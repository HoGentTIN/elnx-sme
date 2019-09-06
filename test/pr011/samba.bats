#! /usr/bin/env bats
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Test a Samba server

#
# Variables
#
sut_ip=172.16.192.11   # IP of the system under test
sut_wins_name=FILES    # NetBIOS name
workgroup=AVALON       # Workgroup
admin_user=bert        # User with admin privileges
admin_password=bert

samba_share_root=/srv/shares # Root directory of shares
# The name of a directory and file that will be created to test for
# write access (= random string)
test_dir=peghawJaup
test_file=Nocideicye

# {{{Helper functions

teardown() {
  # Remove all test directories and files
  find "${samba_share_root}" -maxdepth 2 -type d -name "${test_dir}" \
    -exec rm -rf {} \;
  find "${samba_share_root}" -maxdepth 2 -type f -name "${test_file}" \
    -exec rm {} \;
  find "/home" -maxdepth 2 -type d -name "${test_dir}" \
    -exec rm -rf {} \;
  find "/home" -maxdepth 2 -type f -name "${test_file}" \
    -exec rm {} \;
  rm -f "${test_file}"
}

# Checks if a user has shell access to the system
# Usage: assert_can_login USER PASSWD
assert_can_login() {
  echo $2 | su -c 'ls ${HOME}' - $1
}

# Checks that a user has NO shell access to the system
# Usage: assert_cannot_login USER
assert_cannot_login() {
  run sudo su -c 'ls' - $1
  [ "0" -ne "${status}" ]
}

# Check that a user has read acces to a share
# Usage: read_access SHARE USER PASSWORD
assert_read_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command='ls'
  [ "${status}" -eq "0" ]
}

# Check that a user has NO read access to a share
# Usage: no_read_access SHARE USER PASSWORD
assert_no_read_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command='ls'
  [ "${status}" -eq "1" ]
}

# Check that a user has write access to a share
# Usage: write_access SHARE USER PASSWORD
assert_write_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command="mkdir ${test_dir};rmdir ${test_dir}"
  # Output should NOT contain any error message. Checking on exit status is
  # not reliable, it can be 0 when the command failed...
  [ -z "$(echo ${output} | grep NT_STATUS_)" ]
}

# Check that a user has NO write access to a share
# Usage: no_write_access SHARE USER PASSWORD
assert_no_write_access() {
  local share="${1}"
  local user="${2}"
  local password="${3}"

  run smbclient "//${sut_wins_name}/${share}" \
    --user=${user}%${password} \
    --command="mkdir ${test_dir};rmdir ${test_dir}"
  # Output should contain an error message (beginning with NT_STATUS, usually
  # NT_STATUS_MEDIA_WRITE_PROTECTED
  [ -n "$(echo ${output} | grep NT_STATUS_)" ]
}

# Check that users from the same group can write to each other’s files
# Usage: assert_group_write_file SHARE USER1 PASSWD1 USER2 PASSWD2
assert_group_write_file() {
  local share="${1}"
  local user1="${2}"
  local passwd1="${3}"
  local user2="${4}"
  local passwd2="${5}"

  echo "Hello world!" > ${test_file}

  smbclient "//${sut_wins_name}/${share}" --user=${user1}%${passwd1} \
    --command="put ${test_file}"
  # In order to overwrite the file, write access is needed. This will fail
  # if user2 doesn’t have write access.
  smbclient "//${sut_wins_name}/${share}" --user=${user2}%${passwd2} \
    --command="put ${test_file}"
}

# Check that users from the same group can write to each other’s directories
# Usage: assert_group_write_dir SHARE USER1 PASSWD1 USER2 PASSWD2
assert_group_write_dir() {
  local share="${1}"
  local user1="${2}"
  local passwd1="${3}"
  local user2="${4}"
  local passwd2="${5}"

  smbclient "//${sut_wins_name}/${share}" --user=${user1}%${passwd1} \
    --command="mkdir ${test_dir}; mkdir ${test_dir}/tst"
  run smbclient "//${sut_wins_name}/${share}" --user=${user2}%${passwd2} \
    --command="rmdir ${test_dir}/tst"
  [ -z $(echo "${output}" | grep NT_STATUS_ACCESS_DENIED) ]
}

#}}}

# Preliminaries

@test 'The ’nmblookup’ command should be installed' {
  which nmblookup
}

@test 'The ’smbclient’ command should be installed' {
  which smbclient
}

@test 'The Samba service should be running' {
  systemctl status smb.service
}

@test 'The Samba service should be enabled at boot' {
  systemctl is-enabled smb.service
}

