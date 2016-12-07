#
# Cookbook Name:: masala_ldap
# Provider:: user
#
# Copyright 2016, Paytm Labs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use_inline_resources

action :create do

  ldap_creds = Hash['bind_dn' => "cn=#{node['openldap']['cn']},#{node['openldap']['basedn']}", "password" => node['masala_ldap']['rootpw_clear']]
  dn = "uid=#{new_resource.common_name},ou=users,#{node['openldap']['basedn']}"

#  converge_by("Creating #{dn}") do
    require 'digest'
    require 'base64'
    salt = ( rand * 10 ** 5 ).to_s

    attrs = { objectClass: [ 'top', 'person', 'inetOrgPerson', 'posixAccount', 'shadowAccount' ],
                    uid: new_resource.common_name,
                    cn: new_resource.common_name,
                    sn: new_resource.surname,
                    givenName: new_resource.firstname,
                    loginShell: '/bin/bash',
                    uidNumber: new_resource.uid_number.to_s,
                    gidNumber: new_resource.gid_number.to_s,
                    homeDirectory: '/home/' + new_resource.common_name
    }
    seed_attrs = {}
    if new_resource.password
        seed_attrs['userPassword'] = new_resource.password =~ /^{SSHA}/ ? new_resource.password : '{SSHA}' + Base64.encode64(Digest::SHA1.digest( new_resource.password + salt ) + salt ).chomp
    end
    if new_resource.ssh_pubkey && !new_resource.ssh_pubkey.nil?
        attrs[:sshPublicKey] = new_resource.ssh_pubkey
        attrs[:objectClass].push('ldapPublicKey')
    end
    if new_resource.mail && !new_resource.mail.nil?
        attrs['mail'] = new_resource.mail
    end

    ldap_entry dn do
      credentials ldap_creds
      host node['openldap']['slapd_master']
      attributes attrs
      seed_attributes seed_attrs if not seed_attrs.empty?
    end
#  end
end

action :delete do

  ldap_creds = Hash['bind_dn' => "cn=#{node['openldap']['cn']},#{node['openldap']['basedn']}", "password" => node['masala_ldap']['rootpw_clear']]
  dn = "uid=#{new_resource.common_name},ou=users,#{node['openldap']['basedn']}"

  converge_by("Deleting #{dn}") do
    ldap_entry dn do
      credentials ldap_creds
      host node['openldap']['slapd_master']
      action :delete
    end
  end
end

