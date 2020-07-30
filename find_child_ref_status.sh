#!/bin/bash

## This script will recursively check all file references when passed a top level html (e.g. index.html). 
## All file references local to the parent html directory must exist to PASS the check.  The script must 
## be invoked in the directory where the top level html file resides.
## 
## Output files:
##   tmp.flist            - child references in raw format including duplicates and debugging comments
##   references.flist     - unique list of child references formatted to include path starting with $WRKDIR and
##                            + external references will be marked as EXTERNAL_FILE
##                            + references to local files that are not found will be marked as MISSING
##   wrkdir.all.flist     - all files found in current working dir (i.e. should be all the $WEBPG files checked into GitHub)
##   $BASE_DIRNAME.flist  - the references.flist files w/o the $DOCROOT path and excluding external files
##   unused.flist         - all files in current working dir not referenced by top level html
##   missing.flist        - list of referenced files that do not exist in current working dir


## function prtUsage - print script usage with example
function prtUsage {
  echo "USAGE  :  $0 <html_file>"
  echo "EXAMPLE:  $0 index.html"
  exit 1
}

## function recurse - descends down hierarchy of passed html file to identify all child references.
function recurse {
  parent=$1
  if [[ -z $parent ]];then
    echo ""
    exit
  else
    refs=`cat $parent 2>/dev/null | tr "'" '"' | egrep -v 'href="mailto:|href="tel:' | sed -e 's#^#\^#' -e 's#href=#^href=#g' -e 's#src=#^src=#g' | tr '\n' '^' | awk 'BEGIN{RS="^"}{print $0}' | egrep '\.html|\.css|\.gif|\.png|\.php|src=|href=|background-image: *url..' | sed -e 's#^.*background-image: *url..##' -e 's#^.*href=.##' -e 's#^.*src=.##' -e 's#^.*load("##' -e 's#".*$##' | grep -v '^#'`
    for file in `echo $refs | tr '|' '\n'`;do
      echo "$file" >> tmp.flist

      echo $file | grep '/' >/dev/null
      has_slash_rc=$?
      echo $file | grep '^[A-Za-z]' >/dev/null
      starts_with_alphachar_rc=$?
      echo $file | grep '^http' >/dev/null
      starts_with_http_rc=$?
      echo $file | grep '^\./' >/dev/null
      starts_with_dot_rc=$?
      echo $file | grep '^\.\./' >/dev/null
      starts_with_dotdot_rc=$?

      ## file starts with http
      if [[ $starts_with_http_rc -eq 0 ]];then
echo "... starts with http" >> tmp.flist
        file=`echo $file | sed "s#${HTTP_HOME}#${WRKDIR}#"`

      ## file does not contain / or starts with alphabetic character
      elif [[ $has_slash_rc -ne 0 || $starts_with_alphachar_rc -eq 0 ]];then
echo "... does not contain / or starts with alpha character" >> tmp.flist
        file="$WRKDIR/$file"

      ## file contains a /
      else
echo "... contains a slash and does not begin with alpha character" >> tmp.flist

        echo $file | grep '^/' >/dev/null
        if [[ $? -eq 0 ]];then
echo "... starts with /" >> tmp.flist
          file=`echo $file | sed "s#^/#${DOCROOT}/#" | sed 's#//*#/#g'`

        elif [[ $starts_with_dot_rc -eq 0 ]];then
echo "... starts with ./" >> tmp.flist
         prefix=`dirname $parent`
         file=`echo $file | sed "s#^\.#$prefix#"`

        elif [[ $starts_with_dotdot_rc -eq 0 ]];then
echo "... starts with ../" >> tmp.flist
#         parent_depth=`echo $parent | awk -F/ '{print (NF-1)}'`
         up_cnt=`echo $file | tr '/' '\n' | grep -c "\.\."`
echo "... up_cnt = $up_cnt" >> tmp.flist
         prefix=`dirname $parent`
echo "... prefix = $prefix" >> tmp.flist
         for (( i=1; i<=$up_cnt; i++ ));do
           prefix=`dirname $prefix`
         done
echo "... prefix = $prefix" >> tmp.flist
         filename_wo_dotdot=`echo $file | sed 's#\.\./##g'`
         file=`echo $filename_wo_dotdot | sed "s#^#$prefix/#"`

        else
          echo "ERROR:  Unrecognized reference pattern:  $file"
          exit
        fi
      fi

      ## if not leaf, descend down hierarchy.  else, echo $file
      grep $file references.flist >/dev/null
      dup_rc=$?
      file $file | egrep 'ASCII|HTML' >/dev/null
      ascii_rc=$?
      echo $file | grep 'jquery.*\.js' >/dev/null
      jqry_file_rc=$?
      echo $file | grep "^${WRKDIR}/" >/dev/null
      local_file_rc=$?
      if [[ -e $file ]];then
        ## check if duplicate reference
        if [[ $dup_rc -ne 0 && $jqry_file_rc -ne 0 ]];then
          echo $file >> references.flist
          ## check if ascii file
          if [[ $ascii_rc -eq 0 && $local_file_rc -eq 0 ]];then
            recurse $file
          fi
        fi
      else
        if [[ $file == "http"* ]];then
          echo "$file EXTERNAL_FILE" >> references.flist
        else
          echo "$file MISSING" >> references.flist
        fi
      fi
    done
  fi
}





