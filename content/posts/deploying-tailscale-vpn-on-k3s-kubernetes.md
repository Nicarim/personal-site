---
title: "Deploying Tailscale Vpn on K3s Kubernetes"
date: 2021-09-02T22:18:52+02:00
draft: false
---

This is gonna be rather short. I wanted to put all the info I gathered in a single place.

## Dockerfile
There is no official docker image available yet. There is however official Dockerfile which you can use to base your setup off of.

- https://github.com/tailscale/tailscale/blob/v1.14.0/Dockerfile

You need to modify it slightly however

Create file called `entrypoint.sh` (based on [snippet](https://gist.github.com/hamishforbes/2ac7ae9d7ea47cad4e3a813c9b45c10f))

```bash
if [ ! -d /dev/net ]; then mkdir /dev/net; fi
if [ ! -e /dev/net/tun ]; then  mknod /dev/net/tun c 10 200; fi

# Wait 5s for the daemon to start and then run tailscale up to configure
/bin/sh -c "sleep 5; tailscale up --authkey=${TAILSCALE_AUTH} -advertise-tags=${TAILSCALE_TAGS}" &
exec /usr/local/bin/tailscaled --state=/tailscale/tailscaled.state
```

And put it into the same dir you have tailscale Dockerfile. You need to add that entrypoint to Dockerfile and use it:

```diff
# Copyright (c) 2020 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM golang:1.16-alpine AS build-env

WORKDIR /go/src/tailscale

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# see build_docker.sh
ARG VERSION_LONG=""
ENV VERSION_LONG=$VERSION_LONG
ARG VERSION_SHORT=""
ENV VERSION_SHORT=$VERSION_SHORT
ARG VERSION_GIT_HASH=""
ENV VERSION_GIT_HASH=$VERSION_GIT_HASH

RUN go install -tags=xversion -ldflags="\
      -X tailscale.com/version.Long=$VERSION_LONG \
      -X tailscale.com/version.Short=$VERSION_SHORT \
      -X tailscale.com/version.GitCommit=$VERSION_GIT_HASH" \
      -v ./cmd/...

FROM alpine:3.14
RUN apk add --no-cache ca-certificates iptables iproute2
COPY --from=build-env /go/bin/* /usr/local/bin/
+COPY entrypoint.sh /entrypoint.sh

+ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
```

You can now build the dockerfile and it should work out of the box.

## Kubernetes manifest
To test things out, I used following deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tailscale
  labels:
    app: tailscale
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tailscale
  template:
    metadata:
      labels:
        app: tailscale
    spec:
      containers:
      - name: tailscale
        image: nicarim/tailscale:v1.14.0-entrypoint2
        securityContext:
          capabilities:
            add:
              - NET_ADMIN
      - name: nginx
        image: nginx:1.21.1
        ports:
        - containerPort: 80
```

Change the image to your own, or use the one you see here - it should work just as in this post.

After deploying the manifest, you need to authenticate your tailscale instance (if you didn't provide `TAILSCALE_AUTH` env variable)

Check logs of tailscale pod and look for following line

```
│ tailscale 2021/09/02 00:00:00 control: doLogin(regen=false, hasUrl=true)             
│ tailscale To authenticate, visit:                                                     
│ tailscale     https://login.tailscale.com/a/<cut>
```

Click the link and authenticate.

THIS IS IN NO WAY PRODUCTION READY - I was just testing things out and wanted to put together a working example for `v1.14.0`.

Helpful [thread on github](https://github.com/tailscale/tailscale/issues/504)
