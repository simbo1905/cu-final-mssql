# "Contoso University" ASP.NET Core and Entity Framework Core with SQLServer on Docker (Linux/Mac)

"Contoso University" demonstrates how to use Entity Framework Core in an
ASP.NET Core MVC web application. This repository makes minor patches to be
able to configure the connection settings via Environment Variables.

There are instructions at [meetup.md](meetup.md) showing how to run it in OpenShift PaaS on Mac OS.

The original demo webapp material is at https://github.com/aspnet/Docs/tree/master/aspnetcore/data/ef-mvc/intro/samples/cu-final

The code isn't aiming for production quality as its a quick alpha spike. By way of example the logging of SQL strings happens in production builds. In a real application you would use the DotNet core convensions of checking a standard Env Var to enable or disable it. Still those modifications are easy to make so why not have a go and send me a PR.

Just be clear these steps work on my Mac Book Pro running an official preview edition of the next major release of SQLServer which runs on Linux using a Microsoft supplied docker image.

## Run It with Docker on Mac OS

_Personal Opinion:_ I recommend using "Docker for Mac" as there is less messing around with network issues than using a brew install of Docker Engine. Visual Studio 2017 now has good support for "Docker for Windows" so the Docker native tooling seems to be something that Microsoft are getting behind.

SQLServer wont get out of bed for less than 3.5G RAM so you need to up your memory settings on Docker for Mac and restart it. Then start up SQLServer on under docker with:

```
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=<YourStrong!Passw0rd>' -p 1433:1433 -d microsoft/mssql-server-linux
```

In the real world you would have the app generate the tables however we need to
do this manually: 

```
# replace d961b29f54df with your container uid shown using "docker ps"
docker cp SqlServer.sql d961b29f54df:/var/opt/mssql/data/SqlServer.sql
# login
docker exec -it d961b29f54df bash
# this will only outpout "Changed database context to 'mydatabase'."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong!Passw0rd>' -i /var/opt/mssql/data/SqlServer.sql
# query a table to check it is there. use exit twice to quite out to the host
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong!Passw0rd>'
1> use mydatabase;
2> GO
Changed database context to 'mydatabase'.
1> select * from [dbo].[OfficeAssignment];
2> GO
InstructorID Location                                          
------------ --------------------------------------------------

(0 rows affected)
1>
```

You can also use Visual Studio Code the free cross platform IDE to execute SQL against MS SQLServer following the instructions at https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-develop-use-vscode

Now set the Environment Variables which points to that database and build and run the code against it:

```
DATABASE_SERVICE_HOST=127.0.0.1
export DATABASE_SERVICE_HOST
MSSQL_DATABASE=mydatabase
export MSSQL_DATABASE
MSSQL_USER=sa
export MSSQL_USER
MSSQL_PASSWORD=""<YourStrong"'!'"Passw0rd>"
export MSSQL_PASSWORD
dotnet restore
dotnet run
```

It should come up on http://localhost:5000 and allow you to query or create students etc.

## Run with RedHat Container Platform (Openshift v3) PaaS on Mac OS

See [meetup.md](meetup.md)

Enjoy!
