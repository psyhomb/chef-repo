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

vault_server = ChefVault::Item.load('certs', 'ssl')['server']
#vault_client = ChefVault::Item.load('certs', 'ssl')['client']

directory "/tmp/sensu"

vault_server.each do |key, value|
  file "/tmp/sensu/server_#{key}.pem" do
    content value
    owner 'root'
    group 'root'
    mode '644'
  end
end

#%w[key cert].each do |f|
# template "/tmp/sensu/#{f}.pem" do
#   variables :"#{f}" => data['client'][f]
#   source "#{f}.erb"
#   group "root"
#   mode "0644"
#   action :create
#  end
#end
