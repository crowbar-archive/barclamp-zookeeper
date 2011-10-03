#
# Cookbook Name: zookeeper
# Recipe: zookeeper_service.rb
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

class ZookeeperService < ServiceObject
  
  def initialize(thelogger)
    @bc_name = "zookeeper"
    @logger = thelogger
  end
  
  def create_proposal
    @logger.debug("zookeeper create_proposal: entering")
    base = super
    
    # Get the node list.
    nodes = NodeObject.all
    nodes.delete_if { |n| n.nil? }
    
    # Find the slave nodes for the zookeeper servers.
    # The number of slaves to use depends on the number of failed
    # nodes to support. We follow the (2F+1) rule so we stop allocating
    # at the first 5 slave nodes found.
    slave_nodes = nodes.find_all { |n| n.role? "hadoop-slavenode" }
    slave_fqdns = Array.new
    node_cnt = 0
    slave_nodes.each { |x|
      next if x.nil?
      if !x[:fqdn].nil? && !x[:fqdn].empty? 
        slave_fqdns << x[:fqdn]  
        node_cnt = node_cnt +1
        break if node_cnt >= 5
      end
    }
    
    # Check for errors or add the proposal elements.
    base["deployment"]["zookeeper"]["elements"] = { } 
    if !slave_fqdns.nil? && slave_fqdns.length > 0 
      base["deployment"]["zookeeper"]["elements"]["zookeeper-server"] = slave_fqdns 
    else
      @logger.debug("zookeeper create_proposal: No slave nodes found, proposal bind failed")
    end
    
    @logger.debug("zookeeper create_proposal: exiting")
    base
  end
  
end
