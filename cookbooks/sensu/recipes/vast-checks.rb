# Cassandra process check
sensu_check "check_cassandra" do
  command "check-procs.rb -p cassandra -C 1"
  handlers ["flapjack"]
  subscribers ["cassandra"]
  interval 30
  additional(:notification => "Cassandra is not running!", :occurrences => 5)
end
