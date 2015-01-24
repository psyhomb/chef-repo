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

vault = ChefVault::Item.load('certs', 'ssl')

#%w[key cert].each do |f|
# template "/tmp/sensu/#{f}.pem" do
#   variables :"#{f}" => data['client'][f]
#   source "#{f}.erb"
#   group "root"
#   mode "0644"
#   action :create
#  end
#end
