#!/bin/bash

applyFilterTo () {
  # Create a temp workspace and bring our image there as a PNG
  dir=$(mktemp -d)
  name=${file%.*}
  convert "$1" "${dir}/${name}.png"

  if [ $((RANDOM & 1)) == 1 ]; then
    # These are true scanlines -- every other line is blacked out
    convert "${dir}/${name}.png" -modulate 125,150 -fx 'xx=j&1?p{i, j}:black; xx' "${dir}/${name}_output.png"
  else
    # This uses the value of the first pixel in the row
    convert "${dir}/${name}.png" -fx 'xx=j&1?i:0; p{xx, j}' "${dir}/${name}_output.png"
  fi

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

