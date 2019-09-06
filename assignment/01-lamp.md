# Setting up a web server

## Learning goals

* Being able to set up a network service with Ansible.
    * Being able to apply existing Ansible roles
    * Understanding the structure of an Ansible *role*, and being able to adapt it (bugfixes, adding small functionalitites)
    * Understanding the concept of Ansible *modules* and being able to apply it
    * Being able to assign a role to a host in the master playbook `ansible/site.yml`
* Understanding the configuration of a LAMP server in order to test and troubleshoot effectively
    * Necessary packages to be installed
    * Validating the availability of a network service remotely
    * Configuring firewall rules
    * Configuring SELinux

## Assignment

A web site is often essential to the public image of an enterprise. This is the first service we will set up for our network. We will be using Apache, MariaDB, and Wordpress as the building blocks for the website.

The installation should be completely automated with Vagrant and Ansible. You can use existing roles (e.g from <https://galaxy.ansible.com/bertvv/>). After `vagrant up` (when the VM is not yet created), the install page of Wordpress should be visible if you use a browser from the *host system* to surf to <https://192.0.2.50/wordpress/>.

SELinux should be active ("enforcing"). The firewall should be up and only allow ssh and web traffic.

The MariaDB database is installed by default with an empty root password, anonymous users (i.e. users with an empty string as user name) and a database named `test`. These should *not* be present in the final system. Use strong passwords.

The web server should also support encrypted communication over HTTPS. When installing HTTPS support for Apache, a default server key and certificate are installed (in `/etc/pki/tls/private` and `/etc/pki/tls/certs`, respectively). [Generate a new (self-signed) certificate](https://wiki.centos.org/HowTos/Https) and ensure that it is installed on the webserver, and that Apache is configured to use that, rather than the default. Remark that generating the certificate should not be part of your Ansible playbook. Create the certificate once, manually. Then copy the necessary files to the correct location within the directory containing your Ansible playbook (usually a subdirectory `files/`). Your Vagrant/Ansible project directory is mounted inside your VM under `/vagrant/`.

## Testing

In the test script `test/pu001/lamp.bats`, you may want to change the variables in the test script to the values you have used in your configuration script:

```bash
mariadb_root_password=fogMeHud8
wordpress_database=wp_db
wordpress_user=wp_user
wordpress_password=CorkIgWac
```
