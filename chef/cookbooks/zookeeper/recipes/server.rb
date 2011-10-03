#
# Cookbook Name: zookeeper
# Recipe: zookeeper-server.rb
#
# Copyright (c) 2011 Dell Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Paul Webster
#

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:zookeeper][:debug]
Chef::Log.info("BEGIN zookeeper:server") if debug

# Configuration filter for our environment
env_filter = " AND environment:#{node[:zookeeper][:config][:environment]}"

# Install the zookeeper server package.
package "hadoop-zookeeper-server" do
  action :install
end

# Define the zookeeper server service.
service "hadoop-zookeeper-server" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :enable
end

# Find the zookeeper servers in this cluster. 
servers = Array.new
search(:node, "roles:zookeeper-server AND zookeeper_cluster_name:#{node[:zookeeper][:cluster_name]}") do |n|
  ipaddress = BarclampLibrary::Barclamp::Inventory.get_network_by_type(n,"admin").address
  obj = n.clone
  obj[:ipaddress] = ipaddress
  Chef::Log.info("FOUND ZOOKEEPER SERVER [#{obj[:ipaddress]}") if debug
  servers << obj 
end
if servers.size > 0
  servers.sort! { |a, b| a.name <=> b.name }
else 
  Chef::Log.warn("NO ZOOKEEPER SERVERS FOUND")
end
node[:zookeeper][:servers] = servers
node.save

# Enumerate the server listing.
myip = BarclampLibrary::Barclamp::Inventory.get_network_by_type(node,"admin").address
Chef::Log.info("MY IP [#{myip}") if debug
myid = servers.collect { |n| n[:ipaddress] }.index(myip)
Chef::Log.info("MY ID [#{myid}") if debug

# Update the zookeeper log4j configuration.
template "/etc/zookeeper/log4j.properties" do
  source "log4j.properties.erb"
  mode 0644
  notifies :restart, resources(:service => "hadoop-zookeeper-server")
end

# Update the zookeeper configuration file.
template "/etc/zookeeper/zoo.cfg" do
  source "zoo.cfg.erb"
  mode 0644
  variables(:servers => servers)
  notifies :restart, resources(:service => "hadoop-zookeeper-server")
end

# Update the zookeeper server id configuration.
template "#{node[:zookeeper][:data_dir]}/myid" do
  source "myid.erb"
  mode 0644
  variables(:myid => myid)
  notifies :restart, resources(:service => "hadoop-zookeeper-server")
end

# Update the zookeeper server startup script.
template "/usr/bin/zookeeper-server" do
  owner "root"
  group "root"
  mode "0755"
  source "zookeeper-server.erb"
  notifies :restart, resources(:service => "hadoop-zookeeper-server")
end

# Start the zookeeper server process.
service "hadoop-zookeeper-server" do
  action :start
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END zookeeper:server") if debug
