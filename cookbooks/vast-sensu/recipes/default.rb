#
# Cookbook Name:: vast-sensu
# Recipe:: default
#
# Copyright 2015, psyhomb
#
# All rights reserved - Do Not Redistribute
#

# Install, configure and start sensu services
%w[
  vast-sensu::vault
  sensu::default
  vast-sensu::flapjack
  vast-sensu::checks
  sensu::server_service
  sensu::api_service
].each { |recipe| include_recipe recipe }
