pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
		node('p') {
                	echo 'Building..'
		}
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
