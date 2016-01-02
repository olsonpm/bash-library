#! /usr/bin/env sh


#---------#
# Imports #
#---------#

currentDir="$( cd "$( dirname "${0}" )" && pwd )"
if [ -z "${IMPORT_SRC+x}" ]; then
  . "${currentDir}/import.sh"
fi
import file-exists
import test-utils


#------#
# Init #
#------#

testFile="${currentDir}/.file_exists.test"
touch "${testFile}"
tu_init


#------#
# Main #
#------#

tu_assert_success "file_exists ./.file_exists.test" "file_exists" "file does exist"
tu_assert_errno "file_exists ./.file_exists.nothere" \
"2" \
"file_exists" \
"file does not exist"

tu_assert_errno "file_exists" \
"3" \
"file_exists" \
"no arguments"

tu_finalize


#---------#
# Cleanup #
#---------#

rm "${testFile}"
