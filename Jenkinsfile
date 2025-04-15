pipeline {
    agent any
    tools {
        maven 'Maven' // Must match the name in Jenkins > Global Tool Config
    }
    environment {
        IMAGE_NAME = 'parmarajay/irada:1.0'
        CONTAINER_NAME = 'irada-test'
        NETWORK_NAME = 'jenkins'
    }
    stages {
        stage('Checkout Code') {
            steps {
                sshagent(['git-ssh-key']) {
                    checkout([$class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            url: 'git@github.com:ajayparmar311/java-source.git'
                        ]]
                    ])
                }
            }
        }
        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonar') {
                 sh 'mvn -U clean install sonar:sonar -Dsonar.projectKey=iwayQApp'
              }
            }
      }
	  
	  stage('Upload to Nexus') {
		steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
            sh 'mvn deploy --settings settings.xml'
			}
		}
	}
	
	 stage('Copy Files to Ansible Server') {
    steps {
        sshagent(['ansible-ssh-key']) {
            sh '''
                scp -o StrictHostKeyChecking=no Dockerfile create-container-image.yaml admin@ansible-controller:/home/admin
            '''
        }
    }
}

	stage('Build Container Image') {
    steps {
        sshagent(['ansible-ssh-key']) {
            sh '''
				ssh -o StrictHostKeyChecking=no admin@ansible-controller -C \"sudo ansible-playbook create-container-image.yaml"
            '''
        }
    }
}

    stage('Pull Image') {
            steps {
                script {
                    sh "docker pull $IMAGE_NAME"
                }
            }
        }

    stage('Stop & Remove Existing Container') {
            steps {
                script {
                    sh """
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                    """
                }
            }
        }
        
    stage('Run Container') {
            steps {
                script {
                    sh """
                        docker run -d --name $CONTAINER_NAME -p 31000:8080 --network $NETWORK_NAME $IMAGE_NAME
                    """
                }
            }
        }
    
   
    
        
    }
}
