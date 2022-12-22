@Library('jenkins-library@opensource-release') _
dockerImagePipeline(
  script: this,
  service: 'cmd-nsmgr',
  dockerfile: 'Dockerfile',
  buildContext: '.',
  buildArguments: [PLATFORM:"amd64"]
)
