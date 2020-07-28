#!/bin/bash

## Define vars
OPERATION=$1
WRKDIR=`pwd`
BASE_DIRNAME=`basename $WRKDIR`
rc=0          # return code


## Check OPERATION to be performed (e.g. deploy or verify) and execute step
if [[ "$OPERATION" == "deploy" ]];then
  i=10          # used to pause upload since webhost site terminates scp connection after repeated rapid file upload
  waitfloor=5   # used to pause upload since webhost site terminates scp connection after repeated rapid file upload
  ./sync.sh 2>/dev/null
  
  cat $BASE_DIRNAME.flist | grep "^$BASE_DIRNAME" | sed "s#^$BASE_DIRNAME/##" | sort > ref.flist
  echo ""
  echo "--- FILES TO SYNC ---"
  
  ## Check if any files need to be syncd to QA env
  comm -12 sync.flist ref.flist | grep '[A-Za-z]' >/dev/null
  if [[ $? -ne 0 ]];then
    echo "No files need to be syncd"
  else
    echo "QA env needs to be updated"
    comm -12 sync.flist ref.flist
    comm -12 sync.flist ref.flist | while read f;do dirname $f; done | sort -u | grep -v '^.$' | while read dir;do
       ssh -i ${SECRETKEY} ${SECRETUSER}@${SECRETHOST} "mkdir -p /home/ar4jf2nz/public_html/QA_${BASE_DIRNAME}/$dir"
    done
    comm -12 sync.flist ref.flist | while read f;do
      waittime=$(($(($RANDOM % 15))+$waitfloor))
      scp -p -i ${SECRETKEY} $f ${SECRETUSER}@${SECRETHOST}:/home/ar4jf2nz/public_html/QA_${BASE_DIRNAME}/$f
      sleep $waittime    # used to pause upload since webhost site terminates scp connection after repeated rapid file upload
      i=$(($i+1))
      waitfloor=$(($i/5))
    done
  fi

elif [[ "$OPERATION" == "verify" ]];then
  
  ## Check my URLs for non-http 200 responses
  cat missing.flist | sed 's#^#jhwebex.com/#' > my_urls.flist
  cat ref.flist | sed 's#^\([^/].*\)$#jhwebex.com/QA_profile/\1#' >> my_urls.flist
  myBadHttpResp=`sort -u my_urls.flist | while read url; do echo "^ > $url"; curl -Is $url | head -n 1; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | grep -v '200 OK'`
  
  myBadHttpResp=`cat ref.flist | sed 's#^\([^/].*\)$#jhwebex.com/QA_profile/\1#' | while read url; do echo "^--- $url"; curl -Is $url | head -n 1; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | egrep -v '^ *|200 OK' | tr '\n' '|'`
  
  if [[ -z $myBadHttpResp ]];then
    echo "All referenced URLs are OK"
  else
    echo "There are bad URLs:"
    echo $myBadHttpResp | tr '|' '\n'
    rc=1
  fi
  
  
  
  ## Check external URLs for non-http 200 responses
  grep '^http' references.flist | awk '{print $1}' | sort -u  > ext_urls.flist
  
  badExtUrls=`cat ext_urls.flist | grep -v oracle | while read url; do echo "^--- $url"; curl -Is --connect-timeout 3 "$url" | grep HTTP; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | egrep -v '^ *$|linkedin.com.*HTTP.* 999|HTTP.* 200|HTTP.* 302' | tr '\n' '|'`

  if [[ -z $badExtUrls ]];then
    echo "All external URLs are OK"
  else
    echo "There are bad external URLs:"
    echo $badExtUrls | tr '|' '\n'
    rc=2
  fi


  ## Check for any unused files in QA directory
  ssh -i ${SECRETKEY} ${SECRETUSER}@${SECRETHOST} "cd public_html/QA_${BASE_DIRNAME}; find . -type f" | sed 's#^\./##' | sort > qa_all.flist
  echo "There are unused files in QA environment:"
  comm -23 qa_all.flist ref.flist | grep -v '/archive/'
       

else
  ## Unrecognized build step
  echo "ERROR:  Unrecognized argument specified for $0"
  rc=3
fi

exit $rc
