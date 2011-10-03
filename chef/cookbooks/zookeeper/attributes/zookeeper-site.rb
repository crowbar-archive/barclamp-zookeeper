#
# Cookbook Name: zookeeper
# Attributes: zookeeper-site.rb
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
# Site Specific ZOOKEEPER settings.
#######################################################################

# Provides the ability separate zookeeper services in logical groups.
default[:zookeeper][:cluster_name] = "default"

# The number of milliseconds of each tick.
default[:zookeeper][:tick_time] = "2000"

# The number of ticks that the initial synchronization phase can take.
default[:zookeeper][:init_limit] = "10"

# The number of ticks that can pass between sending a request and
# getting an acknowledgement.
default[:zookeeper][:sync_limit] = "5"

# Directory where the Zookeeper snapshot is stored.
default[:zookeeper][:data_dir] = "/var/zookeeper"

# Directory where the data log is stored.
default[:zookeeper][:data_log_dir] = "/var/log/zookeeper"

# Increase the heapsize of the ZooKeeper-Server instance to 4GB.
default[:zookeeper][:jvm_flags] = "-Dzookeeper.log.threshold=INFO -Xmx4G"

# Port at which the clients will connect.
default[:zookeeper][:client_port] = "2181"

# Server peer port.
default[:zookeeper][:peer_port] = "2888"

# Server leader port.
default[:zookeeper][:leader_port] = "3888"
