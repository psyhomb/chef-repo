#
# Cookbook Name:: vast-sensu
# Recipe:: default
#
# Copyright 2015, psyhomb
#
# All rights reserved - Do Not Redistribute
#

# Install and configure sensu server
include_recipe "vast-sensu::vault"
include_recipe "sensu"
include_recipe "vast-sensu::flapjack"
include_recipe "vast-sensu::checks"

# Start sensu server and api services
include_recipe "sensu::server_service"
include_recipe "sensu::api_service"
