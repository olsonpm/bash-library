#! /usr/bin/env sh


string_in_res=
string_in () {
  str="${1}"
  arr=${2}
  found=0
  set -f
  for element in ${arr}; do
    if [ "${str}" = "${element}" ]; then
      found=1
      break
    fi
  done
  set +f
  
  string_in_res=${found}
}
