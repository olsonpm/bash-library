#! /usr/bin/env sh


#---------#
# Imports #
#---------#

if [ -z "${IMPORT_SRC+x}" ]; then
  . "$( cd "$( dirname "${0}" )" && pwd )/import.sh"
fi
import config-utils
import test-utils


#------------#
# Init tests #
#------------#

not_exist=".config_utils_noexist"
rm -f "${not_exist}"

does_exist=".config_utils_exist"
echo "" > "${does_exist}"

conf=".config_utils_conf"


#-------------#
# Begin tests #
#-------------#

tu_init

test1 () {
  echo "" > "${conf}"
  (cu_set_name_value "myname" "myvalue" "${conf}" >/dev/null 2>&1)
  if [ ! -f "${conf}" ]; then
    exit 1
    elif [ "$(grep -c "myname=" "${conf}")" != "1" ]; then
    exit 1
    elif [ "$(grep -c "=myvalue" "${conf}")" != "1" ]; then
    exit 1
  fi
  echo "" > "${conf}"
}

test2 () {
  printf "myname=myoldval\n" > "${conf}"
  (cu_set_name_value "myname" "myvalue" "${conf}" >/dev/null 2>&1)
  if [ ! -f "${conf}" ]; then
    exit 1
    elif [ "$(grep -c "myname=" "${conf}")" != "1" ]; then
    exit 1
    elif [ "$(grep -c "=myvalue" "${conf}")" != "1" ]; then
    exit 1
  fi
  echo "" > "${conf}"
}

test3_1 () {
  cu_set_name_value "" "myvalue" "${conf}"
}
test3 () {
  tu_assert_errno_nr "test3_1" \
  "${__cu_inv_name}" \
  
  tu_assert_errno_nr "cu_set_name_value myname" \
  "${__cu_val_not_given}"
  
  tu_assert_errno_nr "cu_set_name_value myname myvalue" \
  "${__cu_need_opt_file}"
  
  tu_assert_errno_nr "cu_set_name_value myname myvalue ${not_exist}" \
  "${__cu_inv_opt_file}"
}

tu_assert_success "test1" \
"cu_set_name_value" \
"name and value are set on new conf"

tu_assert_success "test2" \
"cu_set_name_value" \
"name and value are set on existing conf"

tu_assert_success "test3" \
"cu_set_name_value" \
"test all errors"

test4 () {
  printf "myname=myvalue\n" > "${conf}"
  cu_get_value "myname" "file=${conf}"
  if [ "${config_utils_result}" != "myvalue" ]; then
    exit 1
  fi
  echo "" > "${conf}"
}

test5 () {
  printf "myname=myvalue\n" > "${conf}"
  
  tu_assert_errno_nr "cu_get_value myname" \
  "${__cu_need_opt_file}"
  
  tu_assert_errno_nr "cu_get_value myname file=" \
  "${__cu_need_opt_file}"
  
  tu_assert_errno_nr "cu_get_value myname file=${not_exist}" \
  "${__cu_inv_opt_file}"
  
  tu_assert_errno_nr "cu_get_value myname file=${conf} a=d" \
  "${__cu_inv_argument}"
  
  tu_assert_errno_nr "cu_get_value myname file=${conf} throw-error=a" \
  "${__cu_inv_throw}"
  
  tu_assert_errno_nr "cu_get_value mybadname file=${conf} throw-error=true" \
  "${__cu_name_not_found}"
  
  echo "" > "${conf}"
}

tu_assert_success "test4" \
"cu_get_value" \
"gets value"

tu_assert_success "test5" \
"cu_get_value" \
"test all errors"

test6 () {
  printf "myname=myvalue\n" > "${conf}"
  
  (cu_remove_name "myname" "${conf}") >/dev/null 2>&1
  if [ "${?}" != "0" ] && [ "$(grep -c myname "${conf}")" != 0 ]; then
    exit 1
  fi
  
  echo "" > "${conf}"
}

tu_assert_success "test6" \
"cu_remove_name" \
"name removed"

test7 () {
  cu_set_persistent_file "${conf}"
  if [ "${cu_persistent_file}" != "$(realpath "${conf}")" ]; then
    exit 1
  fi
  cu_persistent_file=
}

test8 () {
  (cu_set_persistent_file) >/dev/null 2>&1
  if [ "${?}" != "${__cu_file_not_provided}" ]; then
    exit 1
  fi
  (cu_set_persistent_file "${not_exist}") >/dev/null 2>&1
  if [ "${?}" != "${__cu_file_not_exist}" ]; then
    exit 1
  fi
}

tu_assert_success "test7" \
"cu_set_persistent_file" \
"setting file"

tu_assert_success "test8" \
"cu_set_persistent_file" \
"test all errors"

tu_finalize

#----------#
# Clean up #
#----------#

rm -f "${not_exist}" "${does_exist}" "${conf}"
