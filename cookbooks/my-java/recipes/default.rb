#
# Cookbook Name:: my-java
# Recipe:: default
#
# Copyright 2015, psyhomb
#
# All rights reserved - Do Not Redistribute
#

#node.default["checksums"]["8u31"] = "efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437"
#node.default["checksums"]["7u76"] = "ce8ff4fed2cd16aea432edf8e94f21ccfe29e9d4a659bbbef3551982769e0c8c"
#node.default["checksums"]["7u75"] = "460959219b534dc23e34d77abc306e180b364069b9fc2b2265d964fa2c281610"

#node.checksums.each do |version, checksum|
#  Chef::Log.info("#{version} => #{checksum}")
#end

#include_recipe 'my-java::java8'
#include_recipe 'my-java::java-uniform'
include_recipe 'my-java::java2-uniform'
