#! /bin/bash

#-----------------------------------------------------#
# This file is intended to be included within scripts #
#-----------------------------------------------------#


#------#
# Init #
#------#

TEST_UTILS_SRC=
#log 1 "entering test_utils"


#-----#
# API #
#-----#

#-------------------------------
#
# Function: tu_assert_success <call> <function name> <test description>
#
# Arguments:
#   <call> - Call to be evaluated for error numbers.
#   <function name> - Name of the function to be tested.
#   <test description> - Description of what's being tested.  Keep it small.
#
# Description: This function will print to stdout either 'success' if the call returns 0, or 'failure'
#                if the call returns an exit code between 1 and 255.  After, it will "pretty print"
#                <function name> followed by <test description>.
#
#-------------------------------
#
# Function: tu_assert_error <call> <function name> <test description>
#
# Parameters:
#   <call> - Call to be evaluated for error numbers.
#   <function name> - Name of the function to be tested.
#   <test description> - Description of what's being tested.  Keep it small.
#
# Description: This function will print to stdout either 'success' if the call returns an exit code
#                between 1 and 255, or 'failure' if the call returns an exit code of 0.  After, it will
#                "pretty print" <function name> followed by <test description>.
#
#-------------------------------
#
# Function: tu_assert_errno <call> <error number> <function name> <test description>
#
# Parameters:
#   <call> - Call to be evaluated for error numbers.
#   <error number> - Error number between 1 and 255
#   <function name> - Name of the function to be tested.
#   <test description> - Description of what's being tested.  Keep it small.
#
# Description: This function will print to stdout either 'success' if the call returns the exit code
#                specified, or 'failure' if the call returns any other exit code.  After, it will
#                "pretty print" <function name> followed by <test description>.
#
#-------------------------------
#
# Function: tu_assert_errno_nr <call> <error number>
#
# Parameters:
#   <call> - Call to be evaluated for error numbers.
#   <error number> - Error number between 1 and 255.
#
# Description: This function is postfixed "nr" for "no report".  It is meant to be used as a helper
#                function to quickly determine whether specific errors are being returned.  For instance,
#                you might 'assert success' a test that goes through all the possible errors
#                in the tested function.  Please see the example section for clarification.
#
# Example:
#
# testErrors () {
#   tu_assert_errno_nr "myAPI causeErr1" 1
#   tu_assert_errno_nr "myAPI causeErr2" 2
# }
#
# tu_assert_success "testErrors" "myAPI" "test all errors"
#
#-------------------------------


#------------------#
# Script Variables #
#------------------#

__tu_total_tests=
__tu_total_failures=
__tu_total_successes=
__test_utils_res=


#-----------#
# Functions #
#-----------#

tu_init () {
  __tu_print_headers
  __tu_total_tests=0
  __tu_total_successes=0
  __tu_total_failures=0
}

tu_finalize () {
  printf "\n# Tests: ${__tu_total_tests}\n"
  printf "# Successes: ${__tu_total_successes}\n"
  printf "# Failures: ${__tu_total_failures}\n\n"
  __tu_total_tests=""
  __tu_total_successes=""
  __tu_total_failures=""
}

tu_assert_success () {
  __tu_validate_call "${1}"
  local call="${__test_utils_res}"
  
  __tu_validate_function_name "${2}"
  local fxnName="${__test_utils_res}"
  
  __tu_validate_test_description "${3}"
  local tstDesc="${__test_utils_res}"
  
  
  #if (${call}); then
  if (${call} &>/dev/null); then
    __tu_pretty_print_test "success" "${fxnName}" "${tstDesc}"
    __tu_increment_successes
  else
    __tu_pretty_print_test "failed " "${fxnName}" "${tstDesc}"
    __tu_increment_failures
  fi
}

