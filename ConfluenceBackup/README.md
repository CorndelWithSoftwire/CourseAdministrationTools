Corndel Confluence Backup
=========================

Script to backup contents of Corndel Confluence, https://corndel.atlassian.net/wiki/

Designed to be run via Jenkins, eg:

```
node {
    stage("Backup") {
        withCredentials([usernamePassword(credentialsId: 'AwsJenkinsAccessKey', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            withCredentials([usernamePassword(credentialsId: 'ConfluenceJenkinsUser', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                git url: "git@github.com:CorndelWithSoftwire/CourseAdministrationTools.git", credentialsId: "db9fa8c4-2a99-49e7-840b-2a0323095f50"
                dir ("ConfluenceBackup") {
                    sh "bash ./run.sh"
                }
            }
        }
    }
}
```
