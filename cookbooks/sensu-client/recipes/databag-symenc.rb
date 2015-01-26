#
# Cookbook Name:: sensu-client
# Recipe:: default
#
# Copyright 2015, psyhomb
#
# All rights reserved - Do Not Redistribute
#

# Use with unencrypted data_bag
#data = data_bag_item("sensu", "ssl")

# Use with encrypted data_bag
data = Chef::EncryptedDataBagItem.load("sensu", "ssl")

directory "/tmp/sensu" do
  owner "root"
  group "root"
  mode "0644"
  action :create
end

template "/tmp/sensu/rabbitmq.json" do
  source "rabbitmq.erb"
  group "root"
  mode "0644"
  action :create
end

%w[key cert].each do |f|
  template "/tmp/sensu/#{f}.pem" do
    variables :"#{f}" => data['client'][f]
    source "#{f}.erb"
    group "root"
    mode "0644"
    action :create
  end
end
