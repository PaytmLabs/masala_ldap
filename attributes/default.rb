
default['masala_ldap']['slapd_type'] = nil
default['masala_ldap']['rootpw_clear'] = 'devuser'
default['masala_ldap']['org_name'] = 'Masala'

default['masala_ldap']['data_bag_item'] = 'example_users'

case node['platform_family']
when 'rhel'
    default['masala_ldap']['service']['sshd'] = 'sshd'
when 'debian'
    default['masala_ldap']['service']['sshd'] = 'ssh'
else
    default['masala_ldap']['service']['sshd'] = 'sshd'
end

default['openldap']['syncrepl_interval'] = '00:00:10:00'
