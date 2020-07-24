WRKDIR=`pwd`
BASE_DIRNAME=`basename $WRKDIR`
i=10
waitfloor=5
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
    sleep $waittime
    i=$(($i+1))
    waitfloor=$(($i/5))
  done
fi

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
fi



## Check external URLs for non-http 200 responses
grep '^http' references.flist | awk '{print $1}' | sort -u  >> ext_urls.flist

badExtUrls=`cat ext_urls.flist | grep -v oracle | while read url; do echo "^--- $url"; curl -Is --connect-timeout 3 "$url" | grep HTTP; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | egrep -v '^ *$|linkedin.com.*HTTP.* 999|200 OK|302 Found' | grep -v '404'cat ext_urls.flist | grep -v oracle | while read url; do echo "^--- $url"; curl -Is --connect-timeout 3 "$url" | grep HTTP; done | tr '\n' ' ' | awk 'BEGIN{RS="^"}{print $0}' | egrep -v '^ *$|linkedin.com.*HTTP.* 999|200 OK|302 Found' | tr '\n' '|'`

if [[ -z $badExtUrls ]];then
  echo "All external URLs are OK"
else
  echo "There are bad external URLs:"
  echo $badExtUrls | tr '|' '\n'
