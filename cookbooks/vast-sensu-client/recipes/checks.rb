# Cassandra process check
sensu_check "check_cassandra" do
  type "metric"
  command "check-procs.rb -p cassandra -C 1"
  handlers ["flapjack"]
  subscribers ["cassandra"]
  interval 60
  additional(:notification => "Cassandra status", :occurrences => 3)
end

# Disk check
sensu_check "check_disk" do
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
  handlers ["flapjack"]
  subscribers ["base"]
  interval 60
  additional(:notification => "SSH status!", :occurrences => 3)
end

include_recipe "vast-sensu-client::service-restart"
