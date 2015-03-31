# pnc-docker
An Automated build of docker image which contains WildFly, Aprox and Postgresql server prepared.
It can be easily used to deploy the [pnc](https://github.com/project-ncl/pnc) ear.

## what it provides

   * WildFly 8.2.0.Final started at port: `8080`, management port at: `9990`
      * This has postgresql driver and pnc datasource configured already:
         * jta datasource: `java:jboss/datasources/NewcastleDS`
         * db conn url: `jdbc:postgresql://localhost:5432/newcastle`
         * db username: `newcastle`
         * db password: `newcastle`
   * Aprox-launcher-savant-0.19.1 started at port: `8090`
   * Postgresql server started at port: `5432`
      * This has the `newcastle` database created, but no DDL imported yet.

## what it does not provides

   * No pnc ear deployments
      * The container needs a volume `/mnt/deployments` mounted on start up, the `ear-package.ear` can be put in
      the docker host machine, then use `-v /opt/pnc/deployments:/mnt/deployments` arguement to run the container.
   * No pnc database DDL script imported
      * the pnc ear will use `create-drop` for hibernate ddl import
   * No jenkins docker container prepared
      * pnc set up needs another docker container to run jenkins in it.
      * The docker jenkins container will be another one.
   

## pnc-config.json

The pnc-config.json:

```
{
"@class":"ModuleConfigJson","name":"pnc-config",
        "configs":[
          {
            "@module-config":"jenkins-build-driver",
            "username":"jenkins",
            "password":"jenkins"
          },
          {
            "@module-config":"maven-repo-driver",
            "baseUrl":"http://localhost:8090/api"
          },
          {
            "@module-config":"docker-environment-driver",
            "ip":"172.17.42.1",
            "inContainerUser":"jenkins",
            "inContainerUserPassword":"jenkins",
            "dockerImageId":"pnc-builder-0.3:1",
            "firewallAllowedDestinations":"192.30.252.131:80"
          }
        ]
}
```

## job-template.xml

```
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Free-style job config for testing</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.2.2">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>${scm_url}</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>${scm_branch}</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>${hudson.tasks.Shell.command}</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
```

## Command to start the container

Assume your pnc ear is located at: `/opt/pnc/deployments/` in the docker host,
then using following arguments to pass into the docker contaniner:

`docker run -d --name=pnc-docker -p 8080:8080 -p 8090:8090 -p 5432:5432 -v /opt/pnc/deployments/:/mnt/deployments/ -v /opt/pnc/config:/mnt/config aoingl/pnc-docker`


> Remember to copy the configuration files above into `/opt/pnc/config/pnc-config.json` and `/opt/pnc/config/job-template.xml`

This will redirect the host port to container.
