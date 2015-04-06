case node['sensu']['sensu_client']
  when true
    # Install and configure sensu-client
    include_recipe 'vast-sensu-client::client-service'
  when false
    # Install and configure checks on sensu-server
    include_recipe 'vast-sensu-client::checks'
end
