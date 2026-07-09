pipeline {
    agent {
        docker {
            image 'docker:29-cli'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        AWS_REGION   = "il-central-1"
        ECR_REGISTRY = "992382545251.dkr.ecr.il-central-1.amazonaws.com"
        IMAGE_NAME   = "roeicicd"
    }

    stages {

        stage('Build Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                """
            }
        }

        stage('Unit Tests') {
            steps {
                sh """
                    docker run --rm \
                        ${IMAGE_NAME}:${BUILD_NUMBER} \
                        python3 -m unittest discover tests
                """
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} \
                        ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}

                    docker push \
                        ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }

            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker stop calculator || true
                    docker rm calculator || true

                    docker pull ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}

                    docker run -d \
                        --name calculator \
                        --restart unless-stopped \
                        -p 5000:5000 \
                        ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        stage('Health Verification') {
            when {
                branch 'main'
            }

            steps {
                sh """
                    echo "Waiting for application..."

                    sleep 10

                    curl --fail http://localhost:5000/health
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }

        failure {
            echo "Pipeline failed!"
        }
    }
}
