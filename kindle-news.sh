#!/bin/bash
# Used in junction with (headless) Calibre and its recipes

email_from=user@example.com
email_to=example@kindle.com
root_path=/home/wchen/calibre/
recipe_root_path="$root_path/recipes"
mobi_root_path="$root_path/mobi"

# Specify what recipe files to use (filename minus the file extension) and the name/title to show up on Kindle
recipe_name=(wsj_free liberty_times china_times taipei united_daily apple_daily bbc fhm_uk epicurious)
title_name=("WSJ" "Liberty Times" "China Times" "Taipei" "聯合" "蘋果日報" "BBC" "FHM UK" "Epicurious")

if [[ ${#recipe_name[*]} != ${#title_name[*]} ]]; then
  echo "Number of filenames and titles mismatch" >/dev/stderr
  exit 1
fi

for i in `seq 0 ${#title_name[*]}`; do
  if [[ $i == ${#title_name[*]} ]]; then
    continue
  fi
  recipe_path="$recipe_root_path/${recipe_name[$i]}.recipe"
  mobi_name="${recipe_name[$i]}.mobi"
  ebook-convert $recipe_path $mobi_root_path/$mobi_name --title="${title_name[$i]}" && \
  calibre-smtp -r localhost -a $mobi_root_path/$mobi_name $email_from $email_to $mobi_name
done
