FROM microsoft/dotnet:1.1.1-runtime
WORKDIR /app
COPY out /app
 
EXPOSE 5000/tcp
ENV ASPNETCORE_URLS http://*:5000
 
ENTRYPOINT ["dotnet", "ContosoUniversity.dll"]
