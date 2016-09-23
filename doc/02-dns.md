# Domain Name Service

## Learning goals

- Being able to set up and test a DNS-server with BIND
   - Understanding BIND's configuration files, particularly zone files, and being able to find and fix errors
   - Knowing how to query a DNS server with `dig`

## Assignment

DNS is essential for any network domain, and quite a few ([according to some, *all*](http://www.krisbuytaert.be/blog/)) problems in a network can be traced back to errors in DNS. There are several implementations of DNS servers, but the most used by far is [ISC BIND](https://www.isc.org/downloads/bind/).

The goal of this assignment is to set up an authoritative DNS server for our domain `avalon.lan`.

- An overview of all hosts in the domain can be found in the README of this repository. Your virtualization host will not get a host name entry in the DNS.
- All other hosts should get a *forward* (name -> IP) and *reverse* (IP -> name) lookup record. The specified aliases should also be recognized and yield the correct host and IP address.
- Add an MX record pointing to the mail server with preference number 10
- Set up a secondary (slave) DNS server. It has no zone files of its own, but synchronizes with the primary (master) DNS server. The slave should respond to the same requests as the master.

The setup is completely automated with Ansible. Using existing roles is permitted, e.g. [bertvv.bind](https://galaxy.ansible.com/bertvv/bind/) (**Read the documentation carefully!!**).

Check what happens on the server. How does the configuration file look? What's in the zone files? Make sure you understand the syntax and structure of BIND configuration so you are able to troubleshoot this.


