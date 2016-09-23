#! /usr/bin/env bats
#
# Acceptance test script for srv010
admin_user=bert

@test "EPEL repository should be available" {
  [ -n "$(yum -C repolist | grep 'epel')" ]
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

@test "Custom /etc/motd should have been installed" {
  [ -f /etc/motd ]
  [ -n "$(grep enp0s3 /etc/motd)" ]
}


