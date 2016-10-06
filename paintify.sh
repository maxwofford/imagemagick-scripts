#!/bin/bash

applyFilterTo () {
  # Create a temp workspace and bring our image there as a PNG
  dir=$(mktemp -d)
  name=${file%.*}
  convert "$1" "${dir}/${name}.png"

  convert "${dir}/${name}.png" -mean-shift 25x25+10% "${dir}/${name}_output.png"

  # Bring our result out of the temp workspace
  convert "${dir}/${name}_output.png" "$1"
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
