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

The setup is completely automated with Ansible. Using existing roles is permitted, e.g. [bertvv.bind](https://galaxy.ansible.com/bertvv/bind/) (**Read the documentation carefully!!**). To add a new host to the Vagrant environment, you shoud edit two files: `vagrant-hosts.yml` and the master playbook `ansible/site.yml`.

In `vagrant-hosts.yml`, add for the primary DNS server:

```Yaml
- name: pu001
  ip: 192.0.2.10
```

and an appropriate entry for the secondary server. In the master playbook, you should also add entries for both new servers and assign them the appropriate roles.

Check what happens on the server. How does the configuration file look? What's in the zone files? Make sure you understand the syntax and structure of BIND configuration so you are able to troubleshoot this.

## Acceptance tests

Both servers can be validated with the test scripts. Execute `sudo /vagrant/test/runbats.sh` to run them. Remark that these tests run locally on the VMs. Ensure that the DNS service is also available from your host system!
