pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        SECRET_ID  = 'terraform/aws/jenkins'
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Stage: Checkout Repository"

                git branch: 'main', url: 'https://github.com/Mogeskebede/terraform-iam.git'

                echo "Repository checkout completed"
            }
        }

        stage('Get AWS Credentials') {
            steps {
                echo "Stage: Fetch AWS Credentials"

                script {
                    def secret = bat(
                        script: """
                        aws secretsmanager get-secret-value ^
                        --secret-id %SECRET_ID% ^
                        --region %AWS_REGION% ^
                        --query SecretString ^
                        --output text
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Secret retrieved successfully"

                    def creds = readJSON text: secret

                    env.AWS_ACCESS_KEY_ID     = creds.AWS_ACCESS_KEY_ID
                    env.AWS_SECRET_ACCESS_KEY = creds.AWS_SECRET_ACCESS_KEY
                    env.AWS_DEFAULT_REGION    = creds.AWS_DEFAULT_REGION

                    echo "AWS credentials set in environment"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                echo "Stage: Terraform Init"

                bat 'terraform init'

                echo "Terraform init completed"
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "Stage: Terraform Format Check"

                bat 'terraform fmt -check -recursive'

                echo "Terraform formatting check passed"
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "Stage: Terraform Validate"

                bat 'terraform validate'

                echo "Terraform validation successful"
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "Stage: Terraform Plan"

                bat 'terraform plan -out=tfplan'

                echo "Terraform plan generated"
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "Stage: Terraform Apply"

                bat 'terraform apply -auto-approve tfplan'

                echo "Terraform apply completed successfully"
            }
        }
    }

    post {
        success {
            echo "PIPELINE RESULT: SUCCESS"
            echo "All stages completed successfully."
        }

        failure {
            echo "PIPELINE RESULT: FAILURE"
            echo "One or more stages failed. Check logs above."
        }

        always {
            echo "Pipeline execution finished."
        }
    }
}