dotnet new console -o myApp
cd myApp
dotnet run


cd aspnetapp
dotnet run

cd aspnetapp
docker build -t aspnetapp .
docker run -it --rum -p 5000:80 --name aspnetcore_sample aspnetapp
