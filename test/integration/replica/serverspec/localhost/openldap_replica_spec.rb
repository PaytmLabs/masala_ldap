require 'spec_helper'

describe command('getent passwd ldap') do
  its(:stdout) { should match(/ldap:x:\d+:\d+:LDAP User:\/var\/lib\/ldap:\/sbin\/nologin/) }
end

describe command('getent passwd jhohertz') do
  its(:stdout) { should match(/jhohertz:\*:\d+:\d+:jhohertz:\/home\/jhohertz:\/bin\/bash/) }
end
