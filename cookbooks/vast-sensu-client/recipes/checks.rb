### Default handlers
default_handlers = node['sensu']['default_handlers']
metric_handlers = node['sensu']['metric_handlers']



### Sensu checks
# Load check
sensu_check "check-load" do
  type "metric"
  command "check-load.rb -p"
  handlers default_handlers
  subscribers ["awsbase"]
  interval 60
  additional(:occurrences => 3)
end

# Disk check
sensu_check "check-disk" do
  type "metric"
  command "check-disk.rb -w :::disk.wspace::: -c :::disk.cspace::: -W :::disk.winode::: -K :::disk.cinode::: -L :::disk.mount::: -d"
  handlers default_handlers
  subscribers ["awsbase"]
  interval 60
  additional(:occurrences => 3)
end



### Sensu metrics (graphite format)
# Load metrics
sensu_check "load-metrics" do
  type "metric"
  command "load-metrics.rb -p --scheme :::graphite.name:::"
  handlers metric_handlers
  subscribers ["awsbase"]
  interval 60
  additional(:occurrences => 3)
end

# Vmstat metrics
sensu_check "vmstat-metrics" do
  type "metric"
  command "vmstat-metrics.rb --scheme :::graphite.name:::"
  handlers metric_handlers
  subscribers ["awsbase"]
  interval 60
  additional(:occurrences => 3)
end



### Nagios checks (with perfdata mutated to graphite format)
# SSH check
sensu_check "check_ssh" do
  type "metric"
  command "check_ssh -t 20 -p :::ssh.port::: :::address:::"
  handlers default_handlers + metric_handlers
  subscribers ["awsbase"]
  interval 60
  additional(:output_type => "nagios", :occurrences => 3)
end

# Surfer check
sensu_check "surfer" do
  type "metric"
  command "surfer.py -n -e graphite -c /etc/sensu/plugins/surfer.json"
  handlers default_handlers + metric_handlers
  subscribers ["surfer_graphite"]
  interval 60
  additional(:output_type => "nagios", :occurrences => 3)
end



### Resart sensu-server
include_recipe "vast-sensu-client::service-restart"
