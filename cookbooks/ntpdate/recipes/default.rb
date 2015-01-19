#
# Cookbook Name:: ntpdate
# Recipe:: default
#
# Copyright 2014, psyhomb
#
# All rights reserved - Do Not Redistribute
#

package "ntpdate" do
  action :install
end


directory '/var/lock/chef' do
    owner 'root'
    group 'root'
    mode  '0755'
    action :create
end


file '/var/lock/chef/ntpdate_runonce' do
    action :create_if_missing
    notifies :run, 'execute[ntpdate_runonce]', :immediately
end


execute 'ntpdate_runonce' do
    command '/usr/sbin/ntpdate 2.rs.pool.ntp.org'
    action :nothing
end


cookbook_file "/etc/cron.d/ntpdate" do
    source "etc/cron.d/ntpdate"
    action :create
end
