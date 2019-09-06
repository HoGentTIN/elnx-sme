#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

# Fix for error "INIT: Id "TO" respawning too fast: disabled for 5 minutes"
delete system console device ttyS0

#
# Basic settings
#
set system host-name 'router'
#set service ssh port '22'

#
# IP settings
#

# TODO

#
# Network Address Translation
#

# TODO

#
# Time
#

#

#
# Domain Name Service
#

# TODO

# Make configuration changes persistent
commit
save

# Fix permissions on configuration
sudo chown -R root:vyattacfg /opt/vyatta/config/active

# vim: set ft=sh
