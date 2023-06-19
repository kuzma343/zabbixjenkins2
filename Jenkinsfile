
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
       
        stage("Work") {
            steps {
                sh '''
               
                docker-compose up -d
                '''
            }
        }  
             stage('Tag Docker Image') {
            steps {
                script {
                    // Команда для тегування Docker образу
                    sh 'docker tag zabbix/zabbix-web-nginx-mysql:latest kuzma343/zabbix-web:latest'
                        sh 'docker tag zabbix/zabbix-server-mysql:latest kuzma343/zabbix-server:latest'
                        sh 'docker tag mysql:latest kuzma343/mysql:latest'
                }
            }
        }
        stage("docker login") {
            steps {
                echo " ============== docker login =================="
                withCredentials([usernamePassword(credentialsId: 'DockerHub-Credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    docker login -u $USERNAME -p $PASSWORD
                    '''
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    
                    sh 'docker push kuzma343/zabbix-web:latest'
                        sh 'docker push kuzma343/zabbix-server:latest'
                        sh 'docker push kuzma343/mysql:latest'
                }
            }
        }
    }
}
