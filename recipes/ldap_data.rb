#
# Cookbook Name:: masala_ldap
# Recipe:: ldap_data
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

if node['masala_ldap'].has_key?('data_bag_item') && !node['masala_ldap']['data_bag_item'].nil?
  ldap_data = data_bag_item('ldap_data', node['masala_ldap']['data_bag_item'])
  ldap_data['groups'].each do |name, attr|
    masala_ldap_group name do
      gid_number attr['gid_number']
      members    attr['members']
    end
  end
  ldap_data['sudoers'].each do |name, attr|
    masala_ldap_sudo name do
      option       attr['option']
      user         attr['user']        if attr.has_key?('user')
      host         attr['host']        if attr.has_key?('host')
      command      attr['command']     if attr.has_key?('command')
      run_as_user  attr['run_as_user'] if attr.has_key?('run_as_user')
    end
  end
  ldap_data['users'].each do |name, attr|
    masala_ldap_user name do
      firstname   attr['firstname']
      surname     attr['surname']
      uid_number  attr['uid_number']
      gid_number  attr['gid_number']
      mail        attr['mail']         if attr.has_key?('mail')
      ssh_pubkey  attr['ssh_pubkey']   if attr.has_key?('ssh_pubkey')
    end
  end
end


