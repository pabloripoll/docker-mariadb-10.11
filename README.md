<div style="width:100%;float:left;clear:both;margin-bottom:50px;">
    <a href="https://github.com/pabloripoll?tab=repositories">
        <img style="width:150px;float:left;" src="https://pabloripoll.com/files/logo-light-100x300.png"/>
    </a>
</div>

# Docker - MariaDB 10.11

The objective of this repository is having a CaaS [Containers as a Service](https://www.ibm.com/topics/containers-as-a-service) repository to provide a start up database for local development and follow the best practices on a [cloud database](https://cloud.google.com/learn/what-is-a-cloud-database) scenario, to understand and modify by development requirements.

The connection with this container service is as [Host Network](https://docs.docker.com/network/drivers/host/) on `eth0`, thus this container do not share networking or bridge configuration.

### Stack Details

- [Alpine Linux 3.19](https://www.alpinelinux.org/)

- [MariaDB 10.11.6-r0](https://mariadb.com/kb/en/changes-improvements-in-mariadb-1011/)

- [MariaDB Package](https://alpine.pkgs.org/3.19/alpine-main-x86_64/mariadb-10.11.6-r0.apk.html)

### Objetives

* Built on the lightweight and secure Alpine 3.19 [2024 release](https://www.alpinelinux.org/posts/Alpine-3.19.1-released.html) Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-280MB)
* Uses MariaDB 10.11 as default for the best performance, low CPU usage & memory footprint.
* Services independency to connect from container application to this database allocation

## Usage
Local machien apps can connect to this service by address `localhost:${PORT}` but to connect other containers to this service, the address is `${HOSTNAME}:${PORT}`.

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
Makefile  help                     shows this Makefile help message
Makefile  hostname                 shows local machine ip
Makefile  fix-permission           sets project directory permission
Makefile  port-check               shows this project ports availability on local machine
Makefile  database-ssh             enters the database container shell
Makefile  database-set             sets the database enviroment file to build the container
Makefile  database-build           builds the database container from Docker image
Makefile  database-start           starts up the database container running
Makefile  database-stop            stops the database container but data will not be destroyed
Makefile  database-destroy         stops and removes the database container from Docker network destroying its data
Makefile  repo-flush               clears local git repository cache specially to update .gitignore
```

Create a [.env](DOTENV) file from example a set the following variables
```
# Leave it empty if no need for sudo user to execute docker commands
DOCKER_USER=sudo

# Container data for docker-compose.yml
PROJECT_TITLE="MARIADB"   # <- this name will prompt on makfile messages
PROJECT_ABBR="mdb1"       # <- part of the image tag, useful if more maridb are running

# Database container
PROJECT_DB_HOST="127.0.0.1"                 # <- for this project is not necessary
PROJECT_DB_PORT="8889"                      # <- port to connect to mariadb
PROJECT_DB_CAAS="mariadb"                   # <- container as a service name
PROJECT_DB_PATH="../resources/database/"    # <- path location for database backup or copy
PROJECT_DB_ROOT="7c4a8d09ca3762af61e595"    # <- database root password
PROJECT_DB_NAME="mariadb"                   # <- database user
PROJECT_DB_USER="mariadb"                   # <- database name
PROJECT_DB_PASS="123456"                    # <- database user password
```

Checkout local machine ports availability
```bash
$ make port-check

Checking configuration for MARIADB container:
MARIADB > port:8880 is free to use.
```

Checkout local machine IP to set connection between containers using the following makefile recipe
```bash
$ make hostname

192.168.1.41
```

**Before running this service** checkout database connection health using a database mysql client.

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
85cc9f74b6be   mariadb:mariadb-10.11   "/scri..."   About a minute ago   Up About a ...   0.0.0.0:8899->3306/t...   mariadb

$ sudo docker images
REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
mariadb      10.11     d4d593f6b82e   About a minute ago   284MB

$ sudo docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          1         1         284.2MB   0B (0%)
Containers      1         1         14.37kB   0B (0%)
Local Volumes   2         1         260.9MB   130.5MB (50%)
Build Cache     8         0         2.917kB   2.917kB
```
