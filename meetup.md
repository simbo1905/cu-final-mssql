
# Run on Redhat Container Development Kit (on MacOS)

## Checkout and build the code using .Net Core (aka `dotnet`)

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

## Install the Redhat OpenShift Container Developer Kit (CDK)

The CDK is a single binary which setups OpenShift within a Virtual Machine.
The default virtual machine runtime is Virtual Box and the CDK installer will
install the correct version if you don't already have it.  

Before you can download and use the CDK, you need a _no_cost_ Red Hat Enterprise
Linux Developer Suite subscription. This is so that it can register a RHEL7 virtual machine
which is what the commercially supported version of OpenShift is supported on.

You do not want to install everything provided in the installation binary. You can select
only the CDK during the install. This is a single `minishift` which is typically installed at
`/Applications/DevelopmentSuite/cdk/bin/minishift`. You may need to `chmod +x /Applications/DevelopmentSuite/cdk/bin/minishift`
and add it to your path.

Information can be found:

https://developers.redhat.com/products/cdk/overview/

Before you run the commands to setup the VM you need to export your redhat developer
account details. This is used to register the OS running in the VM which is RHEL7.
To do this edit this little script to use your redhat login and then run it:

```
#!/usr/bin/env bash
# Copied from https://github.com/jhcook/game_engine/blob/master/openshift/minishift_boot.sh
# This sets the appropriate environment variables, creates a CDK with access
# to appropriate insecure registries and allows transparent access.
#
# Author: Justin Cook <jhcook@secnix.com>

# Check if we have an environment that will work

export MINISHIFT_USERNAME="jhcook@secnix.com"
echo "Please enter your RHDS Password: "
read -sr MINISHIFT_PASSWORD_INPUT
export MINISHIFT_PASSWORD=$MINISHIFT_PASSWORD_INPUT

minishift start --vm-driver virtualbox
```

If it fails (I got a network timeout first time) use `minishift delete` and retry.

If you get stuck try these instructions:

- https://www.youtube.com/watch?v=UxwBB0_-9VM
- https://access.redhat.com/documentation/en-us/red_hat_container_development_kit/3.0/html/installation_guide/

## Start Minishift ("Mini OpenShift")

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
