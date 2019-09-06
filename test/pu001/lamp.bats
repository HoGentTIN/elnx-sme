#! /usr/bin/env bats
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Acceptance test script for a LAMP stack with Wordpress

#{{{ Helper Functions


#}}}
#{{{ Variables
sut=192.0.2.50
mariadb_root_password=fogMeHud8
wordpress_database=wp_db
wordpress_user=wp_user
wordpress_password=CorkIgWac
#}}}

# Test cases

@test 'The necessary packages should be installed' {
  rpm -q httpd
  rpm -q MariaDB-server
  rpm -q wordpress
  rpm -q php
  rpm -q php-mysql
}

@test 'The Apache service should be running' {
  systemctl status httpd.service
}

@test 'The Apache service should be started at boot' {
  systemctl is-enabled httpd.service
}

@test 'The MariaDB service should be running' {
  systemctl status mariadb.service
}

@test 'The MariaDB service should be started at boot' {
  systemctl is-enabled mariadb.service
}

@test 'The SELinux status should be ‘enforcing’' {
  [ -n "$(sestatus) | grep 'enforcing'" ]
}

@test 'Web traffic should pass through the firewall' {
  firewall-cmd --list-all | grep 'services.*http\b'
  firewall-cmd --list-all | grep 'services.*https\b'
}

@test 'Mariadb should have a database for Wordpress' {
  mysql -uroot -p${mariadb_root_password} --execute 'show tables' ${wordpress_database}
}

@test 'The MariaDB user should have "write access" to the database' {
  mysql -u${wordpress_user} -p${wordpress_password} \
    --execute 'CREATE TABLE a (id int); DROP TABLE a;' \
    ${wordpress_database}
}

@test 'The website should be accessible through HTTP' {
  # First check whether port 80 is open
  [ -n "$(ss -tln | grep '\b80\b')" ]

  # Fetch the main page (/) with Curl/
  #  - If the site is not up, curl will exit with an error and the test will fail
  #  - If the site is up, but the index page cannot be found, ${result} will be nonempty
  run curl --silent "http://${sut}/"
  [ -z "$(echo ${output} | grep 404)" ]
}

@test 'The website should be accessible through HTTPS' {
  # We're just checking if port 443 is open here. If HTTP runs and serves pages, HTTPS should as well
  # We check the open TCP server ports with ss and check if port 443 is listed.
  [ -n "$(ss -tln | grep '\b443\b')" ]
}

@test 'The certificate should not be the default one' {
  # Fetch the server certificate
  run openssl s_client -showcerts -connect ${sut}:443 < /dev/null

  [ "0" -eq "${status}" ]

  # The default certificate for Apache has "SomeOrganization" as the organization
  # So grepping it in the output of the openssl command should return an empty string
  # if a self-signed certificate was installed by the administrator.
  [ -z "$(echo ${output} | grep SomeOrganization)" ]
}

@test "The Wordpress install page should be visible under http://${sut}/wordpress/" {
  [ -n "$(curl --silent --location http://${sut}/wordpress/ | grep '<title>WordPress')" ]
}

@test 'MariaDB should not have a test database' {
  run mysql -uroot -p${mariadb_root_password} --execute 'show tables' test
  [ "0" -ne "${status}" ]
}

@test 'MariaDB should not have anonymous users' {
  result=$(mysql -uroot -p${mariadb_root_password} --execute "select * from user where user='';" mysql)
  [ -z "${result}" ]
}
