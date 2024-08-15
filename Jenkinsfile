pipeline {
    agent any

    tools {
        jdk 'jdk17'
        nodejs 'nodejs16'
    }

    environment {
        SCANNER_HOME = tool name: 'sonar'
    }

    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        
        stage('git pull') {
            steps {
                git branch: 'main', url: 'https://github.com/gyenoch/Three-tier-Application-Deployment.git'
            }
        }

        stage('Owaps fs scan') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'DC'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('trivy fs scan') {
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }

        stage('sonarqube analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=three-tier-app \
                    -Dsonar.projectKey=three-tier-app '''
                }
            }
        }

        stage("quality gate"){
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }

        stage('install nodejs dependencies backend') {
            steps {
                dir('backend') { // Corrected path
                    sh 'npm install'
                }
            }
        }

        stage('install nodejs dependencies frontend') {
            steps {
                dir('frontend') { // Corrected path
                    sh 'npm install'
                }
            }
        }

        stage('Stop and Remove Specific Containers') {
            steps {
                script {
                    sh '''
                    CONTAINERS="ng_frontend ng_backend mongodb"
                    for CONTAINER in $CONTAINERS; do
                        if [ "$(docker ps -q -f name=$CONTAINER)" ]; then
                            docker stop $CONTAINER
                            docker rm $CONTAINER
                        fi
                    done
                    '''
                }
            }
        }

        stage('docker container deploy') {
            steps {
                dir('app') {
                sh 'docker-compose up -d' 
                }
            }
        }

        stage('run command to tag local images') {
            steps {
                sh 'docker tag app_backend gyenoch/three-tier-app_backend:latest'
                sh 'docker tag app_frontend gyenoch/three-tier-app_frontend:latest'
                sh 'docker tag mongo:4.4.6 gyenoch/three-tier-app:database'
            }
        }

        stage("TRIVY SCAN") {
            steps {
                sh "trivy image gyenoch/three-tier-app_backend:latest >> trivyimage.txt"
                sh "trivy image gyenoch/three-tier-app_frontend:latest >> trivyimage.txt"
                sh "trivy image gyenoch/three-tier-app:database >> trivyimage.txt"
            }
        }

        stage('run command to push images') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'three-tier-app-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh 'docker push gyenoch/three-tier-app_backend:latest'
                        sh 'docker push gyenoch/three-tier-app_frontend:latest'
                        sh 'docker push gyenoch/three-tier-app:database'
                    }
                }
            }
        }
    }
}
