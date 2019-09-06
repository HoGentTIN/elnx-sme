#! /usr/bin/env bats
#
# Acceptance test for the DNS server for linuxlab.lan

sut_ip=172.16.192.1
domain=avalon.lan

#{{{ Helper functions

# Usage: assert_forward_lookup NAME IP
# Exits with status 0 if NAME.DOMAIN resolves to IP, a nonzero
# status otherwise
assert_forward_lookup() {
  local name="$1"
  local ip="$2"

  [ "$ip" = "$(dig @${sut_ip} "${name}.${domain}" +short)" ]
}

# Usage: assert_reverse_lookup NAME IP
# Exits with status 0 if a reverse lookup on IP resolves to NAME,
# a nonzero status otherwise
assert_reverse_lookup() {
  local name="$1"
  local ip="$2"
  local result
  result=$(dig @${sut_ip} -x "${ip}" +short)

  [ "${name}.${domain}." = "${result}" ]
}

# Usage: assert_alias_lookup ALIAS NAME IP
# Exits with status 0 if a forward lookup on NAME resolves to the
# host name NAME.DOMAIN and to IP, a nonzero status otherwise
assert_alias_lookup() {
  local alias="$1"
  local name="$2"
  local ip="$3"
  local result
  result=$(dig @${sut_ip} "${alias}.${domain}" +short)

  echo "${result}" | grep "${name}\.${domain}\."
  echo "${result}" | grep "${ip}"
}

# Usage: assert_ns_lookup NS_NAME...
# Exits with status 0 if all specified host names occur in the list of
# name servers for the domain.
assert_ns_lookup() {
  local result
  result=$(dig @${sut_ip} ${domain} NS +short)

  [ -n "${result}" ] # the list of name servers should not be empty
  while (( "$#" )); do
    echo "${result}" | grep "$1\.${domain}\."
    shift
  done
}

# Usage: assert_mx_lookup PREF1 NAME1 PREF2 NAME2...
#   e.g. assert_mx_lookup 10 mailsrv1 20 mailsrv2
# Exits with status 0 if all specified host names occur in the list of
# mail servers for the domain.
assert_mx_lookup() {
  local result
  result=$(dig @${sut_ip} ${domain} MX +short)

  [ -n "${result}" ] # the list of name servers should not be empty
  while (( "$#" )); do
    echo "${result}" | grep "$1 $2\.${domain}\."
    shift
    shift
  done
}

#}}}

@test 'The dig command should be installed' {
  which dig
}

@test 'The main config file should be syntactically correct' {
  named-checkconf /etc/named.conf
}

@test 'The forward zone file should be syntactically correct' {
  # It is assumed that the name of the zone file is the name of the zone
  # itself (without extra extension)
  named-checkzone ${domain} /var/named/${domain}
}

@test 'The reverse zone files should be syntactically correct' {
  # It is assumed that the name of the zone file is the name of the zone
  # itself (without extra extension)
  for zone_file in /var/named/*.in-addr.arpa; do
    reverse_zone=${zone_file##*/}
    named-checkzone ${reverse_zone} ${zone_file}
  done
}

@test 'The service should be running' {
  systemctl status named
}

@test 'Forward lookups public servers' {
  #                     host name  IP
  assert_forward_lookup pu001      192.0.2.10
  assert_forward_lookup pu002      192.0.2.20
}

@test 'Forward lookups private servers' {
  #                     host name  IP
  assert_forward_lookup pr001      172.16.192.1
  assert_forward_lookup pr002      172.16.192.2
  assert_forward_lookup pr003      172.16.192.3
  assert_forward_lookup pr004      172.16.192.4
  assert_forward_lookup pr010      172.16.192.10
  assert_forward_lookup pr011      172.16.192.11
}

@test 'Reverse lookups public servers' {
  #                     host name  IP
  assert_reverse_lookup pu001      192.0.2.10
  assert_reverse_lookup pu002      192.0.2.20
}

@test 'Reverse lookups private servers' {
  #                     host name  IP
  assert_reverse_lookup pr001      172.16.192.1
  assert_reverse_lookup pr002      172.16.192.2
  assert_reverse_lookup pr003      172.16.192.3
  assert_reverse_lookup pr004      172.16.192.4
  assert_reverse_lookup pr010      172.16.192.10
  assert_reverse_lookup pr011      172.16.192.11
}

@test 'Alias lookups public servers' {
  #                   alias      hostname  IP
  assert_alias_lookup www        pu001      192.0.2.10
  assert_alias_lookup mail       pu002      192.0.2.20
}

@test 'Alias lookups private servers' {
  #                   alias      hostname  IP
  assert_alias_lookup ns1        pr001      172.16.192.1
  assert_alias_lookup ns2        pr002      172.16.192.2
  assert_alias_lookup dhcp       pr003      172.16.192.3
  assert_alias_lookup directory  pr004      172.16.192.4
  assert_alias_lookup inside     pr010      172.16.192.10
  assert_alias_lookup files      pr011      172.16.192.11
}

@test 'NS record lookup' {
  assert_ns_lookup pr001 pr002
}

@test 'Mail server lookup' {
  assert_mx_lookup 10 pu002
}
