
## Run SQLServer on Linux and the demo app with Openshift Origin PaaS on Mac OS

*These instructions are out of date see [meetup.md](meetup.md) instead!

First build the production release container which doesn't need a writable file system:

```
# build the production version
dotnet publish -c Release -o out
docker build -t cu-final-mssql .
```

If you have private containers you are going to have to "docker push" into the docker repo OpenShift will start up below. With opensource code is far easier to deploy via your own free account on docker hub:

```
# in the following commands you need to change "username" to be your docker hub user name
docker login
docker tag cu-final-mssql username/cu-final-mssql:latest
docker push username/cu-final-mssql:latest
```

_Personal Opinion:_ There are multiple ways to run Openshift PaaS on Mac and I found the old ways a real headache. The latest Openshift Origin "oc cluster up" approach is a breath of fresh air. I really wanted to use the enterprise distro but that doesn't yet support this developer friendly approach.

At the time of writing Openshift parsed the latest stable Docker for Mac version number as being an unstable version number so refused to run. I had to downgrade to the previous stable Docker for Mac.

First create the machine if it is the first time. Note the use of the stable Origin 1.5.0 "oc" binary which has the cluster up feature and the use of the "v1.5.0-alpha.3" version of the cluster being brought up:

```
# CREATE MACHINE here change the host data folder to your own folder
../openshift-origin-client-tools-v1.5.0/oc cluster up --version=v1.5.0-alpha.3 --create-machine=true   \
                --use-existing-config   \
                --host-data-dir=/Users/you/oc_data \
                --metrics=false
```

Now run the machine:

```
# RUN CLUSTER here change the host data folder to your own folder
../openshift-origin-client-tools-v1.5.0/oc cluster up --version=v1.5.0-alpha.3   \
                --use-existing-config   \
                --host-data-dir=/Users/you/oc_data  \
                --metrics=false
```

_Personal Opinion:_ While that all sounded a bit buggy I think the tools are in general good and stable. It is just that I used a very convenient bleeding edge feature on Mac rather than Linux so I found some wet paint. The Openshift devs where helpful in offering work arounds to folks running into these issues on Mac and were scheduling the fixes as I went press. I blame the next issue below on having to run the alpha versions.

If you now run ```docker ps``` you should now see a load of Openshift services running in their own containers.

In the following when I created a project on the command-line I got access denied trying to access it on the web console. If you run into that issue run `oc delete project cu-final-mssql` and recreated it via the web console.

Deploy SQLServer into Openshift (OMG!):

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
1> select * from  [dbo].[OfficeAssignment];                                                                                                                           
2> G0
```

Then deploy the app via the web console:

1. Log in to the web console the url is shown at the bottom of the `oc cluster up` output
2. Open the project
3. Browse to the mssql *service* and note down its IP address on its details page.
4. Click Add to Project at the top
5. Deploy image
6. Select Image Name and paste in your image path on dockerhub e.g. `username/cu-final-mssql:latest`
7. Click on the search icon and wait for it to load the details. Ignore the warning about root user.
8. Set an Environment Variable "ConnectionStrings__DefaultConnection" with the following value edited to contain the database service IP address `Server=172.30.219.45;Database=mydatabase;User Id=sa;Password=<YourStrong!Passw0rd>`
9. Click on Create
10. Check that everything deployed correctly. On the pod log it should say its listening on port 5000.
11. On the Overview click on "Create Route" for the CU FINAL MSSQL service. Just hit Create.
12. The overview should show a http link to an xip.io url which opens a browser pointing at your apps IP address.
13. Navigate to the Student tab and click Create New to confirm you can write to the dataase.
