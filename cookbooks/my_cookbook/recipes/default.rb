#
# Cookbook Name:: my_cookbook
# Recipe:: default
#
# Copyright 2014, psyhomb
#
# All rights reserved - Do Not Redistribute
#

#message = node['my_cookbook']['message']

#Chef::Log.info("#{message}")

#template '/tmp/message' do
#    source 'message.erb'
#    variables(
#        hi: 'Hello',
#        world: 'World',
#        from: node['fqdn']
#    )
#end

#deploy_dirs do
#  deploy_to "/srv"  
#end

#ENV['MESSAGE'] = 'Hello from Chef'

#execute 'Print value of env var $MESSAGE' do
#  command 'echo $MESSAGE > /tmp/message'
#  environment 'MESSAGE' => 'Ovo je samo test'
#end

#max_mem = node['memory']['total'].to_i

#execute 'Print max memory size' do
#  command "echo #{max_mem} > /tmp/max_memory_size"
#end

#node.override['my_cookbook']['version'] = '1.1.1'

#execute 'Change recipe version' do
#  command "echo #{node['my_cookbook']['version']} > /tmp/recipe_version"
#end

hook = data_bag_item('hooks', 'request_psyhomb')
http_request 'callback' do
  url hook['url']
end
