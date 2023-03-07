# Define variables
DOCKER_IMAGE_NAME = test-dotnet-app-public
DOCKER_REGISTRY = docker.io
DOCKER_REPO = nikoogle
DOCKER_TAG = latest
DOCKER_PLATFORMS = linux/arm64,linux/amd64
DOCKER_TARGET = runtime

BASE_FOLDER = yy-IaC/tests
BASE_INTEGRATION_FOLDER = integration
BASE_LOAD_FOLDER = stress
ENDPOINT_TO_BE_TESTED = api/weather
LOAD_TEST_SCRIPT = load-test.js
SOAK_TEST_SCRIPT = soak-test.js
INTEGRATION_TEST_SCRIPT = integration-test.js

# Define phony targets
.PHONY: all build combo down extract git-all hosts-entry integration-test kompose load-test portfwd soak-test up

# Define targets
all: combo

utility-www:
	git submodule add https://github.com/yemiwebby/docker-dotnet-api.git www

build: git-release #Still uses this, as Kaniko via Waypoint does not yet support passing secrets
	docker buildx build \
		--platform $(DOCKER_PLATFORMS) \
		--build-arg DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
		--build-arg DOCKER_REPO=$(DOCKER_REPO) \
		--secret id=newrelic_license_key,env=NR_LICENSE_KEY \
		--tag $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$(DOCKER_IMAGE_NAME):$(VERSION) \
		--tag $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$(DOCKER_IMAGE_NAME):latest \
		--target serve \
		. --no-cache


local-up:
	docker compose up

local-down:
	docker compose down --remove-orphans

local-combo: down build up

test-load:
	$(TEST_RUNNER) $(BASE_FOLDER)/$(BASE_LOAD_FOLDER)/$(ENDPOINT_TO_BE_TESTED)/$(LOAD_TEST_SCRIPT)

test-soak:
	$(TEST_RUNNER) $(BASE_FOLDER)/$(BASE_LOAD_FOLDER)/$(ENDPOINT_TO_BE_TESTED)/$(SOAK_TEST_SCRIPT)

test-integration:
	$(TEST_RUNNER) $(BASE_FOLDER)/$(BASE_INTEGRATION_FOLDER)/$(ENDPOINT_TO_BE_TESTED)/$(INTEGRATION_TEST_SCRIPT)

utility-kompose:
	-kompose convert -f docker-compose.yml -c && rm -rf yy-IaC/helm/* && mv docker-compose yy-IaC/helm

utility-port:
	kubectl expose service app --type=NodePort --name=app --port=80 --target-port=80

utility-hosts:
	sudo sh -c "echo '127.0.0.1 testdotnet.nstankov.com' >> /etc/hosts"

utility-macOS-install-pre-reqs:
	brew install gh
	brew tap hashicorp/tap
	brew install kompose
	brew install helm
	brew install k6
	brew install hashicorp/tap/terraform
	brew install hashicorp/tap/packer
	brew install hashicorp/tap/waypoint
	brew install buildkit
	brew install pre-commit
	brew install terraform-docs
	brew install gsed #because macos's sed sucks

#prompt user for ticket number
TICKET = $(shell read -p "Enter ticket number: " ticket; echo $$ticket)
#prompt user for commit message, enter your commit message
MSG = $(shell read -p "Enter commit message: " msg; echo $$msg)
#prompt user for time spent
TIME = $(shell read -p "Enter time spent: " time; echo $$time)

git-add:
	git add .

git-commit:
	git commit -m "$(TICKET)-$(TIME) $(MSG)"

#Current branch
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
git-origin:
	git push origin $(BRANCH)

git-fast: git-add git-commit git-origin

git-pr:
	gh pr create --title "Title of the PR" --body "Description of the PR"

VERSION = ${shell gh release list | head -n 1 | awk '{print $$3}'}
NEXT_VERSION = ${shell echo $(VERSION) | awk -F. '{$$NF = $$NF + 1;} 1' | sed 's/ /./g'}


git-fast:
	@echo "Fast git add"
	@git add -A
	@git commit -m "Fast commit"
	@git push

git-latest-release:
	@echo "Latest release is $(VERSION)"
	@echo "Next release is $(NEXT_VERSION)"

git-release: git-latest-release
	@echo "create release with GH"
	gh release create $(NEXT_VERSION) --notes "Release $(NEXT_VERSION)"

# Grouped targets
combo: local-combo
portfwd: utility-port
hosts-entry: utility-hosts
kompose: utility-kompose

# Aliases for some targets
up: local-up
down: local-down
extract: build
#Trigger
