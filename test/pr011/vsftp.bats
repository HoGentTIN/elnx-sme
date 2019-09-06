#! /usr/bin/env bats
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Test a Vsftpd server

#
# Variables
#
sut_ip=172.16.192.11   # IP of the System Under Test
admin_user=bert      # User with admin privileges
admin_password=bert
testfile="tst${RANDOM}"

# Useful return codes

# FTP
ftp_pathname_created=257

# curl
curl_ok=0
curl_err_access_denied=9
curl_err_retr_failed=9
curl_err_failed_to_log_in=67
curl_err_resource_doesnt_exist=78
#

# {{{Helper functions
# Check that a user has read acces to a share
# Usage: assert_read_access SHARE USER PASSWORD
assert_read_access() {
  local share=${1}
  local user=${2}
  local password=${3}

  run curl "ftp://${sut_ip}/${share}/" --user ${user}:${password}
  [ "${curl_ok}" -eq "${status}" ]
}

# Check that a user has NO read access to a share
# Usage: assert_no_read_access SHARE USER PASSWORD
assert_no_read_access() {
  local share=${1}
  local user=${2}
  local password=${3}

  run curl "ftp://${sut_ip}/${share}/" --user ${user}:${password}
  [ "${curl_err_access_denied}" -eq "${status}" ]
}

# Check that a user has write access to a share.
# Usage: assert_write_access SHARE USER PASSWORD
assert_write_access() {
  local share=${1}
  local user=${2}
  local password=${3}

  run curl "ftp://${sut_ip}/${share}/" \
    --request "MKD ${testfile}" \
    --user ${user}:${password}
  echo "${output}" | grep "RETR response: ${ftp_pathname_created}"
  run curl "ftp://${sut_ip}/${share}/" \
    --request "RMD ${testfile}" \
    --user ${user}:${password}
}

# Check that a user has NO write access to a share.
# Writing can be blocked in (at least) two ways:
# - the USER has no read access => curl gives an "access denied" error
# - the USER has read acces, but can't write => curl gives a "RETR failed"
#   error with an FTP error code denoting "file unavailable"
# Usage: assert_no_write_access USER SHARE
assert_no_write_access() {
  local share=${1}
  local user=${2}
  local password=${3}

  run curl "ftp://${sut_ip}/${share}/" \
    --request "MKD ${testfile}" \
    --user ${user}:${password}
  if [ "${curl_err_access_denied}" -eq "${status}" ]; then
    # user has no read access
    return 0
  elif [ "${curl_err_retr_failed}" -eq "${status}" ]; then
    # user can read, but has no write access
    echo ${output} | grep "${ftp_file_unavailable}"
  fi
}
# }}}

#
# Tests
#

# Preliminaries

@test 'VSFTPD service should be running' {
  sudo systemctl status vsftpd.service
}

@test 'VSFTPD service should be enabled at boot' {
  sudo systemctl is-enabled vsftpd.service
}

@test 'The ’curl’ command should be installed' {
  which curl
}

@test 'The SELinux status should be ‘enforcing’' {
  [ -n "$(sestatus) | grep 'enforcing'" ]
}

@test 'FTP traffic should pass through the firewall' {
  firewall-cmd --list-all | grep 'services.*ftp\b'
}

# Configuration

@test 'VSFTPD configuration should be syntactically correct' {
  # skip # slow test
  run sudo vsftpd -olisten=NO /etc/vsftpd/vsftpd.conf
  [ -z "${output}" ]
}

@test 'Anonymous user should not be able to see shares' {
  # skip #slow test
  run curl ftp://${sut_ip}/
  [ "${curl_err_failed_to_log_in}" -eq "${status}" ]
}

# Read/write access

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
