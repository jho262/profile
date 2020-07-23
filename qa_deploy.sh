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