tu_assert_error () {
  __tu_validate_call "${1}"
  local call="${__test_utils_res}"
  
  __tu_validate_function_name "${2}"
  local fxnName="${__test_utils_res}"
  
  __tu_validate_test_description "${3}"
  local tstDesc="${__test_utils_res}"
  
  #if ! (${call}); then
  if ! (${call} &>/dev/null); then
    __tu_pretty_print_test "success" "${fxnName}" "${tstDesc}"
    __tu_increment_successes
  else
    __tu_pretty_print_test "failed " "${fxnName}" "${tstDesc}"
    __tu_increment_failures
  fi
}

tu_assert_errno () {
  __tu_validate_call "${1}"
  local call="${__test_utils_res}"
  
  __tu_validate_errno "${2}"
  local errno="${__test_utils_res}"
  
  __tu_validate_function_name "${3}"
  local fxnName="${__test_utils_res}"
  
  __tu_validate_test_description "${4}"
  local tstDesc="${__test_utils_res}"
  
  (${call} &>/dev/null)
  #(${call})
  if [ "${?}" = "${errno}" ]; then
    __tu_pretty_print_test "success" "${fxnName}" "${tstDesc}"
    __tu_increment_successes
  else
    __tu_pretty_print_test "failed " "${fxnName}" "${tstDesc}"
    __tu_increment_failures
  fi
}

tu_assert_errno_nr () {
  __tu_validate_call "${1}"
  local call="${__test_utils_res}"
  
  __tu_validate_errno "${2}"
  local errno="${__test_utils_res}"
  
  (${call} &>/dev/null)
  #(${call})
  if [ "${?}" != "${errno}" ]; then
    exit 1
  fi
}


#------------------#
# Helper Functions #
#------------------#

__tu_validate_call () {
  if [ "${1}" = "" ]; then
    #log 6 "<call> wasn't provided"
    printf "<call> wasn't provided\n"
    exit 1
  fi
  __test_utils_res="${1}"
}

__tu_validate_errno () {
  if [ "${1}" = "" ]; then
    #log 6 "<error number> wasn't provided"
    printf "<error number> wasn't provided\n"
    exit 1
  fi
  if [ "${1}" -lt 1 ] || [ "${1}" -gt 255 ]; then
    #log 6 "<error number> '${1}' is invalid.  Must be between 1 and 255"
    printf "<error number> '${1}' is invalid.  Must be between 1 and 255\n"
    exit 1
  fi
  __test_utils_res="${1}"
}

__tu_validate_function_name () {
  if [ "${1}" = "" ]; then
    #log 6 "<function name> wasn't provided"
    printf "<function name> wasn't provided\n"
    exit 1
  fi
  __test_utils_res="${1}"
}

__tu_validate_test_description () {
  if [ "${1}" = "" ]; then
    #log 6 "<test description> wasn't provided"
    printf "<test description> wasn't provided\n"
    exit 1
  fi
  __test_utils_res="${1}"
}

__tu_print_headers () {
  printf "\nStatus      Function Name                 Test Description\n"
  printf -- "------      -------------                 ----------------\n"
}

__tu_pretty_print_test () {
  local result="${1}"
  local fxnName="${2}"
  local tstDesc="${3}"
  
  printf "${result}" >&1
  if [ "${#fxnName}" -gt 30 ]; then
    # indent four spaces
    printf "\n    function:    ${fxnName}" >&1
    printf "\n    description: ${tstDesc}\n" >&1
  else
    printf "     ${fxnName}" >&1
    local descIndent=$(( 30 - ${#fxnName} ))
    printf "%0.s " $(seq 1 ${descIndent}) >&1
    printf "${tstDesc}\n" >&1
  fi
}

__tu_increment_successes () {
  if [ ! "${__tu_total_tests}" = "" ]; then
    __tu_total_tests=$(( __tu_total_tests+=1 ))
    __tu_total_successes=$(( __tu_total_successes+=1 ))
  fi
}

__tu_increment_failures () {
  if [ ! "${__tu_total_tests}" = "" ]; then
    __tu_total_tests=$(( __tu_total_tests+=1 ))
    __tu_total_failures=$(( __tu_total_failures+=1 ))
  fi
}