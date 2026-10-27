PRG=$( basename $0 )
BOS=/usr/bin/bos
DAYS=1
LOGDATE=

HOSTS=(
tyvek
papyrus
vellum
mylar
parchment
paper
)


# ANSI escape codes for colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

err() {
  echo -e "${RED}✗ ERROR: $*${NC}" 1>&2
}

success() {
  echo -e "${GREEN}✓ $*${NC}" 1>&2
}

die() {
  err "$*"
  echo "from (${BASH_SOURCE[1]} [${BASH_LINENO[0]}] ${FUNCNAME[1]})" 1>&2
  kill 0
  exit 99
}


mk_log_filenames() {
  local _datestr _start_days
  if [[ -n "${LOGDATE}" ]] ; then
    echo "audit.log-${LOGDATE}"
  else
    let "_start_days = $DAYS - 2"
    for ((i=_start_days; i>=0; i--)); do
      _datestr=$( date -d "$i days ago" +%Y%m%d )
      echo "audit.log-${_datestr}"
    done
    echo "audit.log"
  fi
}


process_host_logs() {
  local _start _end _elapsed
  for host in "${HOSTS[@]}"; do
    for audit_fn in $( mk_log_filenames ); do
      echo "Server '${host}' logfile '${audit_fn}'" 1>&2
      _start=$SECONDS
      $BOS getlog "${host}" "${audit_fn}"
      _end=$SECONDS
      let "_elapsed = $_end - $_start"
      echo "  completed in '${_elapsed}' seconds" 1>&2
    done \
    | awk -f audit_log_unique_users_hosts.awk \
    | sed -e "s/$/ $host/"
  done
}


print_usage() {
  cat <<ENDHERE

${PRG} [OPTIONS]

OPTIONS
  -h|--help  Print this help message
  -d|--days  Number of days to report on (Example: -d 3 = today, today-1, today-2)
  -D|--date  Report on just a specific date

ENDHERE
}


assert_integer() {
  local _check _orig
  _orig="$1"
  _check=$( echo "$_orig" | tr -cd '[0-9]' )
  [[ "${#_check}" -eq "${#_orig}" ]] || die "not a valid integer '$_orig'"
}

### MAIN

ENDWHILE=0
while [[ $# -gt 0 ]] && [[ $ENDWHILE -eq 0 ]] ; do
  case $1 in
    -h|--help) print_usage; exit 1;;
    -d|--days) DAYS=$2; assert_integer $2; shift;;
    -D|--date) LOGDATE="$2"; assert_integer $2; shift;;
    --) ENDWHILE=1;;
    -*) echo "Invalid option '$1'"; exit 1;;
     *) ENDWHILE=1; break;;
  esac
  shift
done

output_format="%10s %15s %48s %5d %19s %s\n"
process_host_logs \
| sort -k 1,1 -k 4,4 \
| while read -r user ip count date server; do
    client=$( dig -x "${ip}" +short )
    [[ -z "${client}" ]] && client='--unknown--'
    printf "$output_format" "$user" "$ip" "$client" "$count" "$date" "$server"
  done
echo "Completed full run in '$SECONDS' seconds" 1>&2
