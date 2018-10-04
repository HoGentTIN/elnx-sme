#! /usr/bin/env bats
#
# Acceptance test script for srv010
admin_user=bert

@test "SELinux should be set to 'Enforcing'" {
  [ 'Enforcing' = $(getenforce) ]
}

@test "Firewall should be enabled and running" {
  systemctl is-active firewalld.service
  systemctl is-enabled firewalld.service
}

@test "EPEL repository should be available" {
  [ -n "$(yum repolist | grep 'epel')" ]
}

@test "Bash-completion should have been installed" {
  # This file should exist if bash-completion was installed
  [ -f /etc/profile.d/bash_completion.sh ]
}

@test "bind-utils should have been installed" {
  # Ask version of dig, this should execute with exit status 0
  dig -v
}

@test "Git should have been installed" {
  git --version
}

@test "Nano should have been installed" {
  nano --version
}

@test "Tree should have been installed" {
  tree --version
}

@test "Vim-enhanced should have been installed" {
  vim --version
}

@test "Wget should have been installed" {
  wget --version
}

@test "Admin user ${admin_user} should exist" {
  # The user should exist
  getent passwd ${admin_user}
  # and should be member of the `wheel` group
  [ -n "$(groups ${admin_user} | grep wheel)" ]
}

@test "An SSH key should have been installed for ${admin_user}" {
  local keyfile="/home/${admin_user}/.ssh/authorized_keys"
  [ -f "${keyfile}" ]
  [ -s "${keyfile}" ] # should be nonempty
  [ $(stat --format="%a" "${keyfile}") = '600' ]

}

@test "Custom /etc/motd should have been installed" {
  [ -f /etc/motd ] # is a regular file
  [ -s /etc/motd ] # is nonempty
}

