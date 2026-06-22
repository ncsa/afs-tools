#!/usr/bin/bash

# from svcplan-8540
# rxdebug -servers parchment -port 7000 -all | grep host | cut -f4 -d" " | sort | uniq | sed -e "s/,//g" | xargs -n 1 -iblah getent hosts blah
#

PRG=$( basename $0 )
OUTPUT_FN="${PRG}".out
ERRORS_FN="${PRG}".err
SUMMARY_FN="${PRG}".summary

SERVERS=( cotton mylar paper parchment papyrus tyvek vellum )
PORTS=( 7000 7002 7003 7005 )
# queries to these host&port combos return nothing and take 30 seconds to
# timeout
HOST_PORT_SKIPS=(
  cotton:7000
  cotton:7002
  cotton:7003
  cotton:7005
  mylar:7002
  mylar:7003
  paper:7002
  paper:7003
  parchment:7002
  parchment:7003
  papyrus:7002
  papyrus:7003
  tyvek:7002
  tyvek:7003
  vellum:7002
  vellum:7003
)

do_scans() {
  for server in "${SERVERS[@]}" ; do
    for port in "${PORTS[@]}" ; do
      server_port="${server}:${port}"
      echo "SERVER $server_port"
      # skip known bad host + port combos
      if [[ " ${HOST_PORT_SKIPS[@]} " =~ " ${server_port} " ]]; then
        echo "SKIPPING ${server_port}"
      else
        rxdebug -servers "${server}" -port "${port}" -all
      fi
    done
  done \
  | tee "${OUTPUT_FN}"
}


check_errors() {
  grep -B2 -F 'getstats call failed' "${OUTPUT_FN}" > "${ERRORS_FN}"
}

mk_summary() {
  grep 'host' "${OUTPUT_FN}" \
  | cut -d' ' -f4 \
  | cut -d, -f1 \
  | sort -u \
  | xargs -n 1 -iblah getent hosts blah \
  | tee "${SUMMARY_FN}"
}


print_summary() {
  echo
  echo "Raw output in: '${OUTPUT_FN}'"
  echo "Errors in: '${ERRORS_FN}'"
  echo "Client summary in: '${SUMMARY_FN}'"
}


###
# MAIN
###

do_scans

check_errors

mk_summary

print_summary
