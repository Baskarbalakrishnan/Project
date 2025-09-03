// Jenkinsfile
pipeline {
  agent any

  environment {
    DOCKERHUB_USER = "baskarb"
    IMAGE_NAME = "baskarb/project"
    IMAGE_TAG = "latest"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh 'echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin'
          sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
        }
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        dir('infra') {
          withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                           string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh 'terraform init'
            sh 'terraform apply -auto-approve -var="docker_image=$IMAGE_NAME:$IMAGE_TAG" -var="key_name=$KEY_NAME"'
          }
        }
      }
      environment {
        KEY_NAME = "${params.KEY_NAME ?: 'Severs Key Pair BN'}"
      }
    }

    stage('Deploy to EC2') {
  steps {
    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-key', 
                                       keyFileVariable: 'EC2_KEY', 
                                       usernameVariable: 'EC2_USER')]) {
      sh '''
        EC2_PUBLIC_IP=$(terraform -chdir=infra output -raw public_ip)

        ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_PUBLIC_IP \
          "docker rm -f devops-app || true &&
           docker pull $IMAGE_NAME:$IMAGE_TAG &&
           docker run -d --restart unless-stopped -p 80:3000 --name devops-app $IMAGE_NAME:$IMAGE_TAG"
      '''
    }
  }
}

  parameters {
    string(name: 'KEY_NAME', defaultValue: 'Severs Key Pair BN', description: 'EC2 key pair name')
  }
}
