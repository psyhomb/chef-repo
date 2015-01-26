#
# Cookbook Name:: sensu-client
# Recipe:: default
#
# Copyright 2015, psyhomb
#
# All rights reserved - Do Not Redistribute
#

chef_gem 'chef-vault'
require 'chef-vault'

server = ChefVault::Item.load('certs', 'ssl')['server']
client = ChefVault::Item.load('certs', 'ssl')['client']

directory "/tmp/sensu"

server.each do |key, value|
  file "/tmp/sensu/server_#{key}.pem" do
    content value
    owner 'root'
    group 'root'
    mode '644'
  end
end

client.each do |key, value|
  file "/tmp/sensu/client_#{key}.pem" do
    content value
    owner 'root'
    group 'root'
    mode '644'
  end
end
