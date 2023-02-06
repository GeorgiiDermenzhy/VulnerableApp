pipeline {
    agent any
    tools{
        gradle ('gradle 7.5.1')
    }
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_hub_login')
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build'
            }
        }
		stage('Build Docker Image') {
			steps {
				sh './gradlew bootBuildImage --imageName=georgeder/vulnerableapp:latest'
			}
		}
		stage('Push Docker Image') {
			steps {
				sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
				sh 'docker push georgeder/vulnerableapp:latest' 
			}
		}
    }
}