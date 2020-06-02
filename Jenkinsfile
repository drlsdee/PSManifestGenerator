pipeline{
    parameters {
        string defaultValue: 'http://gitea00.mmc.local:3000', description: 'Git SCM URI', name: 'ScmUri', trim: true
        string defaultValue: 'mmc.local', description: 'Git repo owner\'s name', name: 'ownerName', trim: true
        string defaultValue: '', description: 'Repository name', name: 'RepoName', trim: true
        string defaultValue: 'JenkinsSvc-GitGeneral', description: 'SCM credentials ID', name: 'credsID', trim: true
        string defaultValue: '', description: 'Set new GUID if needed', name: 'newGuid', trim: true
        booleanParam defaultValue: false, description: 'Increment major version', name: 'IncrementMajor'
        booleanParam defaultValue: false, description: 'Increment minor version', name: 'IncrementMinor'
        string defaultValue: "${BUILD_NUMBER}", description: 'Set build number', name: 'numberOfBuild', trim: true
    }
    agent any
    stages{
        stage("Build the module PSManifestGenerator itself"){
            when {
                environment name: 'RepoName', value: ''
            }
            steps{
                echo "====++++executing Build the module PSManifestGenerator itself++++===="
                powershell label: 'Get-ChildItem', returnStatus: true, script: "Get-ChildItem -Path ${WORKSPACE}"
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Build the module PSManifestGenerator itself executed successfully++++===="
                }
                failure{
                    echo "====++++Build the module PSManifestGenerator itself execution failed++++===="
                }
        
            }
        }
        stage("Checkout PS Module"){
            when {
                not {
                    environment name: 'RepoName', value: ''
                }
            }
            steps{
                echo "====++++executing Checkout PS Module ${RepoName}++++===="
                checkout(
                    [
                        $class: 'GitSCM',
                        branches: [
                            [
                                name: '*/master'
                            ]
                        ],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [
                            [
                                $class: 'CleanBeforeCheckout',
                                deleteUntrackedNestedRepositories: true
                            ],
                            [
                                $class: 'CleanCheckout',
                                deleteUntrackedNestedRepositories: true
                            ],
                            [
                                $class: 'RelativeTargetDirectory',
                                relativeTargetDir: "${RepoName}"
                            ]
                        ],
                        submoduleCfg: [],
                        userRemoteConfigs: [
                            [
                                credentialsId: 'JenkinsSvc-GitGeneral',
                                url: "${ScmUri}/${ownerName}/${RepoName}.git"
                            ]
                        ]
                    ]
                )
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Checkout PS Module ${RepoName} executed successfully++++===="
                }
                failure{
                    echo "====++++Checkout PS Module ${RepoName} execution failed++++===="
                }
        
            }
        }
        stage("Build manifest for PS module"){
            when {
                not {
                    environment name: 'RepoName', value: ''
                }
            }
            steps{
                echo "====++++executing Build manifest for PS module ${RepoName}++++===="
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Build manifest for PS module ${RepoName} executed successfully++++===="
                }
                failure{
                    echo "====++++Build manifest for PS module ${RepoName} execution failed++++===="
                }
        
            }
        }
        /* stage("Checkout the module PSManifestGenerator"){
            steps{
                echo "====++++executing Checkout the module PSManifestGenerator++++===="
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Checkout the module PSManifestGenerator executed successfully++++===="
                }
                failure{
                    echo "====++++Checkout the module PSManifestGenerator execution failed++++===="
                }
        
            }
        } */
    }
    post{
        always{
            echo "========always========"
        }
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}