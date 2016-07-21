#
# Cookbook Name:: masala_ldap
# Recipe:: server
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

include_recipe 'masala_base::default'

# add ldap helpers
include_recipe 'ldap'

directory "#{node['openldap']['dir']}/schema" do
  action :create
  recursive false
  mode '0755'
  owner 'root'
  group node['root_group']
end

cookbook_file "#{node['openldap']['dir']}/schema/openssh-openldap.schema" do
  source 'openssh-openldap.schema'
  mode '0644'
  owner 'root'
  group node['root_group']
end

cookbook_file "#{node['openldap']['dir']}/schema/sudo.schema" do
  source 'sudo.schema'
  mode '0644'
  owner 'root'
  group node['root_group']
end

node.default['openldap']['schemas'] = [
  'corba.schema',
  'core.schema', 
  'cosine.schema',
  'duaconf.schema',
  'dyngroup.schema',
  'inetorgperson.schema',
  'java.schema',
  'misc.schema',
  'nis.schema',
  'openldap.schema',
  'ppolicy.schema',
  'collective.schema',
  'openssh-openldap.schema',
  'sudo.schema'
]

case node['masala_ldap']['slapd_type']
when 'master'
  include_recipe 'openldap::master'
when 'slave'
  include_recipe 'openldap::slave'
else
  include_recipe 'openldap::server'
end

# register process monitor
ruby_block "datadog-process-monitor-slapd" do
  block do
    node.set['masala_base']['dd_proc_mon']['slapd'] = {
      search_string: ['slapd'],
      exact_match: true,
      thresholds: {
       critical: [1, 1]
      }
    }
  end
  only_if { node['masala_base']['dd_enable'] and not node['masala_base']['dd_api_key'].nil? }
  notifies :run, 'ruby_block[datadog-process-monitors-render]'
end


if node['masala_ldap']['slapd_type'] != 'slave'

  # Do structural modifications
  ldap_creds = Hash['bind_dn' => "cn=#{node['openldap']['cn']},#{node['openldap']['basedn']}", "password" => node['masala_ldap']['rootpw_clear']]

  first_dc = node['openldap']['basedn'].split(/, */).first.split(/=/).last

  # FIXME: Hard coded in bits...
  # Top-level organization
  ldap_entry node['openldap']['basedn'] do
    credentials ldap_creds
    host node['openldap']['slapd_master']
    attributes({ objectClass: [ 'dcObject', 'organization'],
                  dc: first_dc,
                  o: node['masala_ldap']['org_name'] })
  end

  # Posix Users, top level
  ldap_entry "ou=users,#{node['openldap']['basedn']}" do
    credentials ldap_creds
    host node['openldap']['slapd_master']
    attributes({ objectClass: [ 'top', 'organizationalUnit' ],
                  ou: 'users' })
  end

  # Posix Groups, top level
  ldap_entry "ou=groups,#{node['openldap']['basedn']}" do
    credentials ldap_creds
    host node['openldap']['slapd_master']
    attributes({ objectClass: [ 'top', 'organizationalUnit' ],
                  ou: 'groups' })
  end

  # SUDO config, top level
  ldap_entry "ou=SUDOers,#{node['openldap']['basedn']}" do
    credentials ldap_creds
    host node['openldap']['slapd_master']
    attributes({ objectClass: [ 'top', 'organizationalUnit' ],
                  ou: 'SUDOers' })
  end

  # Replication User
  if node['masala_ldap']['slapd_type'] == 'master'
    require 'digest'
    require 'base64'
    salt = ( rand * 10 ** 5 ).to_s

    ldap_entry "cn=syncrole,#{node['openldap']['basedn']}" do
      credentials ldap_creds
      host node['openldap']['slapd_master']
      attributes({ objectClass: [ 'simpleSecurityObject', 'organizationalRole' ],
                    cn: 'syncrole',
                    userPassword: node['openldap']['slapd_replpw'] =~ /^{SSHA}/ ? node['openldap']['slapd_replpw'] : '{SSHA}' + Base64.encode64(Digest::SHA1.digest( node['openldap']['slapd_replpw'] + salt ) + salt ).chomp
      })
    end
  end

  if node['masala_ldap']['slapd-type'] != 'slave'
    include_recipe 'masala_ldap::ldap_data'
  end

end
