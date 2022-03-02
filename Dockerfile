FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y \
        nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY ["SpookifyBot.csproj", "SpookifyBot/"]
RUN dotnet restore "SpookifyBot/SpookifyBot.csproj"
WORKDIR "/src/SpookifyBot"
COPY . .
RUN dotnet build "SpookifyBot.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SpookifyBot.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# ENTRYPOINT [ "dotnet", "SpookifyBot.dll" ]
# Use the following instead for Heroku
CMD ASPNETCORE_URLS=http://*:$PORT dotnet SpookifyBot.dll