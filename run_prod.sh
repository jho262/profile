#!/bin/bash

###########################################################################################
## This program will perform operations on the PROD environment for the specified web page.
## Operations include backup, deploy, verify and cleanup.
###########################################################################################

function prtUsage {
  echo "USAGE  :  $0 <operation> <webpg>"
  echo "EXAMPLE:  $0 backup profile   --> takes a backup of PROD profile page (~/public_html/profile directory)"
  echo "EXAMPLE:  $0 deploy profile   --> deploys changes to the PROD env"
  echo "EXAMPLE:  $0 verify profile   --> verifies updates to the PROD env"
  echo "EXAMPLE:  $0 cleanup profile  --> cleans up PROD env"
}


#########
## MAIN
#########

## Check for args
if [[ -z $2 ]];then
  echo "ERROR:  Missing mandatory arguments"
  prtUsage
  exit 1
fi


## Define vars
OPERATION=$1
WEBPG=$2
WRKDIR=`pwd`
BASE_DIRNAME=`basename $WRKDIR`
rc=0          # return code


## Check OPERATION to be performed (e.g. backup, deploy, verify, or cleanup) and execute step
if [[ "$OPERATION" == "backup" ]];then
  echo "... backing up PROD $WEBPG page"

  ## set variables
  dtstmp=`date +"%Y%m%d"`
  bak_dir="${HOME}/public_html/${WEBPG}_${dtstmp}"
  KEEP_QTY=5

  if [[ -d $bak_dir ]];then
    echo "... backup already taken today.  If a more recent backup is needed, rename (i.e. append -1) or remove earlier backup taken today."
  else
    ## take a backup of prod
    mkdir ${HOME}/public_html/${WEBPG}_${dtstmp}
    cd ${HOME}/public_html/${WEBPG}
    find . | cpio -pdmv ${HOME}/public_html/${WEBPG}_${dtstmp}

    ## create cksum values for src & tgt directory contents`
    src_cksum=`find . -type f | cksum`
    cd ${HOME}/public_html/${WEBPG}_${dtstmp}
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
  ls | grep "${WEBPG}_20[0-9][0-9]*" | sort -r | sed -n "$start_line,\$p" > rmv.old_backups.flist
  grep '_20[0-9][0-9]*/$' rmv.old_backups.flist | while read dir;do echo "removing $dir"; rm -rf $dir; done
  rm rmv.old_backups.flist

elif [[ "$OPERATION" == "deploy" ]];then
  echo "... deploying changes to PROD $WEBPG page"

  ## generate checksums for each file in ${WEBPG} and QA_${WEBPG}
  cd ${HOME}/public_html
  find QA_${WEBPG}/ -type f | grep -v '/archive/' | while read f;do cksum $f | awk '{print $NF, $1}';done | sort | sed "s#QA_${WEBPG}/##" | egrep -v '\.flist |\.cksum ' > qa.cksum
  find ${WEBPG} -type f | grep -v '/archive/' | while read f;do cksum $f | awk '{print $NF, $1}';done | sort | sed "s#${WEBPG}/##" | egrep -v '\.flist |\.cksum ' > prod.cksum

  ## identify differences between PROD and QA
  ##   generate lists containing identical files in QA and prod, extra files in prod,
  ##   extra files in QA, and files that do not match in QA and prod
  join -a1 qa.cksum prod.cksum | awk '{if($2==$3)print $0}' > identical.flist
  join -a2 qa.cksum prod.cksum | awk '{if(NF==2)print $0}' > prod_extras.flist
  join -a1 qa.cksum prod.cksum | awk '{if(NF==2)print $0}' > qa_extras.flist
  join -a1 qa.cksum prod.cksum | awk '{if(NF==3 && $2!=$3)print $0}' > modified.flist

  if [[ ! -z prod_extras.flist ]];then
    cat prod_extras.flist | awk 'BEGIN{print "Files exist in PROD but not in QA.  Consider archiving these files."}{print $1}END{print ""}'
  fi

  if [[ ! -z qa_extras.flist && ! -z modified.flist ]];then
    cat qa_extras.flist modified.flist | sort | awk 'BEGIN{print "Files that will be added or modified in PROD:"}{print $1}'
    echo "cat qa_extras.flist modified.flist | sort | awk '{print $1}' | while read f; do cp -p QA_${WEBPG}/$f ${WEBPG}/$f; done"
  ###  cat qa_extras.flist modified.flist | sort | awk '{print $1}' | while read f; do cp -p QA_${WEBPG}/$f ${WEBPG}/$f; done
  else
    echo "No changes are needed.  All non-archive files in PROD env are already in sync with QA."
  fi


elif [[ "$OPERATION" == "verify" ]];then
  echo "... verifying PROD updates to $WEBPG page"

#-------------------------
#        ## Check my URLs for non-http 200 responses
#        cat missing.flist | sed 's#^#jhwebex.com/#' > my_urls.flist
#        cat ref.flist | sed 's#^\([^/].*\)$#jhwebex.com/QA_profile/\1#' >> my_urls.flist
#        myBadHttpResp=`sort -u my_urls.flist | while read url; do echo "^ > $url"; curl -Is $url | head -n 1; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | grep -v '200 OK'`
#
#        myBadHttpResp=`cat ref.flist | sed 's#^\([^/].*\)$#jhwebex.com/QA_profile/\1#' | while read url; do echo "^--- $url"; curl -Is $url | head -n 1; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | egrep -v '^ *|200 OK' | tr '\n' '|'`
#
#        if [[ -z $myBadHttpResp ]];then
#          echo "All referenced URLs are OK"
#        else
#          echo "There are bad URLs:"
#          echo $myBadHttpResp | tr '|' '\n'
#          rc=1
#        fi
#
#
#        ## Check external URLs for non-http 200 responses
#        grep '^http' references.flist | awk '{print $1}' | sort -u  > ext_urls.flist
#
#        badExtUrls=`cat ext_urls.flist | grep -v oracle | while read url; do echo "^--- $url"; curl -Is --connect-timeout 3 "$url" | grep HTTP; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | egrep -v '^ *$|linkedin.com.*HTTP.* 999|HTTP.* 200|HTTP.* 302' | tr '\n' '|'`
#
#        if [[ -z $badExtUrls ]];then
#          echo "All external URLs are OK"
#        else
#          echo "There are bad external URLs:"
#          echo $badExtUrls | tr '|' '\n'
#          rc=2
#        fi
#-------------------------


elif [[ "$OPERATION" == "cleanup" ]];then
  echo "... cleaning up PROD $WEBPG page"


else
  ## Unrecognized build step
  echo "ERROR:  Unrecognized argument specified for $0"
  rc=3
fi

exit $rc
