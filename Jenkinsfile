pipeline {
    agent any

    stages {
        stage ('STAGE 1 - PRE-QA_DEPLOYMENT_CHECK_FOR_MISSING_FILES') {
            steps {
                println "\n=====  EXECUTING pre-QA_deployment check for missing files"
                sh './chk.jenkins_wrkspc.sh index.html'
            }
        }
        stage ('STAGE 2 - QA_DEPLOY') {
            steps {
              println "\n=====  EXECUTING QA deployment stage"
              withCredentials([
                string(credentialsId: 'secret_webuser', variable: 'SECRETUSER'),
                string(credentialsId: 'secret_webhost', variable: 'SECRETHOST'),
                string(credentialsId: 'secret_profilekey', variable: 'SECRETKEY')
              ]){
                  // Random, generally increasing waittime is used since webhost site closes connection when repeated file transfers occur too quick.
                  // Copy all referenced files including parent html to QA location by doing the following:
                  // - execute sync.sh to create a list of all files that do not exist at webhost QA location or that may need updating (e.g sync.flist)
                  // - cross reference the list against list of files referenced by parent html, create required remote directories and scp files

                  sh './run_qa.sh deploy' 
              }
            }
        }
        stage ('STAGE 3 - QA_VERIFY') {
            steps {
              println "\n=====  EXECUTING QA verify stage, test referenced links"
              withCredentials([
                string(credentialsId: 'secret_webuser', variable: 'SECRETUSER'),
                string(credentialsId: 'secret_webhost', variable: 'SECRETHOST'),
                string(credentialsId: 'secret_profilekey', variable: 'SECRETKEY')
              ]){
                  sh './run_qa.sh verify' 
              }
            }
        }
        stage ('STAGE 4 - PROD_BACKUP') {
            steps {
              println "\n=====  EXECUTING PROD backup stage"
              withCredentials([
                string(credentialsId: 'secret_webuser', variable: 'SECRETUSER'),
                string(credentialsId: 'secret_webhost', variable: 'SECRETHOST'),
                string(credentialsId: 'secret_profilekey', variable: 'SECRETKEY')
              ]){
                sh 'wrkdir=`pwd`; webpg=`basename $wrkdir`; scp -p -i $SECRETKEY run_prod.sh  $SECRETUSER@$SECRETHOST:public_html/${webpg}; ssh -i $SECRETKEY $SECRETUSER@$SECRETHOST "cd public_html/${webpg}; ./run_prod.sh backup $webpg"'
              }
            }
        }
        stage ('STAGE 5 - PROD_DEPLOY') {
            steps {
                println "\n=====  EXECUTING PROD deployment stage"
              withCredentials([
                string(credentialsId: 'secret_webuser', variable: 'SECRETUSER'),
                string(credentialsId: 'secret_webhost', variable: 'SECRETHOST'),
                string(credentialsId: 'secret_profilekey', variable: 'SECRETKEY')
              ]){
                sh 'wrkdir=`pwd`; webpg=`basename $wrkdir`; ssh -i $SECRETKEY $SECRETUSER@$SECRETHOST "cd public_html/${webpg}; ./run_prod.sh deploy $webpg"'
              }
            }
        }
        stage ('STAGE 6 - PROD_VERIFY') {
            steps {
                println "\n=====  EXECUTING PROD verify stage"
            }
        }
        stage ('STAGE 7 - PROD_CLEANUP') {
            steps {
                println "\n=====  EXECUTING PROD cleanup stage"
            }
        }
    }
}
