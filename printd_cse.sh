#!/bin/bash
# lpstat -p to show all available printers
DIR="/Users/wchen/Dropbox/print_jobs"
SSH_DST="wchen16@unix.cs.tamu.edu"

PRINTER_DIR="p111j p2"
DUPLEX_DIR="single-sided two-sided-long-edge"
PRINTED_DIR="printed"

shopt -s nullglob
for printer in $PRINTER_DIR; do
  for duplex in $DUPLEX_DIR; do
    path="$DIR/$printer/$duplex"
    if [ -d "$path" ]; then
      cd "$path"
      for file in $path/*; do
        if [ -f "$file" ]; then
          filename=`basename "$file"`
          command="/opt/csw/bin/lpr -P $printer -o sides=$duplex '$filename'" #;/opt/csw/gnu/rm $file"
          scp "$file" $SSH_DST:to_print/
          ssh $SSH_DST "cd to_print;$command"
          mv "$file" $DIR/$PRINTED_DIR
        else
          echo "$file is not a file" >&2
        fi
      done
    else
      echo "directory do not exist" >&2
      mkdir -p "$path"
    fi
  done
done

