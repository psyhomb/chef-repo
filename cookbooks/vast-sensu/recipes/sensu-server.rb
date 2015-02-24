# Include all fundamental recipes for sensu-server installation
%w[
    sensu::default
    sensu::server_service
    sensu::api_service
].each { |recipe| include_recipe recipe }
