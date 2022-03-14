# Fieldsets Local
This is a local development environment for the fieldsets data structure framework built with [docker-compose](https://docs.docker.com/compose/). The purpose of this environment is to create a universal development platform for team members that allows for collaboration within projects with minimal developer onboarding. Currently this environment is a work in progress focusing on aggregated metrics, but has been created with the idea that all of the branches of data science can utilize this environment so developers within each branch can easily contribute to other projects when they have the overhead capacity to help.

## Installation & Getting started

*TL;DR*

```
git clone --recurse-submodules -j8 https://github.com/fieldsets/fieldsets-local.git
cd fieldsets-local
cp ./env.example ./.env
docker-compose up -d
```

## Install Steps
First clone the `fieldsets-local` repository and all of it's submodules into your local environment.

```
git clone --recurse-submodules -j8 https://github.com/fieldsets/fieldsets-local.git
```

Move into this cloned directory. Make a copy of the example env file.

```
cd fieldsets-local
cp ./env.example ./.env
```

The example env contains all the variables used. You can omit or change these variables. Defaults will be filled in using values defined in the docker-compose files for any omitted values.

Now lets get the environment running!

Download and install the latest version of docker-compose following the instructions found [here](https://docs.docker.com/compose/install/)

Once docker-compose is installed and you have cloned this repository you can get fieldsets-local up and running with the following command:

```docker-compose up -d```

That's it you should be up and running. The first docker build may take a while as it imports data remotely and can vary depending on how many days worth of data you specified in your `.env` file. 

When you are done using the environment you can halt the environment using the command:

```docker-compose stop```

Once the containers are running you can clone any missing repositories to the `/src/` directory and run any application docker containers on the `default` network to get connectivity with fieldsets-local container services.

If you are making changes to any of the containers themselves, you may want to utilize the following docker-compose commands:

```docker-compose up -d --build fieldsets-CONTAINER-NAME```
This will re build a container within the fieldsets-local environment.

```docker-compose down -v```
Remove all data volumes when shutting down. This will prompt a rebuild on all containers.

## Tools
Currently fieldsets-local runs Kafka, Zookeeper, ClickHouse and PostgreSQL as the default systems for our data stores. An elasticsearch container is currently optional and experimental.

### ClickHouse
Any GUI with a TCP connection on port 8123 can connect locally to [http://0.0.0.0:8123](http://0.0.0.0:8123). A personal preference is for [DBeaver](https://dbeaver.io/download/). If you want to utilize the clickhouse-client and the native protocol client on port 9000, you can utilize this [shell script](bin/clickhouse-cli.sh) to connect through the wireguard container and pass it a parameter of `stage` if you want to query the staging db.

### PostgreSQL
Any GUI with a TCP connection on port 8123 can connect locally to [http://0.0.0.0:5432](http://0.0.0.0:5432). A personal preference is for [DBeaver](https://dbeaver.io/download/). We use this primarily as a row store. We don't interact directly through Postgres, as we map the tables found here to tables in Clickhouse utilizing their internal Postgres and external dictionary data structure.

## DATA STORE TYPES (default)

## Structured Stores
- *Profiles*: (PostgreSQL)
- *Records*: (ClickHouse), PostgreSQL
- *Sequences*: (ClickHouse), PostgreSQL

# Semi Structured Stores
- *Documents*: (MongoDB), Redis
- *Messages*: (Kafka), PostgreSQL, ClickHouse, MongoDB

# Generated Data Stores
- *Cache*: (Redis), ClickHouse
- *Search*: (Elasticsearch)
- *Metrics*: (ClickHouse), PostgreSQL