#########
## MAIN
#########
>references.flist
>tmp.flist

## Define variables
HTTP_HOME="http://jhwebex.com/QA_profile"
WRKDIR=`pwd`
DOCROOT=`dirname $WRKDIR`
BASE_DIRNAME=`basename $WRKDIR`

## Check for args
if [[ -z $1 ]];then
  echo "ERROR:  Mandatory arg is missing."
  prtUsage
else
  echo $1 | grep '\.html$' >/dev/null 2>&1
  if [[ $? -ne 0 ]];then
    echo "ERROR:  This script only works with html files."
    prtUsage
  fi
fi


## Reformat filename to fully qualified form
echo $1 | grep '^/' >/dev/null
if [[ $? -ne 0 ]];then
  wrkdir=`pwd`
  top_html="$wrkdir/$1"
else
  top_html=$1
fi
echo $top_html >> references.flist

## Recursively descend through child html files to identify all referenced files
recurse $top_html


## find all files in current directory structure excluding check scripts and tmp files created by scripts
find $DOCROOT -type f | grep "/${BASE_DIRNAME}/" | egrep -v '\@tmp/|/\.git/|cksum$|flist$|\.sh$|Jenkinsfile' | sed "s#$DOCROOT/##" | sort -u > wrkdir.all.flist


## find all files that meet the following 2 critera:
##    (1) are directly or indirectly referenced by the parent html file
##    (2) should exist in the directory structure of the parent html file
grep "$DOCROOT" references.flist  | awk '{print $1}' | sort -u | sed "s#$DOCROOT/##" > $BASE_DIRNAME.flist
echo -e "\n--- REFERENCED FILES ---"
cat $BASE_DIRNAME.flist


## identify files that are not part of the parent html hierarchy (i.e. files that can be deleted or archived)
echo -e "\n--- UNUSED FILES ---"
>unused.flist
comm -23 wrkdir.all.flist $BASE_DIRNAME.flist | tee -a unused.flist


## identify files that are needed by the parent html file which are missing
comm -13 wrkdir.all.flist $BASE_DIRNAME.flist > missing.flist

files_in_different_hierarchy=`grep -v "^$BASE_DIRNAME" missing.flist | tr '\n' '^'`
if [[ ! -z $files_in_different_hierarchy ]];then
  echo -e "\n--- REFERENCED FILES THAT EXIST IN ANOTHER HIERARCHY (i.e. SUB-DIRECTORY) ---"
  echo $files_in_different_hierarchy | tr '^' '\n'
fi

grep "^$BASE_DIRNAME" missing.flist >/dev/null
if [[ $? -eq 0 ]];then
  echo "ERROR:  There are missing files referenced by $top_html."
  echo "--- MISSING FILES ---"
  grep "^$BASE_DIRNAME" missing.flist
  exit 1
fi


## prepare a tmp script that will move unused files to archive directory, checks them into github, and deletes original file locations
cat unused.flist | grep -v '/archive/' | grep '[A-Za-z]' >/dev/null
if [[ $? -eq 0 ]];then
  cat unused.flist | grep -v 'archive/' | grep "$BASE_DIRNAME/" | sed "s#$BASE_DIRNAME/##" | while read f; do dirname $f; done | sort -u | egrep -v '^ *$|^\.$' | while read dir;do echo "mkdir -p archive/$dir"; done | awk 'BEGIN{print "#!/bin/bash\n"}{print $0}END{print ""}' > archive_$BASE_DIRNAME.unused.sh
  cat unused.flist | grep -v 'archive/' | grep "$BASE_DIRNAME/" | sed "s#$BASE_DIRNAME/##" | while read f;do dir=`dirname $f | sed 's#^\.##'`; echo "mv $f archive/$dir";done >> archive_$BASE_DIRNAME.unused.sh

  echo $WRKDIR | grep '/\.jenkins/' >/dev/null
  jenkins_wrkspc_rc=$?
  if [[ $jenkins_wrkspc_rc -eq 0 ]];then
    echo "... updating GitHub repository to reflect archiving of files"
    cat unused.flist | grep -v 'archive/' | grep "$BASE_DIRNAME/" | sed "s#$BASE_DIRNAME/##" | while read f;do dir=`dirname $f | sed 's#^\.##'`; fname=`basename $f`; dir=`dirname $f | sed 's#^\.##'`; echo "git add archive/$dir/$fname" | sed 's#//*#/#g'; echo ""; echo "git rm $dir/$fname" | sed 's#//*#/#g';done >> archive_$BASE_DIRNAME.unused.sh
    echo 'git commit -a -m "archive unused files"' >> archive_$BASE_DIRNAME.unused.sh
    echo 'git push origin master' >> archive_$BASE_DIRNAME.unused.sh
  fi
  chmod 755 archive_$BASE_DIRNAME.unused.sh
  echo "If you want to archive all unused files (i.e. move them to the archive directory), use `pwd`/archive_$BASE_DIRNAME.unused.sh"
else
  echo "No unused files need to be archived"
fi


