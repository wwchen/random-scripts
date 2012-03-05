#!/bin/bash
# tv show filenames are usually in this format:
# <tv.show.name>.<season>.HDTV.<singature>.avi
# where <tv.show> is the show name
#       <season> follows SXXEXX format
#       <signature> is a string we don't care about
#
# With this script, we want to organize these episodes into:
# <tv show>/Season X/<tv show> <season> - <name>.avi
# where <name> is the episode name (grabbed from some API)

shopt -s nullglob

file_extensions=(avi mkv mp4)
dir=`pwd`

dry_mode=1
RENAME="/usr/bin/rename"
perl_regex="([\w.]*?)\.(S\d{1,2}E\d{1,2})(.*?)\.hdtv.*"

function execute {
  echo "#> $1"
  if [[ $dry_mode == 0 ]]; then
    eval "$1"
  fi
}

function manpage {
  echo "Usage: `basename $0` [-y]"
  echo "  Renames *.${file_extensions[@]} files in $dir folder with this regex pattern ($perl_regex) and moves them into folders"
  exit 1
}

while getopts "yh" opt; do
  case $opt in
    y) dry_mode=0 ;;
    h) manpage ;;
  esac
done

if [[ $dry_mode == 1 ]]; then
  echo -e "**\n** This is a dry run **\n**\n"
  RENAME=$RENAME" -n"
fi

# get all the avi files at root dir
#$RENAME 's|([\w.]*?)\.(S\d{1,2}E\d{1,2}).*|$1 - $2|;s|\.| |g' *.$file_extension
#alias rntv='for i in *.avi; do mv $i "$( echo $i | sed -e 's/\.[hH][dD][tT][vV].*$//' -e 's/\./ /g' -e 's/$/.avi/')"; done'
for file_extension in ${file_extensions[@]}; do
  #find . -maxdepth 1 -iname "*.$file_extension" -print0 | while read -d $'\0' file
  while IFS= read -r -d $'\0' file; do
    orig_filename=`basename "$file"`
    showname=`echo "$orig_filename" | perl -pe "s|$perl_regex|\1|i; s|\.| |g"`
    episode=` echo "$orig_filename" | perl -pe "s|$perl_regex|\2|i"`
    eptitle=` echo "$orig_filename" | perl -pe "s|$perl_regex|\3|i; s|\.\d*p$||; s|\.| |g; s|^\s*(.*)\s$|\1|"`
    season=`  echo "$episode"  | perl -pe "s|S(\d{1,2}).*|\1|i; s|^0||"` # don't know why, the .* is essential

    # echo showname $showname
    # echo episode $episode
    # echo eptitle $eptitle
  
    path="$dir/$showname/Season $season"
    new_filename="$showname - $episode"
    if [[ -n $eptitle ]]; then
      new_filename="$new_filename - $eptitle"
    fi
    new_filename="$new_filename".$file_extension

    if [[ ! -d "$path" ]]; then
      mkdir_cmds+=("$path")
    fi
    mv_src_cmds+=("$orig_filename")
    mv_dst_cmds+=("$path/$new_filename")
  done < <(find . -maxdepth 1 -iname "*.$file_extension" -print0)
done

OLDIFS="$IFS"
IFS=$'\n'
mkdir_cmds=(`for i in "${mkdir_cmds[@]}"; do echo $i; done | sort -u | uniq`)
IFS="$OLDIFS"

for i in `seq 0 ${#mkdir_cmds[@]}`; do
  if [[ -n ${mkdir_cmds[$i]} ]]; then
    execute "mkdir -p \"${mkdir_cmds[$i]}\""
  fi
done

for i in `seq 0 ${#mv_src_cmds[@]}`; do
  if [[ -n ${mv_src_cmds[$i]} && -n ${mv_dst_cmds[$i]} ]]; then
    execute "mv \"${mv_src_cmds[$i]}\"	 \"${mv_dst_cmds[$i]}\""
  fi
done



# delete years after the show title if there is one
# convert all the dots to spaces, except for extension
# convert the beginning of each word to caps
# remove anything after HTDV in filename
# convert lowercase to upper in S03E14
# get the filename, make a directory
# get the season number, make a directory
# move the file to the nested directory
