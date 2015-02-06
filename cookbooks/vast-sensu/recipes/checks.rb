# Cassandra process check
sensu_check "check_cassandra" do
  command "check-procs.rb -p cassandra -C 1"
  handlers ["flapjack"]
  subscribers ["cassandra"]
  interval 60
  additional(:notification => "Cassandra is not running", :occurrences => 3)
end

# Disk check
sensu_check "check_disk" do
  command "check_disk -w 15 -c 10 -p /"
  handlers ["flapjack"]
  subscribers ["base"]
  interval 60
  additional(:notification => "Disk space problem", :occurrences => 3)
end

# SSH check
sensu_check "check_ssh" do
  command "check_ssh -t 20 -p 22 :::address:::"
  handlers ["flapjack"]
  subscribers ["base"]
  interval 60
  additional(:notification => "SSH service is not running!", :occurrences => 3)
end
