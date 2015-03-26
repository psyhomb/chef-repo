### Install Sensu client service and plugins
include_recipe 'vast-sensu-client::vault'
include_recipe 'sensu::default'

ip_type = node['monitor']['use_local_ipv4'] ? 'local_ipv4' : 'public_ipv4'
client_attributes = node['monitor']['additional_client_attributes'].to_hash

sensu_client node.name do
  if node.has_key?('cloud')
    address node['cloud'][ip_type] || node['ipaddress']
  else
    address node['ipaddress']
  end
  subscriptions node['roles'] + ['all']
  #subscriptions ( node['roles'] + ['all'] ) - sensu_client_bag_item['subscriptions_exceptions']
  additional client_attributes
end

remote_directory '/etc/sensu/plugins' do
  source 'plugins/default'
  files_mode '0755'
  files_owner 'sensu'
  files_group 'sensu'
  #mode '0755'
  owner 'root'
  group 'sensu'
end

if node['monitor']['use_nagios_plugins']
  include_recipe 'vast-sensu-client::nagios-plugins'
end

include_recipe 'sensu::client_service'
