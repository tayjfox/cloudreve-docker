# Cloudreve Docker - Nginx reverse proxy

This guide starts Cloudreve together with Nginx as a reverse proxy server. Aria2 is bundled inside the Cloudreve image itself, so no separate container is needed for offline downloads. This guide has only been tested on linux/amd64; if you're on arm, adjust parameters as needed.

Before you start, please check:

- Docker is installed. If not, run `wget -qO- https://get.docker.com/ | bash` to install it.
- You have a domain name pointed at the server running Cloudreve. This guide uses `cloudreve.example.com` as an example.

## Getting started

### Create a network

```bash
docker network create my-network
```

### Create the Nginx config file

```bash
mkdir -p /dockercnf/nginx/conf.d \
  && mkdir -p /dockercnf/nginx/ssl \
	&& vim /dockercnf/nginx/conf.d/cloudreve.conf
```

Add the following

```
server {
  listen 80;
  location / {
    proxy_pass http://cloudreve:5212;
    proxy_set_header Host $host;
  }
}
```

### Start the Nginx service

```bash
docker run -d \
  --name nginx \
  -v /dockercnf/nginx/conf.d:/etc/nginx/conf.d \
  -v /dockercnf/nginx/ssl:/etc/nginx/ssl \
  --network my-network \
  -p 80:80 -p 443:443 \
  --restart unless-stopped \
  nginx:alpine
```

### Start Cloudreve

```bash
docker run -d \
  --name cloudreve \
  -e TZ="America/Toronto" \ # optional
  --network my-network \
  --restart=unless-stopped \
  -v <PATH TO data>:/cloudreve/data \
  -p 6888:6888 -p 6888:6888/udp \
  vedla/cloudreve
```

Notes

- `TZ` sets the container's timezone. Defaults to `America/Toronto` if not set.
- `<PATH TO data>`: data directory that stores the config, database, avatars, uploads, and Aria2 downloads, e.g. `/dockercnf/cloudreve/data`.
- Open `http://cloudreve.example.com` and register the first account — it is automatically made the site administrator.
- Aria2 offline downloads work out of the box; there is no separate RPC server to configure.
