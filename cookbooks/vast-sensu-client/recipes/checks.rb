### Checks
# Load check
sensu_check "check-load" do
  type "metric"
  command "check-load.rb -p"
  handlers ["flapjack"]
  subscribers ["base"]
  interval 60
  additional(:notification => "Load status", :occurrences => 3)
end

# Disk check
sensu_check "check-disk" do
  type "metric"
  command "check-disk.rb -w :::disk.wspace::: -c :::disk.cspace::: -W :::disk.winode::: -K :::disk.cinode::: -L :::disk.mount::: -d"
  handlers ["flapjack"]
  subscribers ["base"]
  interval 60
  additional(:notification => "Disk space", :occurrences => 3)
end

# SSH check
sensu_check "check_ssh" do
  type "metric"
  command "check_ssh -t 20 -p 22 :::address:::"
  handlers ["flapjack", "relay"]
  subscribers ["base"]
  interval 60
  additional(:output_type => "nagios", :notification => "SSH service status", :occurrences => 3)
end


### Metrics
# Load metrics
sensu_check "load-metrics" do
  type "metric"
  command "load-metrics.rb -p --scheme :::graphite.name:::"
  handlers ["flapjack", "relay"]
  subscribers ["base"]
  interval 60
  additional(:notification => "Load metrics", :occurrences => 3)
end


### Resart sensu-server
include_recipe "vast-sensu-client::service-restart"
