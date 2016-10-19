# Basic server setup

Apply the role `bertvv.rh-base` to the (currently only) server in our setup. Ensure that all hosts in the network will meet the following requirements:

- The EPEL repository must be installed (Extra Packages for Enterprise Linux, a third-party package repository)
- The following packages must be installed on all servers
    - bash-completion
    - bind-utils
    - git
    - nano
    - tree
    - vim-enhanced
    - wget
- Create a user account for yourself. Take your first name in lowercase. This user will become "administrator" of the system, which means `sudo` rights in practice.
- Generate an ssh key pair on your *host system* and install the public key on every server in your user account. You should be able to log into your servers without having to enter a password.
- Use the option to generate a custom `/etc/motd` file that shows network connection information after login.

## Testing

All machines in the setup can be tested by executing the following command:

```console
$ sudo /vagrant/test/runbats.sh
```

The first time you execute this script, it will install [BATS](https://github.com/sstephenson/bats), a unit testing framework written in Bash. There are test suites for every assigment in order to verify whether the requirements are met.

The test script `test/common.bats` will be executed on *all* hosts in the setup. Test scripts that are specific to one server are stored in a subdirectory with the same name as the server.

**Remark** that you need to update your user name in `common.bats` in order for it to work. Adapt the following line:

```bash
admin_user=bert
```

Showing the results of the test suite is essential when showing your work to the lecturer.

## Test plan

Every lab report should contain a test plan. To give an idea of what is meant by this, a test plan for this assignment is given here.

1. On the host system, go to the local working directory of the project repository
2. Execute `vagrant status`
    - There should be one VM, `pu004` with status `not created`. If the VM does exist, destroy it first with `vagrant destroy -f pu004`
3. Execute `vagrant up pu004`
    - The command should run without errors (exit status 0)
4. Log in on the server with `vagrant ssh pu004` and run the acceptance tests. They should succeed

    ```
    [vagrant@pu004 test]$ sudo /vagrant/test/runbats.sh
    Running test /vagrant/test/common.bats
    ✓ EPEL repository should be available
    ✓ Bash-completion should have been installed
    ✓ bind-utils should have been installed
    ✓ Git should have been installed
    ✓ Nano should have been installed
    ✓ Tree should have been installed
    ✓ Vim-enhanced should have been installed
    ✓ Wget should have been installed
    ✓ Admin user bert should exist
    ✓ Custom /etc/motd should be installed

    10 tests, 0 failures
    ```

    Any tests for the LAMP stack may fail, but this is not part of the current assignment.

5. Log off from the server and ssh to the VM as described below. You should **not** get a password prompt.

    ```
    $ ssh bert@192.0.2.50
    Welcome to pu004.localdomain.
    enp0s3     : 10.0.2.15         fe80::a00:27ff:fe5c:6428/64
    enp0s8     : 192.0.2.50        fe80::a00:27ff:fecd:aeed/64
    [bert@pu004 ~]$
    ```
 
