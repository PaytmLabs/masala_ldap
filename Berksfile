source "https://supermarket.chef.io"

cookbook 'openldap', :git => 'https://github.com/PaytmLabs/chef-openldap.git', :ref => 'feature-our-fixes'
cookbook 'masala_base', :git => 'https://github.com/PaytmLabs/masala_base.git', :ref => 'develop'

# Due to a terrible design decision in berkshelf to not recursively resolve dependencies, we must declare all dependencies of our dependencies

# Dependencies of masala_base:
cookbook 'ixgbevf', :git => 'https://github.com/PaytmLabs/chef-ixgbevf.git', :ref => 'master'
cookbook 'system', :git => 'https://github.com/PaytmLabs/chef-system.git', :ref => 'feature-network-restart-control'
cookbook 'datadog', :git => 'https://github.com/PaytmLabs/chef-datadog.git', :ref => 'kafka-monitor-fix'

metadata
