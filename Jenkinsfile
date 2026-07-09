pipeline {
    agent {
        docker { 
            image 'docker:24.0-dind' 
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock' 
        }
    }
    
    environment {
        AWS_REGION = "il-central-1"
        ECR_REGISTRY = "54.157.34.222.dkr.ecr.il-central-1.amazonaws.com"
        IMAGE_NAME = "roeicicd"
    }

    stages {
        stage('CI - Unit Tests') {
            steps {
                sh 'apk add --no-cache python3 py3-pip aws-cli'
                sh 'pip install --break-system-packages -r requirements.txt'
                sh 'python3 -m unittest discover tests/unit'
            }
        }

        stage('Build & Push') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }

        stage('CD - Integration Tests') {
            steps {
                sh "docker pull ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                sh "docker run -d --name integration-test-app ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                sh 'python3 tests/integration/run_integration_tests.py'
                sh 'docker stop integration-test-app && docker rm integration-test-app'
            }
        }

        stage('CD - Deploy') {
            steps {
                echo "Deploying to production..."
            }
        }
    }
}
