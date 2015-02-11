#
# Author:: Milos Buncic
# Cookbook Name:: vast-sensu
# Recipe:: default
#
# Copyright 2015, Vast.com
#
# All rights reserved - Do Not Redistribute
#

#%w[
#  vast-sensu::vault
#  sensu::rabbitmq
#  vast-sensu::rabbitmq
#  vast-sensu::rabbitmq-cluster
#  sensu::default
#  vast-sensu::flapjack
#  vast-sensu::checks
#  sensu::server_service
#  sensu::api_service
#].each { |recipe| include_recipe recipe }

%w[
  vast-sensu::vault
  sensu::rabbitmq
  vast-sensu::rabbitmq
  sensu::default
  vast-sensu::flapjack
  vast-sensu::checks
  sensu::server_service
  sensu::api_service
].each { |recipe| include_recipe recipe }
