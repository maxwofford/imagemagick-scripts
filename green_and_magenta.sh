#!/bin/bash

aberrate () {
  width=$(convert "$1" -print "%w" /dev/null)
  height=$(convert "$1" -print "%h" /dev/null)

  # Channel shifts
  mx=$(($width / -120))
  my=$(($height / -150))
  gx=$(($width / 200))
  gy=$(($height / 250))
  convert "$1" -virtual-pixel edge -channel M -fx "p[$mx,$my]" -channel G -fx "p[$gx, $gy]" "$1"
}

desaturate () {
  convert "$1" -modulate 100,35,100 -level 150 -sigmoidal-contrast 2x50%% "$1"
}

applyFilterTo () {
  # Create a temp workspace and bring our image there as a PNG
  dir=$(mktemp -d)
  name=${file%.*}
  convert "$1" "${dir}/${name}.png"

  desaturate "${dir}/${name}.png"
  aberrate "${dir}/${name}.png"

  convert "${dir}/${name}.png" "$1"
  rm -rf "${dir}"
}

main () {
  echo -n "This will overwrite the source images. Continue? (Y/N)"
  read resp
  if echo "$resp" | grep -iq "^y" ; then
    for file in "$@"
    do
      echo -n "Converting ${file}... "
      applyFilterTo "$file"
      echo "done"
    done
  elif echo "$resp" | grep -iq "^n" ; then
    return 0
  else
    echo "Command not recognized. Trying again."
    main "$@"
  fi
}

main "$@"
