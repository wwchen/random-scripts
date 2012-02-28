#!/bin/bash
# Used with cups
# lpstat -p to show all available printers
DIR="/home/wchen/Dropbox/Shared-with-Family/print_jobs"
MV="/bin/mv"
MKDIR="/bin/mkdir"

PRINTER_DIR="hermione"
OPTIONS_DIR="color-draft color-standard black-draft black-standard"
PRINTED_DIR="printed"

if [ ! -d "$DIR/$PRINTED_DIR" ]; then
  $MKDIR -p "$DIR/$PRINTED_DIR";
fi

shopt -s nullglob
for printer in $PRINTER_DIR; do
  for options in $OPTIONS_DIR; do
    path="$DIR/$printer/$options"
    if [ -d "$path" ]; then
      cd "$path"
      for file in $path/*; do
        if [ -f "$file" ]; then
          case $options in
            color-draft)    option="-o ColorModel=RGB -o StpQuality=Draft" ;;
            color-standard) option="-o ColorModel=RGB -o StpQuality=Standard" ;;
            black-draft)    option="-o ColorModel=Gray -o StpQuality=Draft" ;;
            black-standard) option="-o ColorModel=Gray -o StpQuality=Standard" ;;
          esac
          command="lpr -P hermione $option '$file'"
          eval $command
          $MV "$file" "$DIR/$PRINTED_DIR"
        else
          echo "$file is not a file" >&2
        fi
      done
    else
      echo "directory do not exist" >&2
      $MKDIR -p "$path"
    fi
  done
done

