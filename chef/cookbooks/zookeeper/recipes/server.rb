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
Chef::Log.info("ZOOKEEPER : BEGIN zookeeper:server") if debug

# Configuration filter for our environment.
env_filter = " AND environment:#{node[:zookeeper][:config][:environment]}"

# Install the zookeeper server package.
package "hadoop-zookeeper-server" do
  action :install
end

# Define the zookeeper server service.
# {start|stop|restart|force-reload|status|force-stop}
service "hadoop-zookeeper-server" do
  supports :start => true, :stop => true, :restart => true, :status => true
  action :enable
end

# Find the zookeeper servers.
servers = Array.new
search(:node, "roles:zookeeper-server AND zookeeper_cluster_name:#{node[:zookeeper][:cluster_name]}") do |n|
  ipaddress = BarclampLibrary::Barclamp::Inventory.get_network_by_type(n,"admin").address
  if ipaddress.nil? || ipaddress.empty?
    Chef::Log.warn("ZOOKEEPER : SERVER IP LOOKUP FAILED")
  else    
    rec = {
    :ipaddress => ipaddress,
    :peer_port => n[:zookeeper][:peer_port],
    :leader_port => n[:zookeeper][:leader_port],
    :fqdn => n[:fqdn]
    } 
    Chef::Log.info("ZOOKEEPER : FOUND SERVER [" + rec[:ipaddress] + ", " + rec[:fqdn] + "]") if debug
    servers << rec
  end
end
if servers.size > 0
  servers.sort! { |a, b| a[:ipaddress] <=> b[:ipaddress] }
else
  Chef::Log.warn("ZOOKEEPER : NO SERVERS FOUND")
end

# Find myid - the index into the zookeeper servers list array.
myip = BarclampLibrary::Barclamp::Inventory.get_network_by_type(node,"admin").address
if myip.nil? || myip.empty?
  Chef::Log.warn("ZOOKEEPER : MYIP LOOKUP FAILED")
else    
  Chef::Log.info("ZOOKEEPER : MY IP [#{myip}]") if debug
  myid = servers.collect { |n| n[:ipaddress] }.index(myip)
  myid = myid + 1 if !myid.nil? 
  Chef::Log.info("ZOOKEEPER : MY ID [#{myid}]") if debug
end

# Create data_log_dir and set ownership/permissions (/var/log/zookeeper). 
data_log_dir = node[:zookeeper][:data_log_dir]
directory data_log_dir do
  owner "zookeeper"
  group "zookeeper"
  mode "0755"
  action :create
  only_if { !data_log_dir.nil? && !data_log_dir.empty? }
  notifies :restart, resources(:service => "hadoop-zookeeper-server")
end

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
Chef::Log.info("ZOOKEEPER : END zookeeper:server") if debug
