#
# Cookbook Name:: masala_ldap
# Provider:: group
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
  dn = "cn=#{new_resource.common_name},ou=groups,#{node['openldap']['basedn']}"

#  converge_by("Creating #{dn}") do
    ldap_entry dn do
      credentials ldap_creds
      host node['openldap']['slapd_master']
      attributes({ objectClass: [ 'top', 'posixGroup' ],
                    cn: new_resource.common_name,
                    gidNumber: new_resource.gid_number.to_s,
                    memberUid: new_resource.members
      })
    end
#  end

end


action :delete do

  ldap_creds = Hash['bind_dn' => "cn=#{node['openldap']['cn']},#{node['openldap']['basedn']}", "password" => node['masala_ldap']['rootpw_clear']]
  dn = "cn=#{new_resource.common_name},ou=groups,#{node['openldap']['basedn']}"

  converge_by("Deleting #{dn}") do
    ldap_entry dn do
      credentials ldap_creds
      host node['openldap']['slapd_master']
      action :delete
    end
  end
 
end
