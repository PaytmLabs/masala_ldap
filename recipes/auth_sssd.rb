#
# Cookbook Name:: masala_ldap
# Recipe:: auth_sssd
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

node.default['sssd_ldap']['ldap_sudo'] = true
node.default['sssd_ldap']['ldap_ssh'] = true
node.default['sssd_ldap']['ldap_autofs'] = true
node.default['sssd_ldap']['authconfig_params'] = "--enablesssd --enablesssdauth --enablelocauthorize --enablemkhomedir --update"

node.default['sssd_ldap']['sssd_conf']['ldap_schema'] = 'rfc2307'
node.default['sssd_ldap']['sssd_conf']['cache_credentials'] = 'true'
node.default['sssd_ldap']['sssd_conf']['ldap_search_base'] = node['openldap']['basedn']
node.default['sssd_ldap']['sssd_conf']['ldap_user_search_base'] = "ou=users,#{node['openldap']['basedn']}"
node.default['sssd_ldap']['sssd_conf']['ldap_group_search_base'] = "ou=groups,#{node['openldap']['basedn']}"
node.default['sssd_ldap']['sssd_conf']['ldap_sudo_search_base'] = "ou=SUDOers,#{node['openldap']['basedn']}"
node.default['sssd_ldap']['sssd_conf']['ldap_tls_cacertdir'] = '/etc/openldap/cacerts'
node.default['sssd_ldap']['sssd_conf']['ldap_id_use_start_tls'] = 'false'
# if you have a domain that doesn't require binding set these two attributes to nil
node.default['sssd_ldap']['sssd_conf']['ldap_default_bind_dn'] = nil
node.default['sssd_ldap']['sssd_conf']['ldap_default_authtok'] = nil
node.default['sssd_ldap']['sssd_conf']['ldap_uri'] = "ldap://#{node['openldap']['server']}:#{node['openldap']['port']}"
node.default['sssd_ldap']['sssd_conf']['access_provider'] = 'ldap' # Should be set to 'ldap' (was nil)
node.default['sssd_ldap']['sssd_conf']['autofs_provider'] = 'ldap'
node.default['sssd_ldap']['sssd_conf']['ldap_user_ssh_public_key'] = 'sshPublicKey'
node.default['sssd_ldap']['sssd_conf']['ldap_access_filter'] = 'objectClass=posixAccount'

# Debian family enablement of mkhomedir
if platform_family?('debian')
  execute 'pam-auth-update' do
    command "pam-auth-update --package"
    action :nothing
  end

  cookbook_file "/usr/share/pam-configs/mkhomedir" do
    source 'mkhomedir'
    mode '0644'
    owner 'root'
    group node['root_group']
    notifies :run, 'execute[pam-auth-update]', :immediately
  end
end

# On redhat 7.0, the right (selinux friendly) way to enable mkhomedir is with oddjob_mkhomedir
# an overly elabourate mechanism to effect the same thing
# selinux can't grant just a module, let alone in a specic context, so it's seperated.
# authconfig should pickup on it's presence
if node['platform_family'] == 'rhel' && node['platform_version'].to_f >= 7.0
  package 'oddjob-mkhomedir'
  service "oddjobd" do
    action [:enable]
  end
  package 'oddjob-mkhomedir' do
    notifies :restart, 'service[oddjobd]', :immediately
  end
end

include_recipe 'sssd_ldap::default'

# register process monitor
ruby_block "datadog-process-monitor-sssd" do
  block do
    # will have 4 processes (sssd, sssd_be, sssd_nss, sssd_pam) plus up to 3 optional
    num_proc = 4
    num_proc += 1 if node['sssd_ldap']['ldap_sudo']
    num_proc += 1 if node['sssd_ldap']['ldap_ssh']
    num_proc += 1 if node['sssd_ldap']['ldap_autofs']
    node.set['masala_base']['dd_proc_mon']['sssd'] = {
      search_string: ['sssd', 'sssd_be', 'sssd_nss', 'sssd_pam', 'sssd_sudo', 'sssd_ssh', 'sssd_autofs'],
      exact_match: true,
      thresholds: {
       critical: [num_proc, num_proc]
      }
    }
  end
  only_if { node['masala_base']['dd_enable'] and not node['masala_base']['dd_api_key'].nil? }
  notifies :run, 'ruby_block[datadog-process-monitors-render]'
end

node.default['openssh']['server']['authorized_keys_command'] = '/usr/bin/sss_ssh_authorizedkeys'
if node['platform_family'] == 'debian' || (node['platform_family'] == 'rhel' && node['platform_version'].to_f >= 7.0)
  node.default['openssh']['server']['authorized_keys_command_user'] = 'nobody'
end

