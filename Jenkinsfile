
#!groovy
//  groovy Jenkinsfile
properties([disableConcurrentBuilds()])\

pipeline  {
        agent { 
           label ''
        }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }
    stages {
        stage("Git clone") {
            steps {
                sh '''
                cd /home/kuzma/
                git clone https://git.rdr-it.io/docker/zabbix.git .         
                '''
            }
        }    
        stage("Work") {
            steps {
                sh '''
                cd env_vars
                docker-compose up -d
                '''
            }
        }   
    }
}
