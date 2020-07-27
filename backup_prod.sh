#!/bin/bash


function prtUsage {
  echo "USAGE  :  $0 <html_main_page> <qty_of_old_backups_to_keep>"
  echo "EXAMPLE:  $0 profile 8    --> creates a backup of ~/public_html/profile directory and removes any backups older than last 8"
  echo "EXAMPLE:  $0 jhpage       --> creates a backup of ~/public_html/jhpage directory and removes any backups older than the default qty of 5"
}


## read name of web page to backup
if [[ -z $1 ]];then
  webpg=$1
else
  echo "ERROR:  Missing mandatory argument"
  prtUsage
  exit 1
fi


## read in KEEP_QTY or set default value for KEEP_QTY
if [[ -z $2 ]];then
  KEEP_QTY=5
else
  echo $2 | grep '^[0-9][0-9]*$' >/dev/null
  if [[ $? -eq 0 && $2 -le 10 ]];then
    KEEP_QTY=$2
  else
    echo "ERROR:  Argument 2 must be an integer value <= 10."
    prtUsage
    exit 1
  fi
fi

## set variables

dtstmp=`date +"%Y%m%d"`
bak_dir="${HOME}/public_html/${webpg}_${dtstmp}"

if [[ -d $bak_dir ]];then
  echo "... backup already taken today.  If a more recent backup is needed, rename (i.e. append -1) or remove earlier backup taken today."
else
  ## take a backup of prod
  mkdir ${HOME}/public_html/${webpg}_${dtstmp}
  cd ${HOME}/public_html/${webpg}
  find . | cpio -pdmv ${HOME}/public_html/${webpg}_${dtstmp}

  ## create cksum values for src & tgt directory contents`
  src_cksum=`find . -type f | cksum`
  cd ${HOME}/public_html/${webpg}_${dtstmp}
  tgt_cksum=`find . -type f | cksum`

  echo "src_cksum = $src_cksum"
  echo "tgt_cksum = $tgt_cksum"

  if [[ "$src_cksum" == "$tgt_cksum" ]];then
    echo "... backup was successful"
  else
    echo "... backup failed"
  fi
fi

## cleanup old backups exceeding KEEP_QTY
start_line=$(($KEEP_QTY+1))
cd ${HOME}/public_html
ls | grep "${webpg}_20[0-9][0-9]*" | sort -r | sed -n "$start_line,\$p" > rmv.old_backups.flist
grep '_20[0-9][0-9]*/$' rmv.old_backups.flist | while read dir;do echo "removing $dir"; rm -rf $dir; done
rm rmv.old_backups.flist

