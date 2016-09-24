#! /usr/bin/env bats
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Test a Vsftpd server

#
# Variables
#
sut_ip=172.16.0.11   # IP of the System Under Test
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
# Usage: read_access SHARE USER PASSWORD
read_access() {
  local share=${1}
  local user=${2}
  local password=${3}

  run curl "ftp://${sut_ip}/${share}/" --user ${user}:${password}
  [ "${curl_ok}" -eq "${status}" ]
}

# Check that a user has NO read access to a share
# Usage: no_read_access SHARE USER PASSWORD
no_read_access() {
  local share=${1}
  local user=${2}
  local password=${3}

  run curl "ftp://${sut_ip}/${share}/" --user ${user}:${password}
  [ "${curl_err_access_denied}" -eq "${status}" ]
}

# Check that a user has write access to a share.
# Usage: write_access SHARE USER PASSWORD
write_access() {
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
# Usage: no_write_access USER SHARE
no_write_access() {
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

@test 'Check read access for share ‘publiek’' {

  read_access publiek franka franka
  read_access publiek femkevdv femkevdv
  read_access publiek hansb hansb
  read_access publiek kimberlyvh kimberlyvh
  read_access publiek taniav taniav
  read_access publiek peterj peterj
  read_access publiek maaiked maaiked
  read_access publiek ${admin_user} ${admin_password}
}

@test 'Check write access for share ‘publiek’' {

  write_access publiek franka franka
  write_access publiek femkevdv femkevdv
  write_access publiek hansb hansb
  write_access publiek hansb hansb
  write_access publiek taniav taniav
  write_access publiek peterj peterj
  write_access publiek maaiked maaiked
  write_access publiek ${admin_user} ${admin_password}
}


@test 'Check read access for share ‘verzekeringen’' {
  read_access verzekeringen franka franka
  read_access verzekeringen femkevdv femkevdv
  read_access verzekeringen hansb hansb
  read_access verzekeringen kimberlyvh kimberlyvh
  read_access verzekeringen taniav taniav
  read_access verzekeringen peterj peterj
  read_access verzekeringen maaiked maaiked
  read_access verzekeringen ${admin_user} ${admin_password}
}

@test 'Check write access for share ‘verzekeringen’' {
  write_access verzekeringen franka franka
  no_write_access verzekeringen femkevdv femkevdv
  write_access verzekeringen hansb hansb
  write_access verzekeringen kimberlyvh kimberlyvh
  write_access verzekeringen taniav taniav
  no_write_access verzekeringen peterj peterj
  write_access verzekeringen maaiked maaiked
  write_access verzekeringen ${admin_user} ${admin_password}
}

@test 'Check read access for share ‘financieringen’' {
  read_access financieringen franka franka
  read_access financieringen femkevdv femkevdv
  read_access financieringen hansb hansb
  read_access financieringen kimberlyvh kimberlyvh
  read_access financieringen taniav taniav
  read_access financieringen peterj peterj
  read_access financieringen maaiked maaiked
  read_access financieringen ${admin_user} ${admin_password}
}

@test 'Check write access for share ‘financieringen’' {
  write_access financieringen franka franka
  no_write_access financieringen femkevdv femkevdv
  no_write_access financieringen hansb hansb
  no_write_access financieringen kimberlyvh kimberlyvh
  no_write_access financieringen taniav taniav
  write_access financieringen peterj peterj
  write_access financieringen maaiked maaiked
  write_access financieringen ${admin_user} ${admin_password}
}

@test 'Check read access for share ‘directie’' {
  read_access directie franka franka
  read_access directie femkevdv femkevdv
  read_access directie hansb hansb
  read_access directie kimberlyvh kimberlyvh
  read_access directie taniav taniav
  read_access directie peterj peterj
  read_access directie maaiked maaiked
  read_access directie ${admin_user} ${admin_password}
}

@test 'Check write access for share ‘directie’' {
  write_access directie franka franka
  write_access directie femkevdv femkevdv
  no_write_access directie hansb hansb
  no_write_access directie kimberlyvh kimberlyvh
  no_write_access directie taniav taniav
  no_write_access directie peterj peterj
  write_access directie maaiked maaiked
  write_access directie ${admin_user} ${admin_password}
}

@test 'Check read access for share ‘staf’' {
  read_access staf franka franka
  read_access staf femkevdv femkevdv
  read_access staf hansb hansb
  read_access staf kimberlyvh kimberlyvh
  read_access staf taniav taniav
  read_access staf peterj peterj
  read_access staf maaiked maaiked
  read_access staf ${admin_user} ${admin_password}
}

@test 'Check write access for share ‘staf’' {
  write_access staf franka franka
  write_access staf femkevdv femkevdv
  no_write_access staf hansb hansb
  no_write_access staf kimberlyvh kimberlyvh
  no_write_access staf taniav taniav
  no_write_access staf peterj peterj
  write_access staf maaiked maaiked
  write_access staf ${admin_user} ${admin_password}
}

@test 'Check read access for share ‘beheer’' {
  no_read_access beheer franka franka
  no_read_access beheer femkevdv femkevdv
  no_read_access beheer hansb hansb
  no_read_access beheer kimberlyvh kimberlyvh
  no_read_access beheer taniav taniav
  no_read_access beheer peterj peterj
  read_access beheer maaiked maaiked
  read_access beheer ${admin_user} ${admin_password}
}

@test 'Check write access for share ‘beheer’' {
  no_write_access beheer franka franka
  no_write_access beheer femkevdv femkevdv
  no_write_access beheer hansb hansb
  no_write_access beheer kimberlyvh kimberlyvh
  no_write_access beheer taniav taniav
  no_write_access beheer peterj peterj
  write_access beheer maaiked maaiked
  write_access beheer ${admin_user} ${admin_password}
}
