# Cloudreve Docker - Docker Compose

## Using Nginx as the server

Before you start, please check:

- Docker is installed. If not, run `wget -qO- https://get.docker.com/ | bash` to install it.
- Docker Compose is installed. If not, see [Install Docker Compose](https://docs.docker.com/compose/install/).
- You have a domain name pointed at the server running Cloudreve. This guide uses `cloudreve.example.com` as an example.
- Ports 80 and 443 are free. If you already have a web server (e.g. Nginx or Caddy), consider adding the config to your existing server instead and removing the `caddy` container from the compose file.

### Pre-create files

Nginx config file

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

### Download the environment file and docker-compose file

Download the environment file

```bash
wget -qO- https://raw.githubusercontent.com/xavier-niu/cloudreve-docker/master/docker-compose-env-example > .env
```

Adjust the environment variables as needed

- `CLOUDREVE_DATA_PATH`: path where Cloudreve stores its data (config, database, avatars, uploads, Aria2 downloads). Only change this if you know what you're doing.

Download the docker-compose file

```bash
wget -qO- https://raw.githubusercontent.com/xavier-niu/cloudreve-docker/master/docker-compose-amd64.yml > docker-compose.yml
```

### Start Docker Compose

```bash
docker-compose up -d
```

Notes

- Aria2 is bundled inside the Cloudreve container, so offline downloads work out of the box — there is no separate RPC server to configure.
- Open `http://cloudreve.example.com` and register the first account — it is automatically made the site administrator.

### Using Traefik as the server

This alternative setup was contributed by @expoli. Traefik is a modern web server with built-in Docker service discovery and automatic HTTPS certificate provisioning — you only need to add labels to your services to enable reverse proxying, which simplifies configuration considerably.

See [https://github.com/expoli/docker-compose-files](https://github.com/expoli/docker-compose-files) for the full config. Note it was written for Cloudreve v3 (**traefik + cloudreve + mysql + redis**) and may need adjusting for v4's data layout.
