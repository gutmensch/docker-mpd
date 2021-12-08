function check_decoder() {
  echo testing for decoder $1
  res="$(mpd -V | grep $1)"
  if [[ $res =~ $1.*$2.* ]]; then
    return 0
  else
    return 1
  fi
}
