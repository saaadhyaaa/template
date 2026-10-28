pipeline {
    agent any

    parameters {
        choice(
            name: 'VERSION',
            choices: ['v1', 'v2', 'v3'],
            description: 'Select application version'
        )
    }

    environment {
        // CHANGE: Your DockerHub username
        DOCKERHUB_USER = 'YOUR_DOCKERHUB_USERNAME'

        // CHANGE: Image repository name if required
        IMAGE_NAME = 'flask-lab-app'

        // Must match the credentials ID configured in Jenkins
        DOCKER_CREDENTIALS = 'dockerhub-creds'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                // Requires Python and pip on the Jenkins agent.
                sh 'python3 -m pip install -r requirements.txt'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.FULL_IMAGE =
                        "${env.DOCKERHUB_USER}/${env.IMAGE_NAME}:${params.VERSION}"
                }

                sh 'docker build -t "$FULL_IMAGE" .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKER_CREDENTIALS}",
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    sh '''
                        set +x
                        echo "$DH_TOKEN" | docker login \
                            -u "$DH_USER" \
                            --password-stdin

                        docker push "$FULL_IMAGE"

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def deploymentFile =
                        "k8s/deployment-${params.VERSION}.yaml"

                    def serviceFile =
                        "k8s/service-${params.VERSION}.yaml"

                    def deploymentName = "flask-${params.VERSION}"

                    sh """
                        kubectl apply -f ${deploymentFile}
                        kubectl apply -f ${serviceFile}

                        kubectl set image \
                            deployment/${deploymentName} \
                            ${deploymentName}=${env.FULL_IMAGE}

                        kubectl rollout status \
                            deployment/${deploymentName}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Flask ${params.VERSION} deployed successfully!"
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
