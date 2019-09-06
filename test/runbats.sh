#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Run BATS test files in the current directory, and the ones in the subdirectory
# matching the host name.
#
# The script installs BATS if needed. It's best to put ${bats_install_dir} in
# your .gitignore.

set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable

#{{{ Variables

test_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bats_version="1.1.0"
bats_archive="v${bats_version}.tar.gz"
bats_url="https://github.com/bats-core/bats-core/archive/${bats_archive}"
bats_install_dir="/usr/local"
bats="${bats_install_dir}/bin/bats"

test_file_pattern="*.bats"

# color definitions
blue='\e[0;34m'
yellow='\e[0;33m'
reset='\e[0m'

#}}}
#{{{ Functions

# Predicate that checks whether BATS is installed
is_bats_installed() {
  test -f "${bats}"
}

# Usage: install_bats_if_needed
install_bats_if_needed() {
  if ! is_bats_installed; then
    echo -e "${blue}Installing BATS${reset}"
    cd /tmp
    wget "${bats_url}"
    tar xf "${bats_archive}"
    (
      cd "./bats-core-${bats_version}/"
      ./install.sh "${bats_install_dir}"
    )
    rm "${bats_archive}"
    rm -r "/tmp/bats-core-${bats_version}"
  fi
}

# find_tests DIR [MAX_DEPTH]
find_tests() {
  local max_depth=""
  if [ "$#" -eq "2" ]; then
    max_depth="-maxdepth $2"
  fi

  local tests
  
  tests=$(find "$1" ${max_depth} -type f -name "${test_file_pattern}" -printf '%p\n' 2> /dev/null)
  
  echo "${tests}"
}
#}}}
# Script proper

install_bats_if_needed

# List all test cases (i.e. files in the test dir matching the test file
# pattern)

# Tests to be run on all hosts
global_tests=$(find_tests "${test_dir}" 1)

# Tests for individual hosts
host_tests=$(find_tests "${test_dir}/${HOSTNAME}")

# Loop over test files
for test_suite in ${global_tests} ${host_tests}; do
  echo -e "${blue}Running test ${yellow}${test_suite}${reset}"
  ${bats} "${test_suite}"
done
