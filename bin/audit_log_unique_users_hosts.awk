/CODE 0 NAME [^ ]+ HOST [0-9.]+/ {
  k=$12" "$14
  month=(index("JanFebMarAprMayJunJulAugSepOctNovDec", $2) + 2) / 3
  count[k]++
  last[k]=$5"-"month"-"$3"_"$4
}
END {
  for (k in count) {
    i = index(k, " ")
    user = substr(k, 1, i - 1)
    ip = substr(k, i + 1)
    printf "%10s %15s %5d %s\n", user, ip, count[k], last[k]
  }
}
