pipeline {
    agent any
    environment { 
        KUBECTL_SCRIPT = './kubectl_apply.sh' 
        NODE_CONFIG_FILE = 'admin.conf'
    }
    stages {
        stage('Fetch Node Configurations') {
            steps {
                echo 'Fetching node configurations from the previous pipeline...'
                script {
                    if (!fileExists(env.NODE_CONFIG_FILE)) {
                        error "Node configuration file (${env.NODE_CONFIG_FILE}) not found!"
                    }
                    echo "Node configurations loaded from ${env.NODE_CONFIG_FILE}."
                }
            }
        }
        stage('Run kubectl_apply.sh') {
            steps {
                echo 'Running kubectl_apply.sh...'
                script {
                    if (!fileExists(env.KUBECTL_SCRIPT)) {
                        error "kubectl_apply.sh script (${env.KUBECTL_SCRIPT}) not found!"
                    }
                    sh env.KUBECTL_SCRIPT
                }
            }
        }
    }
    post {
        always {
            echo 'Pipeline execution completed.'
        }
        success {
            echo 'Pipeline executed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}