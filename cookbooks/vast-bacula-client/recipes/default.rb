#
# Cookbook Name:: vast-bacula-client
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#package "bacula-client"

#cookbook_file "/etc/bacula/bacula-fd.conf" do
#	source "bacula-fd.conf"
#	mode 0600
#end

template "/etc/bacula/bacula-fd.conf" do
	variables :wd => node['bacula']['wd'][node['platform_family']]
	source "bacula-fd.erb"
	mode 0600
end

#service "bacula-fd" do
#	action [ :enable, :start ]
#end
