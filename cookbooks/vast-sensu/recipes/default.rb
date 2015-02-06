#
# Cookbook Name:: vast-sensu
# Recipe:: default
#
# Copyright 2015, psyhomb
#
# All rights reserved - Do Not Redistribute
#

# Install RabbitMQ - test
#include_recipe 'vast-sensu::vault'
#include_recipe 'sensu::rabbitmq'
#include_recipe 'rabbitmq::user_management'

# Install, configure and start sensu services
%w[
  vast-sensu::vault
  sensu::default
  vast-sensu::flapjack
  vast-sensu::checks
  sensu::server_service
  sensu::api_service
].each { |recipe| include_recipe recipe }
