pipeline {
    agent {
        docker {
            image 'docker:24.0-dind'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        AWS_REGION   = "il-central-1"
        // TODO: replace ACCOUNT_ID below with your real 12-digit AWS Account ID
        // Get it by running: aws sts get-caller-identity --query Account --output text
        ECR_REGISTRY = "ACCOUNT_ID.dkr.ecr.il-central-1.amazonaws.com"
        IMAGE_NAME   = "roeicicd"
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
                // TODO: paste your existing integration test steps here
                // (pull image from ECR, run as container, run integration tests)
                sh 'echo "integration tests go here"'
            }
        }
        stage('CD - Deploy') {
            steps {
                // TODO: paste your existing deploy steps here
                // (e.g. aws ecs update-service ...)
                sh 'echo "deploy steps go here"'
            }
        }
    }
}
