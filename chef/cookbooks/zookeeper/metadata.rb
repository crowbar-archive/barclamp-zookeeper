maintainer       "Dell, Inc."
maintainer_email "Paul_Webster@Dell.com"
license          "Apache 2.0 License, Copyright (c) 2011 Dell Inc. - http://www.apache.org/licenses/LICENSE-2.0"
description      "A high-performance coordination service for distributed applications. ZooKeeper provides primitives such as distributed locks which can be used for building large scale distributed processing applications."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "1.0"
recipe           "zookeeper::default", "Installs zookeeper base libraries and configuration."
