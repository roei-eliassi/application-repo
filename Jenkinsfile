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

        stage('Set Image Tag') {
            steps {
                script {
                    if (env.CHANGE_ID) {
                        env.IMAGE_TAG = "pr-${CHANGE_ID}-${BUILD_NUMBER}"
                    } else {
                        env.IMAGE_TAG = "${BUILD_NUMBER}"
                    }

                    echo "Building image tag: ${IMAGE_TAG}"
                }
            }
        }


        stage('Build Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }


        stage('Unit Tests') {
            steps {
                sh """
                    docker run --rm \
                    ${IMAGE_NAME}:${IMAGE_TAG} \
                    python3 -m unittest discover tests
                """
            }
        }


        stage('Install AWS CLI') {
            steps {
                sh """
                    apk add --no-cache aws-cli
                    aws --version
                """
            }
        }


        stage('Push to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}


                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} \
                    ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}


                    docker push \
                    ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}


                    echo "Pushed image:"
                    echo "${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
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


                    docker pull \
                    ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}


                    docker run -d \
                    --name calculator \
                    --restart unless-stopped \
                    -p 5000:5000 \
                    ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
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

                    apk add --no-cache curl

                    curl --fail http://10.0.1.226:5000/health
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
