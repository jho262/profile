#!/bin/bash

## This script will find all files in the working directory and check if the file exists at the target remote QA directory.
## If it does not exist in QA directory, it will add to the list of files that may need to be sync'd (i.e sync.flist).
## If it exists in QA directory, then it will check if the files are different.  If different, the file will be added to 
## the sync.flist.  Since the working directory has many artifacts that are not used by the parent html file (i.e. typically
## named index.html), this generated list of files to be sync'd will need to be cross-referenced with a list of files that
## are referenced by the parent html to determine the actual files that must be sync'd.

WRKDIR=`pwd`
BASE_DIRNAME=`basename $WRKDIR`

## Create remote QA file checksums and flist 
ssh -i ~/.ssh/mac_id_rsa ar4jf2nz@jhwebex.com "find /home/ar4jf2nz/public_html/QA_${BASE_DIRNAME} -type f | grep -v '\/old\/' | while read f;do cksum \$f | awk '{print \$NF, \$1}' | sed 's#/home/ar4jf2nz/public_html/QA_${BASE_DIRNAME}##';done" | sort > remote.cksum
cat remote.cksum | awk '{print $1}' | sort > remote.flist


## Create local file checksums and flist 
find . -type f | egrep -v '\./\.git\/|sync\.|remote\.|local\.|list$|qa_chk.sh|sync.sh' | while read f; do cksum $f | awk '{print $NF, $1}' | sed 's#\./##';done | sort > local.cksum
cat local.cksum | awk '{print $1}' | sort > local.flist


## Generate list of files that need to be sync'd 
comm -23 local.cksum remote.cksum | awk '{print $1}' > sync.flist
comm -23 local.flist remote.flist >> sync.flist


## Cleanup temp files
rm remote.cksum remote.flist local.cksum local.flist


