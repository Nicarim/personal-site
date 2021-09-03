---
title: "I Give Up on Traefik Its Too Complicated"
date: 2021-09-03T22:49:50+02:00
draft: false
---

Mind you, this is kind of a clickbaitish, but what I mean exactly is that traefik is too complicated for personal k3s setup. 

## Trying to setup traefik from scratch
I've been working on setting up traefik from scratch as an exercise. I got to the point where it's all nice and running and then there is this.

I've created IngressRoute

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  labels:
    app.kubernetes.io/managed-by: pulumi
  name: dashboard
  namespace: traefik-tailscale
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: PathPrefix(`/dashboard`) || PathPrefix(`/api`)
    services:
    - kind: TraefikService
      name: api@internal
```

Which does what it says - matches `/dashboard` and directs that to internal api which resolves to showing a dashboard when you access `/dashboard/` (mind the slash).

Now I've made port-forward from traefik's websecure port to a localhost:9100, and I accessed the path at `https://localhost:9100/` viola.

It works

EXCEPT...

Not really..

You see, this works only in port-forward scenario when it's localhost or 127.0.0.1.

Now what if I try to reach to it on my dedicated domain that I setup for it?

IT DOESN'T WORK.

And I've no way to diagnose it using tooling available out of the box. NO WAY.

I've to install Jaeger or some other tracing tool that will be able to tell me how my traffic flows through traefik, no way.

Let me tell you again:

Port forwarded request to `https://localhost:9100/dashboard/` gives me `127.0.0.1 - - [03/Sep/2021:20:43:27 +0000] "GET /dashboard/ HTTP/1.1" 200 3124 "-" "-" 896 "traefik-tailscale-dashboard-d012b7f875133eeab4e5@kubernetescrd" "-" 0ms` in the logs. AND IT WORKS.

Direct request to the same endpoint gives on `https://example.com/dashboard/` me:
`my.ip.get.lost - - [03/Sep/2021:20:43:58 +0000] "GET /dashboard/ HTTP/1.1" - - "-" "-" 920 "-" "-" 0ms`. AND IT DOESN'T WORK.

THERE IS NO HOST MATCHING, that is a single rule, DOESN'T WORK. All I get is this freaking `404 not found` error as if there was nothing more useful it could tell you, like... what it tried to match? where did it decide to drop the packet? NO DEBUGGING AT ALL, NOW GUESS what's the problem.

/rant

Before you mention, I already setup `--api.insecure=true` because without that it didn't work on localhost too :).

And also, it worked before I decided to use root as a user for traefik container (to bind to 80/443 ports).

### I give up on traefik, next comes Caddy
Maybe Caddy doesn't have fancy CRDs, tons of configuration or APIs and "microservice" based band-wagon, but at least I hope it works in a sane way...
