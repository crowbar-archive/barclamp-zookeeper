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

#######################################################################
# Site Specific HIVE settings (/etc/hadoop/conf/zookeeper-site.xml).
#######################################################################

# Default file format for CREATE TABLE statement. Options are TextFile and
# SequenceFile. Users can explicitly say CREATE TABLE ... STORED AS
# <TEXTFILE.
default[:zookeeper][:zookeeper_default_fileformat] = "TextFile"

# This controls whether intermediate files produced by zookeeper between
# multiple map-reduce jobs are compressed. The compression codec and other
# options are determined from hadoop config variables
# mapred.output.compress*.
default[:zookeeper][:zookeeper_exec_compress_intermediate] = "false"

# This controls whether the final outputs of a query (to a local/hdfs file
# or a zookeeper table) is compressed. The compression codec and other options
# are determined from hadoop config variables mapred.output.compress*.
default[:zookeeper][:zookeeper_exec_compress_output] = "false"

# Scratch space for Hive jobs.
# DEFAULT: /tmp/zookeeper-${user.name}
default[:zookeeper][:zookeeper_exec_scratchdir] = "/tmp/zookeeper-crowbar"

# Maximum number of bytes a script is allowed to emit to standard error
# (per map-reduce task). This prevents runaway scripts from filling logs
# partitions to capacity.
default[:zookeeper][:zookeeper_exec_script_maxerrsize] = "100000"

# How many rows in the right-most join operand Hive should buffer before
# emitting the join result.
default[:zookeeper][:zookeeper_join_emit_interval] = "1000"

# Whether to use map-side aggregation in Hive Group By queries.
default[:zookeeper][:zookeeper_map_aggr] = "false"

# Number of retries while opening a connection to metastore.
default[:zookeeper][:zookeeper_metastore_connect_retries] = "5"

# controls whether to connect to remove metastore server or open a new
# metastore server in Hive Client JVM.
default[:zookeeper][:zookeeper_metastore_local] = "true"

# The location of filestore metadata base dir.
default[:zookeeper][:zookeeper_metastore_metadb_dir] = "file:///var/metastore/metadb/"

# Name of the class that implements
# org.apache.hadoop.zookeeper.metastore.rawstore interface. This class is used
# to store and retrieval of raw metadata objects such as table, database.
default[:zookeeper][:zookeeper_metastore_rawstore_impl] = "org.apache.hadoop.zookeeper.metastore.ObjectStore"

# Comma separated list of URIs of metastore servers. The first server that
# can be connected to will be used.
default[:zookeeper][:zookeeper_metastore_uris] = "file:///var/metastore/metadb/"

# location of default database for the warehouse.
default[:zookeeper][:zookeeper_metastore_warehouse_dir] = "/user/zookeeper/warehouse"

# Driver class name for a JDBC metastore.
default[:zookeeper][:javax_jdo_option_ConnectionDriverName] = "org.apache.derby.jdbc.EmbeddedDriver"

# JDBC connect string for a JDBC metastore.
default[:zookeeper][:javax_jdo_option_ConnectionURL] = "jdbc:derby:;databaseName=metastore_db;create=true"