@test 'The WinBind service should be running' {
  systemctl status nmb.service
}

@test 'The WinBind service should be enabled at boot' {
  systemctl is-enabled nmb.service
}

@test 'The SELinux status should be ‘enforcing’' {
  [ -n "$(sestatus) | grep 'enforcing'" ]
}

@test 'Samba traffic should pass through the firewall' {
  firewall-cmd --list-all | grep 'services.*samba\b'
}

#
# 'White box' tests
#

# Users

@test 'Check existence of users' {
  id -u ${admin_user}
}

@test 'Checks shell access of users' {
}

#
# Black box, acceptance tests
#

# Samba configuration

@test 'Samba configuration should be syntactically correct' {
  testparm --suppress-prompt /etc/samba/smb.conf
}

@test 'NetBIOS name resolution should work' {
  # Look up the Samba server’s NetBIOS name under the specified workgroup
  # The result should contain the IP followed by NetBIOS name
  nmblookup -U ${sut_ip} --workgroup ${workgroup} ${sut_wins_name} \
    | grep "^${sut_ip} ${sut_wins_name}"
}

# Read / write access to shares
@test 'read access for share ‘public’' {
  #                      Share      User          Password
  assert_read_access     public     alexanderd    alexanderd
  assert_read_access     public     anc           anc
  assert_read_access     public     benoitp       benoitp
  assert_read_access     public     christophev   christophev
  assert_read_access     public     elenaa        elenaa
  assert_read_access     public     evyt          evyt
  assert_read_access     public     krisv         krisv
  assert_read_access     public     leend         leend
  assert_read_access     public     nehirb        nehirb
  assert_read_access     public     stefaanv      stefaanv
  assert_read_access     public     stevenh       stevenh
  assert_read_access     public     stevenv       stevenv
  assert_read_access     public     svena         svena
  assert_read_access     public     ${admin_user} ${admin_password}
}

@test 'write access for share ‘public’' {
  #                      Share      User          Password
  assert_write_access    public     alexanderd    alexanderd
  assert_write_access    public     anc           anc
  assert_write_access    public     benoitp       benoitp
  assert_write_access    public     christophev   christophev
  assert_write_access    public     elenaa        elenaa
  assert_write_access    public     evyt          evyt
  assert_write_access    public     krisv         krisv
  assert_write_access    public     leend         leend
  assert_write_access    public     nehirb        nehirb
  assert_write_access    public     stefaanv      stefaanv
  assert_write_access    public     stevenh       stevenh
  assert_write_access    public     stevenv       stevenv
  assert_write_access    public     svena         svena
  assert_write_access    public     ${admin_user} ${admin_password}
}

@test 'read access for share ‘management’' {
  skip
  #                      Share      User          Password
  assert_no_read_access  management alexanderd    alexanderd
  assert_no_read_access  management anc           anc
  assert_no_read_access  management benoitp       benoitp
  assert_no_read_access  management christophev   christophev
  assert_read_access     management elenaa        elenaa
  assert_no_read_access  management evyt          evyt
  assert_read_access     management krisv         krisv
  assert_no_read_access  management leend         leend
  assert_no_read_access  management nehirb        nehirb
  assert_no_read_access  management stefaanv      stefaanv
  assert_read_access     management stevenh       stevenh
  assert_no_read_access  management stevenv       stevenv
  assert_no_read_access  management svena         svena
  assert_no_read_access  management ${admin_user} ${admin_password}
}

@test 'write access for share ‘management’' {
  skip
  #                      Share      User          Password
  assert_no_write_access management alexanderd    alexanderd
  assert_no_write_access management anc           anc
  assert_no_write_access management benoitp       benoitp
  assert_no_write_access management christophev   christophev
  assert_write_access    management elenaa        elenaa
  assert_no_write_access management evyt          evyt
  assert_write_access    management krisv         krisv
  assert_no_write_access management leend         leend
  assert_no_write_access management nehirb        nehirb
  assert_no_write_access management stefaanv      stefaanv
  assert_write_access    management stevenh       stevenh
  assert_no_write_access management stevenv       stevenv
  assert_no_write_access management svena         svena
  assert_no_write_access management ${admin_user} ${admin_password}
}

