### Install nagios plugins
platform_matched = false

%w[
  rhel
  debian
].each do |platform|

  if platform_family? platform
    platform_matched = true

    node['monitor'][platform]['nagios_plugin_packages'].each do |package_name|
      package package_name
    end

    case platform 
      when 'rhel'
        plugins_path = "/usr/lib64/nagios/plugins"
      when 'debian'
        plugins_path = "/usr/lib/nagios/plugins"
    end

    plugins = data_bag_item('sensu', 'nagios')['plugins']
    
    plugins.each do |plugin_name|
      link "#{plugins_path}/#{plugin_name}" do
        to "#{plugins_path}/#{plugin_name}"
        only_if "test -f #{plugins_path}/#{plugin_name}"
      end
    end

    break
  end
end

Chef::Log.warn("Can't install nagios plugins - not supported platform family") unless platform_matched
