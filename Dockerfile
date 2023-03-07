# Development Stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS development

SHELL ["/bin/bash", "-c"]
# Set a unique version for cache busting
ARG CACHEBUST=1

WORKDIR /src

# Copy just the .csproj files first for caching
COPY www/*.csproj ./

# Restore dependencies
RUN dotnet restore

# Copy the rest of the source code
COPY ./www .

# Set the entrypoint for running the app
ENTRYPOINT ["dotnet", "watch", "run"]


# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Set a unique version for cache busting
ARG CACHEBUST=1

WORKDIR /src

# Copy just the .csproj files first for caching
COPY www/*.csproj ./

# Restore dependencies
RUN dotnet restore

# Copy the rest of the source code
COPY ./www .

# Publish the app
RUN dotnet publish -c Release -o out


# Serve Stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS serve

RUN apk add --no-cache wget

# install the agent
RUN  mkdir /tmp/newrelic-dotnet-agent \
    && cd /tmp \
    && export NEW_RELIC_DOWNLOAD_URI=https://download.newrelic.com/$(wget -qO - "https://nr-downloads-main.s3.amazonaws.com/?delimiter=/&prefix=dot_net_agent/latest_release/newrelic-dotnet-agent" |  \
    grep -E -o "dot_net_agent/latest_release/newrelic-dotnet-agent_[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){2}_arm64\.tar\.gz") \
    && echo "Downloading: $NEW_RELIC_DOWNLOAD_URI into $(pwd)" \
    && wget -O - "$NEW_RELIC_DOWNLOAD_URI" | gzip -dc | tar xf -

#Remove wget
RUN apk del wget

#Get the NR license key from secret
RUN --mount=type=secret,id=newrelic_license_key \
    export NR_LICENSE_KEY=$(cat /run/secrets/newrelic_license_key)


# Set other New Relic agent configuration options
ENV CORECLR_ENABLE_PROFILING=1 \
    CORECLR_NEWRELIC_HOME=/tmp/newrelic-dotnet-agent \
    CORECLR_PROFILER_PATH=/tmp/newrelic-dotnet-agent/libNewRelicProfiler.so \
    NEW_RELIC_APPLICATION_LOGGING_ENABLED=true \
    NEW_RELIC_APPLICATION_LOGGING_METRICS_ENABLED=true \
    NEW_RELIC_APPLICATION_LOGGING_FORWARDING_ENABLED=true \
    NEW_RELIC_LICENSE_KEY=$NR_LICENSE_KEY \
    NEW_RELIC_APP_NAME=TEST_APP

WORKDIR /app
#Article: https://techcommunity.microsoft.com/t5/azure-developer-community-blog/hardening-an-asp-net-container-running-on-kubernetes/ba-p/2542224
ENV COMPlus_EnableDiagnostics=0
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_EnableDiagnostics=0
ENV DOTNET_USE_POLLING_FILE_WATCHER=1

RUN chown -R 1001:2000 /app

# Sort this out to not run as root!! ##
# Create the appusergroup group and appuser user
RUN addgroup -g 2000 appusergroup && \
    adduser -u 1001 -G appusergroup -D appuser

# Set the user to appuser
USER appuser
# Copy the published app from the build stage
COPY --from=build --chown=1001 /src/out .

#Cleanup

# Set the entrypoint
ENTRYPOINT ["dotnet", "docker-dotnet-api.dll", "--disable-features=FileWatching"]
