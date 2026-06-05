pipeline {
    agent any
    
    environment {
        // Docker Hub configuration
        DOCKER_HUB_USER = "kamleshdv"        // 🔁 Replace with your username
        IMAGE_NAME = "ecommerce-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        
        // 1. GITHUB SE CODE LANA
        stage('Checkout from GitHub') {
            steps {
                echo '📦 Pulling code from GitHub...'
                git branch: 'main', 
                    url: 'https://github.com/kamleshdv/e-commerce-application.git'  // 🔁 Replace
                echo '✅ Code pulled successfully'
            }
        }
        
        // 2. SONARQUBE SE TEST KARNA
        stage('SonarQube Code Test') {
            steps {
                echo '🔍 Testing code quality with SonarQube...'
                withSonarQubeEnv('sonarqube') {
                    sh 'sonar-scanner'
                }
                echo '✅ SonarQube analysis completed'
            }
        }
        
        // 3. QUALITY GATE CHECK (SonarQube ka result)
        stage('Quality Gate Check') {
            steps {
                echo '⏳ Waiting for SonarQube quality gate results...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                echo '✅ Quality Gate PASSED - Code is clean!'
            }
        }
        
        // 4. DOCKER IMAGE BANANA (Build)
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
                echo '✅ Docker image built successfully'
            }
        }
        
        // 5. TRIVY SE IMAGE TEST KARNA
        stage('Trivy Image Security Test') {
            steps {
                echo '🔒 Testing Docker image for vulnerabilities...'
                sh """
                    trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
                echo '✅ Trivy scan PASSED - No critical vulnerabilities!'
            }
        }
        
        // 6. SAB SHI HUA TO DOCKER HUB PUSH KARNA
        stage('Push to Docker Hub') {
            steps {
                echo '☁️ Pushing image to Docker Hub...'
                withCredentials([string(credentialsId: 'docker-hub-password', variable: 'DOCKER_PASS')]) {
                    sh """
                        docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_PASS}
                        docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest
                    """
                }
                echo '✅ Image successfully pushed to Docker Hub!'
            }
        }
        
    }
    
    post {
        success {
            echo '''
                ┌─────────────────────────────────────────────────────────┐
                │              🎉 DEPLOYMENT READY 🎉                     │
                ├─────────────────────────────────────────────────────────┤
                │  Image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}   │
                │  Ready for deployment!                                  │
                └─────────────────────────────────────────────────────────┘
            '''
        }
        failure {
            echo '''
                ┌─────────────────────────────────────────────────────────┐
                │              ❌ PIPELINE FAILED ❌                      │
                ├─────────────────────────────────────────────────────────┤
                │  Check logs for details:                               │
                │  - SonarQube quality gate failed?                      │
                │  - Trivy found vulnerabilities?                        │
                │  - Docker build error?                                 │
                └─────────────────────────────────────────────────────────┘
            '''
        }
    }
}
