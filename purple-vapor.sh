#!/bin/bash

balance () {
  convert "$1" -normalize -auto-gamma "$1"
}

applyFilterTo () {
  # Create a temp workspace and bring our image there as a PNG
  dir=$(mktemp -d)
  name=${file%.*}
  convert "$1" "${dir}/${name}.png"

  # Balance out the gamma
  balance "${dir}/${name}.png"

  # Create a layer made of all the non-black non-alpha values
  convert "${dir}/${name}.png" -alpha On "${dir}/${name}.png" -compose CopyOpacity -composite -colorspace Gray "${dir}/${name}_white.png"

  # Create a layer for our background
  convert "${dir}/${name}.png" -fill "#180348" -draw "color 0,0 reset" "${dir}/${name}_background.jpg"

  # Compose the layers together
  composite "${dir}/${name}_white.png" "${dir}/${name}_background.jpg" -compose ColorDodge "${dir}/${name}_output.png"

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
