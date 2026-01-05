pipeline {
    agent { label 'agent1' }

    options {
        timeout(time: 10, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Pull raw Java code from Git"
                git branch: 'main', url: 'https://github.com/karthikeyan707/Jenkins_CI_pipeline.git'
            }
        }

        stage('Check Code') {
            steps {
                script {
                    if (fileExists('sampleapp/pom.xml')) {
                        env.CHECK = 'pass'
                    } else {
                        error "Invalid project structure"
                    }
                    echo "CHECK value is ${env.CHECK}"
                }
            }
        }

        stage('Maven Build') {
            when { environment name: 'CHECK', value: 'pass' }
            steps {
                echo "Start Maven build"
                dir('sampleapp') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'SonarScanner'
            }
            steps {
                withSonarQubeEnv('Sonar-Server') {
                    dir('sampleapp') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=newproject \
                        -Dsonar.projectName=newproject \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.jacoco.reportPath=target/coverage-reports/jacoco-unit.exec
                        """
                    }
                }
            }
        }

        stage('Push to Nexus') {
            environment {
                NEXUS_CREDS = credentials('nexus-creds')
                NEXUS_URL = 'http://35.91.37.127:8081/repository/jenkins/'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds',usernameVariable: 'NEXUS_USER',passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                       mvn deploy:deploy-file \
                       -Durl=http://35.91.37.127:8081/repository/jenkins/ \
                       -DrepositoryId=nexus \
                       -DgroupId=mavenbuild \
                       -DartifactId=myapp \
                       -Dversion=1.0-SNAPSHOT \
                       -Dpackaging=jar \
                       -Dfile=sampleapp/target/demo-1.0-SNAPSHOT.jar \
                       -Dusername=$NEXUS_USER \
                       -Dpassword=$NEXUS_PASS
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                        def myImage = docker.build("ukarthikeyan/myapp:latest")
                        myImage.push()
                    }
                }
            }
        }
        stage ('Deploy to EC2') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                        sh '''
                           docker pull ukarthikeyan/myapp:latest
                           docker run -d --name webapp -p 8080:8080 ukarthikeyan/myapp:latest
                        '''
                    }
                }
            }
        }
    }
}