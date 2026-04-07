pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
    }

    stages {

        stage('Checkout') {
            steps {
                echo "STAGE: Checkout Repository"

                git branch: 'main', url: 'https://github.com/Mogeskebede/terraform-iam.git'

                echo "Repository checkout completed successfully"
            }
        }

        stage('Set AWS Credentials') {
            steps {
                echo "STAGE: Inject AWS Credentials from Jenkins"

                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_Credentials']]) {
                    script {
                        echo "AWS credentials injected from Jenkins credentials store"

                        // Export credentials as environment variables for Terraform & AWS CLI
                        env.AWS_ACCESS_KEY_ID     = AWS_ACCESS_KEY_ID
                        env.AWS_SECRET_ACCESS_KEY = AWS_SECRET_ACCESS_KEY
                        env.AWS_DEFAULT_REGION    = AWS_REGION

                        echo "AWS environment variables configured"
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                echo "STAGE: Terraform Init"
                bat 'terraform init'
                echo "Terraform initialization completed"
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "STAGE: Terraform Format Check"
                bat 'terraform fmt -check -recursive'
                echo "Terraform formatting check completed"
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "STAGE: Terraform Validate"
                bat 'terraform validate'
                echo "Terraform validation completed successfully"
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "STAGE: Terraform Plan"
                bat 'terraform plan -out=tfplan'
                echo "Terraform plan generated successfully"
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "STAGE: Terraform Apply"
                bat 'terraform apply -auto-approve tfplan'
                echo "Terraform apply completed successfully"
            }
        }
    }

    post {
        success {
            echo "PIPELINE RESULT: SUCCESS"
            echo "All stages completed successfully"
        }

        failure {
            echo "PIPELINE RESULT: FAILURE"
            echo "One or more stages failed. Review logs above."
        }

        always {
            echo "Pipeline execution finished"
        }
    }
}