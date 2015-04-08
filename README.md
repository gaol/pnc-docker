# pnc-docker
An Automated build of docker image which contains WildFly, Aprox and Postgresql server prepared.
It can be easily used to deploy the [pnc](https://github.com/project-ncl/pnc) ear.

## what it provides

   * WildFly 8.2.0.Final started at port: `8080`, management port at: `9990`
   * Aprox-launcher-savant-0.19.1 started at port: `8090`

## what it does not provides

   * It needs docker image: `mareknovotny/pnc-jenkins:v0.3`

## Command to start the container

Assume your pnc ear is located at: `/opt/pnc/deployments/` in the docker host,
and the config files above are located at: `/opt/pnc/config/` in the docker host,
then using following arguments to pass into the docker contaniner:

`docker pull mareknovotny/pnc-jenkins:v0.3`
`docker run -d --name=pnc-docker-local -p 8080:8080 aoingl/pnc-docker:postbuild`

Then you can visit the pnc project at: `http://127.0.0.1:8080/pnc-web/`

> Make sure your docker daemon runs at: `-H tcp://0.0.0.0:2375`, the port is hardcoded in pnc currently.
