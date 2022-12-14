FROM mcr.microsoft.com/dotnet/aspnet:3.1-focal AS base
WORKDIR /app
EXPOSE 7999

ENV ASPNETCORE_URLS=http://+:7999

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:3.1-focal AS build
WORKDIR /src
COPY ["container_sample.csproj", "./"]
RUN dotnet restore "container_sample.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "container_sample.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "container_sample.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "container_sample.dll"]
