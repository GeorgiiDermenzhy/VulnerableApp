pipeline {
    agent any
    parameters{
        booleanParam(name: 'execute_SCA',defaultValue: false, description: 'Run SCA tests')
        booleanParam(name: 'execute_SAST',defaultValue: false, description: 'Run SAST tests')
        booleanParam(name: 'execute_DAST',defaultValue: false, description: 'Run DAST tests')
        booleanParam(name: 'execute_Trivy_image',defaultValue: false, description: 'Scan Image with Trivy')
        booleanParam(name: 'execute_Trivy_yaml',defaultValue: false, description: 'Scan YAML with Trivy')
    }
    tools{
        gradle ('gradle 7.5.1')
    }
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_hub_login')
        DOCKER_IMAGE_NAME = 'georgeder/vulnerableapp:latest'
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build'
            }
        }
        stage('SCA with Dependency-Check') {
            when{
                expression{
                    params.execute_SCA
                }
            }
            steps {
                dependencyCheck additionalArguments: '', odcInstallation: 'dependency-check8.0.2'
                dependencyCheckPublisher pattern: ''
            }
        }
        stage('SAST with Semgrep-Scan') {
            when{
                expression{
                    params.execute_SAST
                }
            }
            steps {
                sh 'docker run --rm -v "${PWD}:/src" returntocorp/semgrep semgrep --config=auto'
            }
        }
		stage('Build Docker Image') {
			steps {
				sh "./gradlew bootBuildImage --imageName=$DOCKER_IMAGE_NAME"
			}
		}
        stage('Image Scan: Trivy') {
            when{
                expression{
                    params.execute_Trivy_image
                }
            }
            steps {
                sh 'trivy --no-progress image --scanners vuln georgeder/vulnerableapp:latest'
            }
        }
		stage('Push Docker Image') {
			steps {
				sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
				sh "docker push $DOCKER_IMAGE_NAME"
			}
		}
        stage('Scan YAML: Trivy'){
            when{
                expression{
                    params.execute_Trivy_yaml
                }
            }
            steps{
                sh 'sudo wget -P /tmp/vulnerableapp.yml https://raw.githubusercontent.com/GeorgiiDermenzhy/VulnerableApp/master/vulnerableapp.yml'
                sh 'trivy config /tmp/vulnerableapp.yml'
            }
        }
        stage('Deploy to Cluster') {
            steps {
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'vulnerableapp.yml',
                    enableConfigSubstitution: true
                )
            }
        }
        stage('DAST with OWASP ZAP'){
            when{
                expression{
                    params.execute_DAST
                }
            }
            steps{
                sh 'docker run -v "${PWD}:/zap/wrk/:rw" -t owasp/zap2docker-weekly zap-baseline.py -t http://10.0.0.11:32000/VulnerableApp/ -j --auto'
            }
        }
    }
}