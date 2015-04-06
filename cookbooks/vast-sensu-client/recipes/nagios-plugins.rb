### Install nagios plugins
platform_matched = false

plugins = data_bag_item('sensu', 'nagios')['plugins']
platforms = data_bag_item('sensu', 'nagios')['supports'].keys
platforms_plugins_path = data_bag_item('sensu', 'nagios')['supports']

platforms.each do |platform|

  if platform_family? platform
    platform_matched = true

    node['sensu'][platform]['nagios_plugin_packages'].each do |package_name|
      package package_name
    end

    plugins_path = platforms_plugins_path[platform]['plugins_path']

    plugins.each do |plugin_name|
      link "/etc/sensu/plugins/#{plugin_name}" do
        to "#{plugins_path}/#{plugin_name}"
        only_if "test -f #{plugins_path}/#{plugin_name}"
      end
    end

    break
  end
end

Chef::Log.warn("Can't install nagios plugins - not supported platform family") unless platform_matched
