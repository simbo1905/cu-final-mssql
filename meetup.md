
# Run on Redhat Container Development Kit (on MacOS)

## Checkout and build the code (Optional requires `dotnet` installation)

Here we build the production release container which doesn't need a writable file system:

```
# checkout the code
git clone https://github.com/simbo1905/cu-final-mssql.git
# build the production version
dotnet restore
dotnet publish -c Release -o out
docker build -t cu-final-mssql .
```

If you have private containers you are going to have to "docker push" into the
docker repo OpenShift will start up below. With opensource code is far easier to
deploy via your own free account on docker hub:

```
# in the following commands you need to change "username" to be your docker hub user name
docker login
docker tag cu-final-mssql username/cu-final-mssql:latest
docker push username/cu-final-mssql:latest
```

## Install the CDK and setup VM (Optional if already installed)

Before you can download and use the CDK, you need a no-cost Red Hat Enterprise
Linux Developer Suite subscription. Information can be found:

https://developers.redhat.com/products/cdk/overview/

A brief video to show you installing the CDK can be found on YouTube here:

Setting up Red Hat Development Suite

https://www.youtube.com/watch?v=UxwBB0_-9VM

The written instructions can be found here:

Red Hat CDK Installation Guide

https://access.redhat.com/documentation/en-us/red_hat_container_development_kit/3.0/html/installation_guide/

If you do not want to install everything provided in the image, you can select
the CDK during the install. It also defaults to using  Virtual Box to run the
VM containing the solution which the installer will install for you.

The CDK installs a single binary `minishift` which is typically installed at
`/Applications/DevelopmentSuite/cdk/bin/minishift`. You may need to `chmod +x /Applications/DevelopmentSuite/cdk/bin/minishift`
and add it to your path.

Before you run the commands to setup the VM you need to export your redhat developer
account details. This is used to register the OS running in the VM which is RHEL7:

```
export MINISHIFT_USERNAME=x@y.com
export MINISHIFT_PASSWORD=xxx
```

Then run the setup command:

```
minishift setup-cdk --default-vm-driver virtualbox
```

If it fails (I got a network timeout first time) use `minishift delete` and retry.

## Start Minishift

Start the environment with `minishift start` which will setup your terminal to interact with openshift and
output you login details to the cluster:

```
-- Server Information ...
   OpenShift server started.
   The server is accessible via web console at:
       https://192.168.99.102:8443

   You are logged in as:
       User:     developer
       Password: developer

   To login as administrator:
       oc login -u system:admin
```

## Deploy the application and database

If you haven't yet obtained the code do so with:

```
git clone https://github.com/simbo1905/cu-final-mssql.git
```

Now create a new project and deploy the database:

```
# login to Openshift
oc login -u system:admin
# see warning above about perhaps not being able to login to this project
oc new-project cu-final-mssql
# create the application
oc new-app application-template.json
```

I didn't have time to alter the application to have it create the database tables.
So login into the openshift web console (url shown in the outpout of `minishift start`),
selected the `Application > Pods` and open the database pod, then click on the Terminal tab:

```
# download the sql
wget https://raw.githubusercontent.com/simbo1905/cu-final-mssql/master/SqlServer.sql
# run it into the database
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1 -U SA -P $SA_PASSWORD -i SqlServer.sql
```

Now login to the openshift console to set a nip.io route to browse the app:

1. Log in to the web console the url is shown at the bottom of the `minishift start` output
1. Open `Applications > Route` then open the frontend route and use the Action button to delete it
1. Open `Applications > Services` then open the frontend service and use the Action to create a route using the defaults
1. The overview should show a http link to an xip.io url which opens a browser pointing at your apps IP address.
1. Navigate to the Student tab and click Create New to confirm you can write to the database.

See also this blog about remote debugging C# inside of Openshift: http://redhat.slides.com/tatanaka/getting-started-with-asp-net-core-on-openshift?token=UUDdJFUs#/

Enjoy!
