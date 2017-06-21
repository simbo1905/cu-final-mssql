
# Run on Redhat Container Development Kit (on MacOS)

## Install the CDK and setup VM

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

## Checkout and build the code

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

Now create a new project and deploy the database:

```
# login to Openshift
oc login -u system:admin
# see warning above about perhaps not being able to login to this project
oc new-project cu-final-mssql
# in case this your second attempt after having to create the project via the web console
oc project cu-final-mssql
# check you have the volume I used in the pvc.yaml
oc get pv | fgrep pv0002
# If you didn't find it you are going to have to author some yaml to create it
# Create the persistent volume claim:
cat pvc.yaml | oc create -f -
# create the "mssql" SQLServer POD:
cat mssql_pod.yaml | oc create -f -
# create the "mssql" SQLServer service:
cat mssql_service.yaml | oc create -f -
```

Login to the web console and click on the logs tab of the POD check it is healthy.

You now need to run the `SQLServer.sql` against the database to create the tables.
Rather than creating a new image with the sql file in it with a mechanism
to start it I cheated. I logged into the openshift web console, selected the pod,
click on the Terminal tab, and open the sqlcmd tool and pasted in the SQL:

```
# Log in to the web console the url is shown at the bottom of the `oc cluster up` output
# open the Terminal tab of the pod to get into the running container
# check the sqlcmd tool is there
find / -name sqlcmd
# login to the local SQLServer as SA
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1 -U SA -P '<YourStrong!Passw0rd>'
# now paste the sql from SQLServer.sql. the terminal will badly format it. hit enter.
...
# check that the last table got created by querying form it:
1> select * from [dbo].[OfficeAssignment];                                                                                                                           
2> G0
```

Then deploy the app:

```
# create the "frontend" deployment. Note you need to edit the yaml file to name your own docker hub login name:
cat frontend_deployment.yaml | oc create -f -
# create the "frontend" service:
cat mssql_service.yaml | oc create -f -
```

Now login to the openshift console: 

1. Log in to the web console the url is shown at the bottom of the `minishift start` output
1. Open the project `cu-final-mssql`
1. Browse to the `mssql` *service* and note down its IP address on its details page.
1. Open the `frontend` *deployment* config and edited teh Environment Variable "ConnectionStrings__DefaultConnection" so set the IP of the mssql service.
1. Open the `frontend` *service* and click on action and create a Route
1. The overview should show a http link to an xip.io url which opens a browser pointing at your apps IP address.
1. Navigate to the Student tab and click Create New to confirm you can write to the dataase.

Enjoy!
