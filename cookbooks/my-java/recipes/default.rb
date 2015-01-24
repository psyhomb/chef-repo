#
# Cookbook Name:: my-java
# Recipe:: default
#
# Copyright 2015, psyhomb
#
# All rights reserved - Do Not Redistribute
#

# Download jdk
# curl -L -H "Cookie: oraclelicense=accept" http://download.oracle.com/otn-pub/java/jdk/8u31-b13/jdk-8u31-linux-x64.tar.gz -O

#include_recipe 'my-java::java8'
include_recipe 'my-java::java-uniform'
