
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
                
                git clone https://git.rdr-it.io/docker/zabbix.git          
                '''
            }
        }    
        stage("Work") {
            steps {
                sh '''
               
                docker-compose up -d
                '''
            }
        }   
    }
}
