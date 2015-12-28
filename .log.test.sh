#! /bin/bash

#---------------------------#
# Test file for file_exists #
#---------------------------#


#---------#
# Imports #
#---------#

if [ -z "${IMPORT_SRC+x}" ]; then
  source "${LIBRARY_FXNS}/import"
fi
import "log"
import "test_utils"


#-------------#
# Begin tests #
#-------------#

tu_init

test1 () {
  touch .delme
  rm -f "${__log_conf}"

  log_print_stdout_level 2>/dev/null 1>.delme
  if [ "$(cat .delme)" != "Current stdout log level: ${__log_res}" ]; then
    exit 1
  fi

  rm -f .delme
  rm -f "${__log_conf}"
}

tu_assert_success "test1" \
"log_print_stdout_level" \
"prints default"

test2 () {
  rm -f "${__log_conf}"
  log_set_stdout_level 1
  __log_get_stdout_level
  if [ "${__log_res}" != 1 ]; then
    exit 1
  fi

  log_set_stdout_level 5
  __log_get_stdout_level
  if [ "${__log_res}" != 5 ]; then
    exit 1
  fi
  rm -f "${__log_conf}"
}

tu_assert_success "test2" \
"log_set_stdout_level" \
"sets to 1 from no file then 5 with existing file"

test3() {
  printf "${__log_stdout_name}=1\n" >"${__log_conf}"

  local msg="this is my log"
  log 1 "${msg}" >.delme
  if [ "$(cat .delme)" != "${__log_trace}: ${msg}" ]; then
    rm -f .delme
    exit 1
  fi

  printf "${__log_stdout_name}=3\n" >"${__log_conf}"
  msg="this is my log"
  log 3 "${msg}" >.delme
  if [ "$(cat .delme)" != "${__log_info}: ${msg}" ]; then
    rm -f .delme
    exit 1
  fi

  printf "${__log_stdout_name}=3\n" >"${__log_conf}"
  msg="this is my error"
  log 5 "${msg}" 2>.delme
  if [ "$(cat .delme)" != "${__log_error}: ${msg}" ]; then
    rm -f .delme
    exit 1
  fi

  rm -f .delme
}

tu_assert_success "test3" \
"log" \
"log levels 1, 3 and 5"

test4 () {
  log_fatal "this is my fatal" 20
}

tu_assert_errno "test4" \
"20" \
"log_fatal" \
"testing fatal errno" \

test5 () {
  local msg="this is my fatal"
  $(log_fatal "${msg}" &>.delme)
  local myLog="$(cat .delme)"
  if [ "${myLog##${__log_fatal}: ${msg}*}" ]; then
    exit 1
  fi
}

tu_assert_success "test5" \
"log_fatal" \
"testing fatal stderr"

tu_finalize
