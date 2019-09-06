# Assignment Enterprise Linux: SME infrastructure

- Student: NAME
- Repository: https://github/com/USER/REPO

The goal of this assignment is to set up the infrastructure for a Small/Medium Enterprise (SME) in a virtualized environment using the [Ansible](https://ansible.com/) configuration management system. When you're finished, you should be able to recreate the entire infrastructure *from scratch* using a minimum of manual interventions, ideally a single command (`vagrant up`).

This repository contains the assignments, some scaffolding code to get you started, and automated acceptance tests to validate whether your solutions conforms to the specifications.

The scaffolding code is based on [ansible-skeleton](https://github.com/bertvv/ansible-skeleton), a framework for quickly setting up an Ansible development and testing environment powered by [Vagrant](https://vagrantup.com).

## Overview

You're hired by Avalon Services, a small but growing startup, to set up their IT infrastructure on-site. Your task is to build the network domain (domain name `avalon.lan`), which is subdivided into two IP ranges:

- 192.0.2.0/24 for public services that should be accessible from the Internet (the so-called "DMZ" or "Demilitarized Zone")
- 172.16.0.0/16 for the internal network.

An overview of notable hosts in the network (remark that you will not set all of these up in the assignment!) can be found below:

| Host name     | Alias     | IP             | Function                 |
| :---          | :---      | :---           | :---                     |
| (host system) |           | 192.0.2.1      | Your physical pc         |
|               |           | 172.16.0.1     |                          |
| router        |           | 192.0.2.254    | Router/DNS forwarder     |
|               | gw        | 172.16.255.254 |                          |
| pu001         | www       | 192.0.2.10     | Webserver                |
| pu002         | mail      | 192.0.2.20     | Mail server              |
| pr001         | ns1       | 172.16.192.1   | Primary DNS              |
| pr002         | ns2       | 172.16.192.2   | Secondary DNS            |
| pr003         | dhcp      | 172.16.192.3   | DHCP server              |
| pr004         | directory | 172.16.192.4   | LDAP server              |
| pr010         | inside    | 172.16.192.10  | Intranet (LAMP)          |
| pr011         | files     | 172.16.192.11  | Fileserver (Samba, FTP)  |
| ws0001        |           | (DHCP)         | Workstation              |

![Diagram of the network to be set up](assignment/avalon-network.png)

## Reporting and documentation

For each partial assignment, write a lab report. **Write documentation **while** you are working on your assignment, **not after** the facts. Your report contains the following elements:

- A **test plan**: a list of steps to perform in order to verify that the requirements are met
    - a test plan may consist only of the command to run the automated acceptance tests. Sometimes, however, you have to check some things manually.
- A detailed description of the **procedure**/process you followed to meet these requirements.
    - It is not necessary to repeat code that is elsewhere in this repository. However, all thought processes and considerations that are not in the code, but that have led you to go into a particular direction, should be clearly documented.
- A **test report**: transcript of a test session according to your test plan that proves that the requirements are met.
    - A test report may contain screenshots. Github Markdown supports including images that reside in your Github repository
    - You can also link to a screencast where you demonstrate the test procedure (e.g. unlisted Youtube video)
- A list of **external resources** you used: manuals, blog posts, books, etc.

Use Github Issues and, optionally, Github Projects to keep a to-do list and visualise work in process. This is a valuable communication tool in the progress reports to your teacher.

## Author/License information

This assignment and the scaffolding code was written by [Bert Van Vreckem](https://github.com/bertvv/).

The assignment and all documentation is shared under the [Creative Commons Attribution 4.0 International](http://creativecommons.org/licenses/by/4.0/) license. All code (both scaffolding and testing code) is subject to the MIT license. See [LICENSE.md](LICENSE.md) for details.

Questions and remarks about this assignment are welcome (use the Issues), as well as improvements, fixes, etc. (you can submit a Pull Request). However, technical support on getting the setup working, or on solving the assignment is reserved to students following the course for which it was developed.