@test 'read access for share ‘technical’' {
  skip
  #                      Share      User          Password
  assert_read_access     technical  alexanderd    alexanderd
  assert_read_access     technical  anc           anc
  assert_read_access     technical  benoitp       benoitp
  assert_read_access     technical  christophev   christophev
  assert_read_access     technical  elenaa        elenaa
  assert_read_access     technical  evyt          evyt
  assert_read_access     technical  krisv         krisv
  assert_read_access     technical  leend         leend
  assert_read_access     technical  nehirb        nehirb
  assert_read_access     technical  stefaanv      stefaanv
  assert_read_access     technical  stevenh       stevenh
  assert_read_access     technical  stevenv       stevenv
  assert_read_access     technical  svena         svena
  assert_read_access     technical  ${admin_user} ${admin_password}
}

@test 'write access for share ‘technical’' {
  skip
  #                      Share      User          Password
  assert_write_access    technical  alexanderd    alexanderd
  assert_write_access    technical  anc           anc
  assert_no_write_access technical  benoitp       benoitp
  assert_no_write_access technical  christophev   christophev
  assert_no_write_access technical  elenaa        elenaa
  assert_write_access    technical  evyt          evyt
  assert_no_write_access technical  krisv         krisv
  assert_write_access    technical  leend         leend
  assert_no_write_access technical  nehirb        nehirb
  assert_write_access    technical  stefaanv      stefaanv
  assert_no_write_access technical  stevenh       stevenh
  assert_write_access    technical  stevenv       stevenv
  assert_no_write_access technical  svena         svena
  assert_no_write_access technical  ${admin_user} ${admin_password}
}

@test 'read access for share ‘sales’' {
  skip
  #                      Share      User          Password
  assert_no_read_access  sales      alexanderd    alexanderd
  assert_no_read_access  sales      anc           anc
  assert_read_access     sales      benoitp       benoitp
  assert_no_read_access  sales      christophev   christophev
  assert_read_access     sales      elenaa        elenaa
  assert_no_read_access  sales      evyt          evyt
  assert_read_access     sales      krisv         krisv
  assert_no_read_access  sales      leend         leend
  assert_no_read_access  sales      nehirb        nehirb
  assert_no_read_access  sales      stefaanv      stefaanv
  assert_read_access     sales      stevenh       stevenh
  assert_no_read_access  sales      stevenv       stevenv
  assert_read_access     sales      svena         svena
  assert_no_read_access  sales      ${admin_user} ${admin_password}
}

@test 'write access for share ‘sales’' {
  skip
  #                      Share      User          Password
  assert_no_write_access sales      alexanderd    alexanderd
  assert_no_write_access sales      anc           anc
  assert_write_access    sales      benoitp       benoitp
  assert_no_write_access sales      christophev   christophev
  assert_no_write_access sales      elenaa        elenaa
  assert_no_write_access sales      evyt          evyt
  assert_no_write_access sales      krisv         krisv
  assert_no_write_access sales      leend         leend
  assert_no_write_access sales      nehirb        nehirb
  assert_no_write_access sales      stefaanv      stefaanv
  assert_no_write_access sales      stevenh       stevenh
  assert_no_write_access sales      stevenv       stevenv
  assert_write_access    sales      svena         svena
  assert_no_write_access sales      ${admin_user} ${admin_password}
}

@test 'read access for share ‘it’' {
  skip
  #                      Share      User          Password
  assert_no_read_access  it         alexanderd    alexanderd
  assert_no_read_access  it         anc           anc
  assert_no_read_access  it         benoitp       benoitp
  assert_read_access     it         christophev   christophev
  assert_read_access     it         elenaa        elenaa
  assert_no_read_access  it         evyt          evyt
  assert_read_access     it         krisv         krisv
  assert_no_read_access  it         leend         leend
  assert_read_access     it         nehirb        nehirb
  assert_no_read_access  it         stefaanv      stefaanv
  assert_read_access     it         stevenh       stevenh
  assert_no_read_access  it         stevenv       stevenv
  assert_no_read_access  it         svena         svena
  assert_read_access     it         ${admin_user} ${admin_password}
}

@test 'write access for share ‘it’' {
  skip
  #                      Share      User          Password
  assert_no_write_access it         alexanderd    alexanderd
  assert_no_write_access it         anc           anc
  assert_no_write_access it         benoitp       benoitp
  assert_write_access    it         christophev   christophev
  assert_no_write_access it         elenaa        elenaa
  assert_no_write_access it         evyt          evyt
  assert_no_write_access it         krisv         krisv
  assert_no_write_access it         leend         leend
  assert_write_access    it         nehirb        nehirb
  assert_no_write_access it         stefaanv      stefaanv
  assert_no_write_access it         stevenh       stevenh
  assert_no_write_access it         stevenv       stevenv
  assert_no_write_access it         svena         svena
  assert_write_access    it         ${admin_user} ${admin_password}
}
