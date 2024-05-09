#!/bin/sh
command -v puppet > /dev/null && { echo "Puppet is installed! skipping" ; exit 0; }

# Install Puppet
apt-get update
apt-get install -y puppet

# Verify installation
command -v puppet > /dev/null && echo "Puppet installed successfully!" || echo "Failed to install Puppet"