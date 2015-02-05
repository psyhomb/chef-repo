# Flapjack configuration for Sensu
template "#{node.sensu.directory}/conf.d/flapjack.json" do
  source "vast-flapjack.erb"
  mode   "640"
  owner  "root"
  group  "sensu"
  variables ({
    :host => node.sensu.flapjack.host,
    :port => node.sensu.flapjack.port,
    :db => node.sensu.flapjack.db
  })
end 

# Install flapjack handler (part of https://github.com/sensu/sensu-community-plugins/tree/master/plugins)
directory "#{node.sensu.handlers}"
cookbook_file "#{node.sensu.handlers}/flapjack.rb" do
  owner "root"
  group "sensu"
  mode  "0750"
end
