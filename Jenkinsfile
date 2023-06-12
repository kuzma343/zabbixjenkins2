#!groovy
//  groovy Jenkinsfile
properties([disableConcurrentBuilds()])

pipeline  {
        agent { 
           label ''
        }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.image('docker').withRun('-it', 'zabbix2') {
                        // Команда для збірки Docker образу
                        sh 'docker build -t zabbix2 .'
                    }
                }
            }
        }
        
        stage('Tag Docker Image') {
            steps {
                script {
                    // Команда для тегування Docker образу
                    sh 'docker tag zabbix2:latest kuzma343/zabbix2:latest'
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
                    
                    sh 'docker push kuzma343/zabbix2:latest'
                }
            }
        }
        
        
    }
}
