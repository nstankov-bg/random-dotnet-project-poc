## Motivation:

-   A demonstration of a modern infrastructure suite, with instrumentation and cloud-based development experience. The source itself, carries no value on its own, but this is rather an exercise in DevOps, around a random .NET application.

## Demo:

_Demos are so `2010`. Just head over to the [Pull Requests](https://github.com/nstankov-bg/random-dotnet-crm-poc/pull/2) section in Github, and experience the beauty of [Ehemerial Environments](https://ephemeralenvironments.io/) yourself!_

Yet still: https://app-nstankov-bg-random-dotnet-crm-poc-pr-2.cloud.okteto.net/api/weather

## 1 Minute Start

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=feature%2Fokteto-showoff&repo=609815328)

## 📜 SRC Description:

-   A random-off-the shelf stateless app ( because stateless means happy Ops ) app, that simulates a weather API at `/api/weather`

## 🚀 Features:

-   🐳 Uses [Docker Buildx](https://docs.docker.com/engine/reference/commandline/buildx/) for cross-architecture image builds (Welcome to the age of Apple Silicon)
-   🕸️ Uses [NewRelic](https://newrelic.com) as an [APM to establish tracing & basic SLAs](https://docs.newrelic.com/docs/apm/agents/net-agent/getting-started/introduction-new-relic-net/)
-   🐳 Uses [k3d](https://rancherdesktop.io) and/or [Compose](https://docs.docker.com/compose/compose-file/) with backwards compatibility for local development
-   🚀 Uses [Kompose](https://kompose.io/conversion/) for compose -> helm conversion
-   🚀 Uses [ArgoCD](https://www.youtube.com/watch?v=ffu7tGtjevU) for best practice deployments & ARM & self-healing
-   🛠️ Uses [Make](https://opensource.com/article/18/8/what-how-makefile) to establish quality of life improvements
-   🐛 Uses (now Grafana)[K6](https://k6.io/about/) (open source) to do Continuous Stress Testing & Implementation Testing cross-platform
-   🔗 Uses (Git-submodules)[https://github.blog/2016-02-01-working-with-submodules/] to establish basic repository templating
-   📝 Uses [EditorConfig](https://editorconfig.org) to establish basic code style
-   🛠️ Uses [Pre-Commit](http://pre-commit.com) to enforce style, very basic security and more.
-   🔭 Uses [Snyk](https://snyk.io) to establish more advanced security

## 🧪 BETA Features:

-   🐳 Compatible with [VSCode Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) for project setup & isolation ( 1m fast start )
-   🐳 Compatible with [Github CodeSpaces](https://github.com/features/codespaces) for project setup & isolation ( 1m fast start ), at an expense
-   🔭 Trying out [Hashicorp Waypoint](https://www.waypointproject.io), because why not.
-   📦 Uses [Okteto](https://www.okteto.com/videos/) to deploy [Ephemeral Environments](http://ephemeralenvironments.io) for testing, debugging, and reviewing
-   🐳 Uses [DockerSlim/Slim.ai](http://slim.ai) to reduce image size, and improve security(drastically).

## 🛠️TODO:

-   [ ] Implement SEMVER
-   [ ] Implement Github Actions for basic CI
