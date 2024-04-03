<div style="width:100%;float:left;clear:both;margin-bottom:50px;">
    <a href="https://github.com/pabloripoll?tab=repositories">
        <img style="width:150px;float:left;" src="https://pabloripoll.com/files/logo-light-100x300.png"/>
    </a>
</div>

# Docker - MariaDB 10.11

The objective of this repository is having a CaaS [Containers as a Service](https://www.ibm.com/topics/containers-as-a-service) to provide a "ready to use" container with the basic enviroment features to deploy a [MariaDB](https://mariadb.org/) database service under a lightweight Linux image for development stage requirements.

The container configuration is as [Host Network](https://docs.docker.com/network/drivers/host/) on `eth0` as [Bridge network](https://docs.docker.com/network/drivers/bridge/), thus it can be accessed through `localhost:${PORT}` by browsers but to connect with it or this with other services `${HOSTNAME}:${PORT}` will be required.

### Stack Details

- [Alpine Linux 3.19](https://www.alpinelinux.org/)

- [MariaDB 10.11.6-r0](https://mariadb.com/kb/en/changes-improvements-in-mariadb-1011/)

- [MariaDB Package](https://alpine.pkgs.org/3.19/alpine-main-x86_64/mariadb-10.11.6-r0.apk.html)

### Project objetives with Docker

* Built on the lightweight and secure Alpine 3.19 [2024 release](https://www.alpinelinux.org/posts/Alpine-3.19.1-released.html) Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-280MB)
* Uses MariaDB 10.11 as default for the best performance, low CPU usage & memory footprint
* Service independency to connect from other container application to this database allocation
* Useful setting to run this service inside a cluster configuration

#### Hostname on Windows systems

This project has not been tested on Windows OS neither I can use it to test it. So, I cannot bring much support on it.

Anyway, using this repository you will needed to find out your PC IP by login as an `administrator user` to set connection between containers.

```bash
C:\WINDOWS\system32>ipconfig /all

Windows IP Configuration

 Host Name . . . . . . . . . . . . : 191.128.1.41
 Primary Dns Suffix. . . . . . . . : paul.ad.cmu.edu
 Node Type . . . . . . . . . . . . : Peer-Peer
 IP Routing Enabled. . . . . . . . : No
 WINS Proxy Enabled. . . . . . . . : No
 DNS Suffix Search List. . . . . . : scs.ad.cs.cmu.edu
```

Take the first ip listed. Wordpress container will connect with database container using that IP.

#### Hostname on Unix based systems

Find out your IP on UNIX systems and take the first IP listed
```bash
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```

## Structure

Directories and main files on a tree architecture description
```
.
│
├── docker
│   ├── ...
│   ├── .env
│   ├── .env.example
│   └── docker-compose.yml
│
├── .env
├── .env.example
└── Makefile
```

## Automation with Makefile

Makefiles are often used to automate the process of building and compiling software on Unix-based systems as Linux and macOS.

*To use Makefile on Windows I recommend to follow this post: \
https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows*

Makefile recipies
```bash
$ make help
usage: make [target]

targets:
Makefile  help                   shows this Makefile help message
Makefile  hostname               shows local machine hostname ip
Makefile  fix-permission         sets project directory permission
Makefile  port-check             shows .env port set availability on local machine
Makefile  env                    checks if docker .env file exists
Makefile  env-set                sets the database enviroment file to build the container
Makefile  ssh                    enters the database container shell
Makefile  build                  builds the database container from Docker image
Makefile  dev                    -- recipe has not usage in this project --
Makefile  up                     starts the containers in the background and leaves them running
Makefile  start                  starts existing containers for a service
Makefile  stop                   stops running container without removing it
Makefile  clear                  stops and removes the database container from Docker network destroying its data
Makefile  destroy                removes the database image from Docker - docker system and volume prune still required to be manually
Makefile  sql-install            installs into container database the init sql file from resources/database
Makefile  sql-replace            replaces container database with the latest sql backup file from resources/database
Makefile  sql-backup             creates / replace a sql backup file from container database in resources/database
Makefile  repo-flush             clears local git repository cache specially to update .gitignore
```

Create a [DOTENV](.env) file from [.env.example](.env.example) and setup according to your project requirement the following variables
```
# Leave it empty if no need for sudo user to execute docker commands
DOCKER_USER=sudo

# Container data for docker-compose.yml
PROJECT_TITLE="MARIADB"   # <- this name will be prompt for Makefile recipes
PROJECT_ABBR="mdb1"       # <- part of the service image tag - useful inside a cluster

# Database container
PROJECT_DB_HOST="127.0.0.1"                 # <- for this project is not necessary
PROJECT_DB_PORT="8889"                      # <- port access container service on local machine
PROJECT_DB_CAAS="mariadb"                   # <- container as a service name to build service
PROJECT_DB_PATH="../resources/database/"    # <- path where database backup or copy resides
PROJECT_DB_ROOT="7c4a8d09ca3762af61e595"    # <- database root password
PROJECT_DB_NAME="mariadb"                   # <- database user
PROJECT_DB_USER="mariadb"                   # <- database name
PROJECT_DB_PASS="123456"                    # <- database user password
```

Exacute the following command to create the [docker/.env](docker/.env) file, required for building the container
```bash
$ make env-set

MARIADB docker-compose.yml .env file has been set.
```

Checkout local machine ports availability
```bash
$ make port-check

Checking configuration for MARIADB container:
MARIADB > port:8880 is free to use.
```

Build the container and start using it
```bash
$ make build up

[+] Building 10.1s (10/10) FINISHED                                                                                                                                                 docker:default
 => [mariadb internal] load build definition from Dockerfile                              0.0s
 => => transferring dockerfile: 1.13kB                                                    0.0s
 => [mariadb] resolve image config for docker-image://docker.io/docker/dockerfile:1       1.0s
 => CACHED [mariadb] docker-image://docker.io/docker/dockerfile:1@sha256:ac85f380a63...   0.0s
 => [mariadb internal] load metadata for ghcr.io/linuxserver/baseimage-alpine:3.19        1.5s
 => [mariadb internal] load .dockerignore                                                 0.0s
 => => transferring context: 107B                                                         0.0s
 => [mariadb 1/3] FROM ghcr.io/linuxserver/baseimage-alpine:3.19@sh
...
 => => exporting layers                                                                   1.4s
 => => writing image sha256:375ffb756af0fe6e33d1d091b883fa840e21d0c1e32e029a9b03817...    0.0s
 => => naming to docker.io/library/mariadb:mdb1-mariadb                                   0.0s
[+] Running 1/2
 ⠧ Network mariadb_default  Created                                                       0.8s
 ✔ Container mariadb        Started                                                       0.6s
[+] Running 1/0
 ✔ Container mariadb  Running
```

**Before connecting to this service** checkout database connection health using a database mysql client.

Checkout local machine IP to set connection between containers using the following makefile recipe
```bash
$ make hostname

192.168.1.41
```

- [MySQL Workbench](https://www.mysql.com/products/workbench/)
- [DBeaver](https://dbeaver.io/)
- [HeidiSQL](https://www.heidisql.com/)
- Or whatever you like. This Docker project doesn't come with [PhpMyAdmin](https://www.phpmyadmin.net/) to make it lighter.


## Docker Info

```bash
$ mariadb --version
mariadb  Ver 15.1 Distrib 10.11.6-MariaDB, for Linux (x86_64) using readline 5.1

$ cat /etc/*-release
3.19.1
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.19.1
PRETTY_NAME="Alpine Linux v3.19"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://gitlab.alpinelinux.org/alpine/aports/-/issues"
```

```bash
$ sudo docker ps
CONTAINER ID   IMAGE                   COMMAND      CREATED              STATUS           PORTS                     NAMES
85cc9f74b6be   mariadb:mariadb-10.11   "/scri..."   About a minute ago   Up About a ...   0.0.0.0:8880->3306/t...   mariadb
```

```bash
$ sudo docker images
REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
mariadb      10.11     d4d593f6b82e   About a minute ago   333MB
```

```bash
$ sudo docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          1         1         332.7MB   0B (0%)
Containers      1         1         25.09kB   0B (0%)
Local Volumes   2         1         248.4MB   117.9MB (50%)
Build Cache     8         0         12.92kB   12.92kB
```

```bash
$ sudo docker system prune
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - unused build cache

Are you sure you want to continue? [y/N] y
Deleted build cache objects:
pi2nekd11s31r4s76flw3ju1f
rjcjdgy9k0trjhvgrq6uol7w3
1f3e2fchph8p0u1nc1h3rdj3u
wk5uspgwehxu1f2cf3yzd825q
l88kfpqdw00qdab64yj3z1zi4
g03h439y1od9xdgyu4bq8yxgv
4cgf7g6rrujewzb0m4xcdhaw0
cj3n87r5jj9trj3aypditdriu
7645felv5gllm8wnzis4f8fq9
sehrl0x8avgtjfyfn17jsodtk

Total reclaimed space: 306.9MB
```

```bash
$ sudo docker volume prune
WARNING! This will remove anonymous local volumes not used by at least one container.
Are you sure you want to continue? [y/N] y
Deleted Volumes:
8ad2974b68ae451f49224d95b066a0f9aa697d9965dfe0e6cf82d1c191e7f34d

Total reclaimed space: 117.9MB
```

## Stop Container Service

Using the following Makefile recipe stops application from running, keeping database persistance and application files binded without any loss
```bash
$ make mariadb-stop
[+] Stopping 1/1
 ✔ Container mariadb-app  Stopped                                                     0.5s
```

## Remove Container Image

To remove application container from Docker network use the following Makefile recipe *(Docker prune commands still needed to be applied manually)*
```bash
$ make mariadb-destroy

[+] Removing 1/0
 ✔ Container mariadb-app  Removed                                                     0.0s
[+] Running 1/1
 ✔ Network mariadb-app_default  Removed                                               0.4s
Untagged: mariadb:mdb1-mariadb
Deleted: sha256:3c99f91a63edd857a0eaa13503c00d500fad57cf5e29ce1da3210765259c35b1
```