### Trigger sensu-server restart
ruby_block "sensu_service_trigger" do
  block do
    # Sensu service action trigger for LWRPs.
    # This resource must be defined before the Sensu LWRPs can be used.
  end
  action :nothing
end
