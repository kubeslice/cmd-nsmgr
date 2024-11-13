@Library('jenkins-library@opensource-release-multiarch') _
dockerImagePipeline(
  script: this,
  services: ['cmd-nsmgr'],
  dockerfiles: ['Dockerfile'],
  pushed: true,
  buildArgumentsList: [
    [ENV: 'production', PLATFORM: 'linux/arm64,linux/amd64']
]  
)
