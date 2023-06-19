
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
                    sh 'docker tag zabbix/zabbix-web-nginx-mysql:latest kuzma343/my-repository:zabbix-web'
                        sh 'docker tag zabbix/zabbix-server-mysql:latest kuzma343/my-repository:zabbix-server'
                        sh 'docker tag mysql:latest kuzma343/my-repository:mysql'
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
                    
                    sh 'docker push kuzma343/my-repository:zabbix-web'
                        sh 'docker push kuzma343/my-repository:zabbix-server'
                        sh 'docker push kuzma343/my-repository:mysql'
                }
            }
        }
    }
}
