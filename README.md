# Fieldsets Local
This is a containerized environment that implements a standard development environment built with [docker-compose](https://docs.docker.com/compose/) for the [Fieldsets Pipeline](https://github.com/Fieldsets/fieldsets-pipeline).

This repository is multi purpose. Utilizing both this repository [Dockerfile](./Dockerfile) and [docker ompose file](./docker-compose.yml), this repository can serve as a boiler plate for containerized deployments of any down stream integrations of Fieldsets's data bases. This repository can also serve as a localized workspace that helps us maintain consistency between versions and dependencies within our pipeline.

Another purpose of this environment is to create a universal platform for team members that allows for collaboration within projects with minimal developer onboarding. By mapping remote data stores to a localized environment, team members can easily create subsets of data as they build out their data driven projects. They can easily recreate their localized environment for collaboration and once completed, can deploy new data structures, analyses and metrics to production with ease.

Currently this environment is a work in progress focusing on aggregated metrics and partitioning of data, but has been created with the idea that all of the branches of fieldsets can utilize this environment such that developers within each branch can easily onboard and contribute to other projects when necessary.

## Installation & Getting started

*TL;DR*

```
git clone --recurse-submodules https://github.com/fieldsets/fieldsets-local.git
cd fieldsets-local
cp ./env.example ./.env (optional for customization)
docker-compose up -d --build
```

## System Requirements.
Before we begin, you must have the following installed locally on your machine. Follow the links below for directions on how to get setup on your current environment.

- [docker-compose](https://docs.docker.com/compose/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Mac OS
Using the terminal execute the following steps
- Install Xcode
    - `xcode-select --install`
- Install homebrew
    - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
- Disable homebrew analytics
    - `brew analytics off`
- Install git
    - `brew install git`
- Install docker-compose
    - `brew install docker`
- Run caffeinate to prevent sleep on first run
    - `caffeinate`


### Linux (Debian based)
- Install git
    - `sudo apt install docker`
- Install git
    - `sudo apt install git`

## Install Steps
Once you have installed git and docker, the first step is to clone the `fieldsets-local` repository and all of it's submodules into your local environment. Since we have no submodles to install, we can omit the `--recurse-submodules` parameters, but often projects have their own repositories. Installing them as a submodule is an option to decouple any applications, scrapers, metrics, etc. from our established data structures.

```
git clone --recurse-submodules https://github.com/fieldsets/fieldsets-local.git
cd fieldsets-local
cp ./env.example ./.env
```

 You can optionally make a copy of the [example env file](./env.example) if you want to change any configuration parameters (like postgres version or the path of your private key). While this is unnecessary as the project will run with the default values set in the `docker-compose.yml` file, it is good to minmally set the following variables in your local dotenv file.

- `LOCAL_UID`: use the command in your terminal `id -u`. Setting the container to have the same user id will allow you to write directly to container volumes without issue.
- `LOCAL_GID`: use the command in your terminal `id -g`.
- `SSH_KEY_PATH`: Will default to `~/.ssh/id_rsa`. If you use another key for Fieldsets's jump server add it here if you are using this as a local work environment.
- `VBDB_USER`, `VBDB_PASSWORD`, `VBDB_HOST`: If you have read access to VBDB, enter your credentials and this environment will add map VBDB as a schema allowing you to query across databases!
- `FIELDSETSPHI_USER`, `FIELDSETSPHI_PASSWORD`, `FIELDSETSPHI_HOST`: If you have read access to Fieldsets PHI, enter your credentials and this environment will add map VBDB as a schema allowing you to query across databases!

For our remote data stores to work, we will need credentials for our production and clone servers. If you are working outside of AWS, you will need to specify the location of your private key that gives access to the Fieldsets jump server [trampoline.fieldsets.com](trampoline.fieldsets.com) if you are using any private key that is not the default `~/.ssh/id_rsa` key defined for unix like systems. The example env contains all the variables used to configure our pipeline. You can omit or change these variables to help with current deployments. Defaults will be filled in using values defined in the docker-compose file for any omitted values.

## Running the container
Now lets get the environment running!

Once docker compose is installed and you have cloned this repository as instructed above, you can get the entire environment up and running with the following command:

```docker-compose up -d```

That's it! You should be up and running. The first docker build may take a while as it imports data remotely and can vary depending on network speed and your local environment hardware. If you'd like to view what is happening on the install you can track the output logs of the container that does all the heavy lifting with the following command:

```docker-compose logs -f fieldsets-local```

When you are done using the environment you can halt the environment using the command:

```docker-compose stop```

### Local Docker Container Info

| Container Name   | Docker Image Name | Default IP Address | Ports Open | Description                    |
| ---------------- | ----------------- | ------------------ | ---------- | ------------------------------ |
| fieldsets-local    | fieldsets/fieldsets-local:latest | 172.28.0.7 | (5432, 5433, 8123, 9000, 9009) | An old fashioned debian linux environment to run any types of scripts you want. Python, R & Bash |

## Additional Steps
Once the containers are running you can clone any missing repositories to the `./src/` directory and run any application docker containers on the `default` network to get connectivity with localized container services.

Any repositories cloned into `./src/` are ignored by git and will be available within the container from the `/fieldsets/` root level directory.

If you utilizing this repository as a boiler plate ad are making changes to the container itself, you may want to utilize the following docker-compose commands:

```docker-compose up -d --build fieldsets-local```

This will rebuild a container within the environment.

```docker-compose down -v```
Remove all data volumes when shutting down. This will prompt a rebuild on all containers. *WARNING:* This will wipe all your local data but is a great way to end to end test your container.

If you'd like to utilize a terminal within the container, make sure the environment variable `ENABLE_TERMINAL=true` is set. You can then run the command: `docker exec -it fieldsets-local /bin/bash`

## Deploying With Fieldsets Local
Fieldsets local handles setting up tunnels if outside of AWS as well as creating foreign data servers in any environment. This is all handled within the [entrypoint script](./entrypoint.sh). It will set a series of checkpoints on it's data volume found at `/data/checkpoints/$ENVIRONMENT/fieldsets-local`. After the entrypoint script it will execute the command `/bin/bash` which will only create a pseudo tty terminal if you sepcify `ENABLE_TERMINAL=true` within your dotenv file. You can use this container and override this command with your own custom command within a `docker-compose.override.yml` file. An example would look like so.
```
version: '3.7'
services:
    fieldsets-local:
        tty: false
        command: /bin/bash -c "/fieldsets/my_repo/init.sh;"
```
This would execute your init script you have clone into ./src and exit the container after it completes successfully.

## Other Fieldsets Containers
Currently this pipeline expects a PostgreSQL instance to be specified. If you want to run one locally, check out Fieldsets's [docker-postgres repository](https://github.com/Fieldsets/docker-postgres) to help you get one running. If you know for a fact you want a all in one environment, check out Fieldsets's full [pipeline repository](https://github.com/Fieldsets/fieldsets-pipeline) which automates running postgres and this repository into a single dotenv file and `docker compose up -d` command.

## Tools
### PostgreSQL
Any GUI with a TCP connection on port 8123 can connect locally to [http://0.0.0.0:5432](http://0.0.0.0:5432). A personal preference is for [DBeaver](https://dbeaver.io/download/). But Fieldsets also utilizes [Postico](https://fieldsetsinc.atlassian.net/wiki/spaces/EN/pages/2632777780/Postico+License).

If you want to use the native PostgresCLI client, you can use the command `docker exec -it fieldsets-postgres /bin/bash -c "export PGPASSWORD=\${POSTGRES_PASSWORD}; psql --host \${POSTGRES_HOST} --username \${POSTGRES_USER} --port \${POSTGRES_PORT} --dbname \${POSTGRES_DB}"` to use the client within the container.
