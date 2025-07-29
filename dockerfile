pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REGISTRY = '533267292058.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPO = 'demo-jenkins'
        IMAGE_TAG = 'latest'
    }

    stages {

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'id'  // Your Jenkins AWS credentials ID
                ]]) {
                    sh '''
                        echo "Logging into Amazon ECR..."
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Pull Docker Image') {
            steps {
                sh '''
                    echo "Pulling Docker image from ECR..."
                    docker pull $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                    echo "Stopping and removing old container if exists..."
                    docker stop ecr-nginx || true
                    docker rm ecr-nginx || true

                    echo "Running Docker container..."
                    docker run -d -p 8080:80 --name ecr-nginx $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
                '''
            }
        }
    }
}
