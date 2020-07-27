#!/bin/bash

function prtUsage {
  echo "USAGE  :  $0 <html_main_page>"
  echo "EXAMPLE:  $0 profile       --> syncs ~/public_html/profile to ~/public_html/QA_profile"
}


## read name of web page to backup
if [[ -z $1 ]];then
  webpg=$1
else
  echo "ERROR:  Missing mandatory argument"
  prtUsage
  exit 1
fi

## generate checksums for each file in ${webpg} and QA_${webpg}
cd ${HOME}/public_html
find QA_${webpg}/ -type f | grep -v '/archive/' | while read f; do cksum $f | awk '{print $NF, $1}'; done | sort | sed "s#QA_${webpg}/##" | egrep -v '\.flist |\.cksum ' > qa.cksum 
find ${webpg} -type f | grep -v '/archive/' | while read f; do cksum $f | awk '{print $NF, $1}'; done | sort | sed "s#${webpg}/##" | egrep -v '\.flist |\.cksum ' > prod.cksum 

## generate lists containing identical QA and prod files, extra files in prod, extra files in QA, and files that do not match in QA and prod
join -a1 qa.cksum prod.cksum | awk '{if($2==$3)print $0}' > identical.flist
join -a2 qa.cksum prod.cksum | awk '{if(NF==2)print $0}' > prod_extras.flist
join -a1 qa.cksum prod.cksum | awk '{if(NF==2)print $0}' > qa_extras.flist
join -a1 qa.cksum prod.cksum | awk '{if(NF==3 && $2!=$3)print $0}' > modified.flist

if [[ ! -z prod_extras.flist ]];then
  cat prod_extras.flist | awk 'BEGIN{print "Files exist in PROD but not in QA.  Consider archiving these files.\n"}{print $1}END{print "\n"}'
fi

if [[ ! -z qa_extras.flist && ! -z modified.flist ]];then
  cat qa_extras.flist modified.flist | sort | awk 'BEGIN{print "Files that will be added or modified in PROD:\n"}{print $1}END{print "\n"}'
  cat qa_extras.flist modified.flist | sort | awk '{print $1}' | while read f; do cp -p QA_${webpg} ${webpg}; done
else
  echo "No changes are needed.  All non-archive files in PROD env are already in sync with QA."
fi



