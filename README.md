# d

Docker simple helper for deployments

## Installation

```
curl https://raw.githubusercontent.com/maximevalette/d/main/d \
--output /usr/local/bin/d && \
chmod +x /usr/local/bin/d && \
d version
```

## Environment file

Add a `.d` environment file in your project root:

```
PROJECT=my_project
USER=www-data
```

## Opinions

- Your main container should be named `app`
- You need green / blue deployments (zero downtime)