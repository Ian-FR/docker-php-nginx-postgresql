# Web Server Dockerized ( NGINX + PHP-FPM + PostgreSQL )

A single container to run PHP using the NGINX - PHP-FPM - PostgrSQL stack. In addition having the composer and xdebug already installed

## Overview

This Docker configuration allows you to easily run PHP 7.4, Nginx 1.18.0, PostgreSQL 12.4. This is the directories setup:

```
./
├── config  # docker configuration files
│   ├── start
│   ├── nginx.conf
│   ├── php.ini
│   └── xdebug.ini
│
├── src     # App folder
│   ├── test.html
│   └── index.php
│
├── vhosts  # Optional additional vhosts
│   ├── js-example.conf
│   └── php-examplo.conf
│
├── .env-example
├── Dockerfile
└── README.md
```

## How to use

- You need to have a `.env` file set up, so rename .env-example to .env open it and configure

- Buid the docker image from Dockerfile

```bash
docker build  -t
              web-server:stable
              .
```
- To test and walkaround the localhost app run the command below

```bash
docker run  -d --env-file .env
            -p 5432:5432
            -p 80:8080
            --name web-server
            web-server:stable
```

Obs.: You can serve one default app mounting the code base host's path to '/var/app' container's path. But also, you can serve multiple apps (static or not) configuring virtual hosts on ./vhosts directory and after, mounting vhosts directory host's path to '/etc/nginx/conf.d' container's path and their respective code base paths

```
            -v ~/path/to/code-base:/var/app
            -v ./vhosts:/etc/nginx/conf.d
            -v ~/path/to/static/app1:/var/app1
            -v ~/path/to/static/app1:/var/app2
```

- If you access localhost on your browser.. Voilá!! You'll see the PHP configurations

- To debug your PHP application, you need have xdebug with pathMapping configured. On VSCode, configure the launch.json file like this

```
"configurations": [
    {
      "name": "Listen for XDebug",
      "type": "php",
      "request": "launch",
      "port": 9999,
      "pathMappings": {
        "/var/app":"${workspaceRoot}/src"
      }
    }
  ]
```

## Using container services on host

The services will be able to use on container console, but you can use them with the command pattern `docker exec -it <container-name> <command>`.

```
docker exec -it web-server php -v
docker exec -it web-server postgres --version
docker exec -it web-server psql -U postgres
docker exec -it web-server psql dbname pguser
docker exec -it web-server composer dump-autoload
```

Obs.: The composer runs at container startup on the default app's workdir to automatically install the project's dependencies
