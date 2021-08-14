---
title: "K3s for Home Server the Easy Way"
date: 2021-08-14T09:30:13+02:00
draft: true
---

I've always wanted to have my own home server. I've even bought Intel NUC for that which I intended to use, but I never got around to configuring it properly so it has gathered dust while not in use.

But in motivation strike, I decided to finally get around to do it, and implement it.

## Infra automation not always the best way to move forward

First of all, I don't want to be it a maintanence burden at all. With that comes also the need to be able to recover from possible hardware failure easily (and by that I mean all the configuration has to be available somewhere without much manual work). 

Initially, I wanted to use Ansible to just automate it, but then I realized that handling home server which I just want to be working it's too much overhead. I've always got that feeling that if there is something trival I want to change in the server (like a value in config file) it made me anxious that I didn't use Ansible for that, because then I had to re-do that in Ansible, and if I forgot / didn't do it it would lead to configuration drift, making the Ansible useless... yeah, you understand why I'm hesitant to using Ansible. Feedback loop for using Ansible for home server is just too big / complicated. If the changes were to be reflected immediately it maybe would be wise, but for a single server [most-likely pet server](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/)? nah.

## Using complicated monstrosity for less complicated setup

This might sound like paradox, but by using Kubernetes which is a [complex beast](https://phoenixnap.com/kb/understanding-kubernetes-architecture-diagrams), we can achieve simplicity thanks to its popularity. I've came to the conclusion after years of reluctance to kubernetes that thanks to the fact it became defacto standard for container orchestration, everyone is working toward making it easier / better / more efficient to work with it. A lovely example of that is tool called [k9s](https://github.com/derailed/k9s#screenshots) which became my Go-To tool for managing Kubernetes clusters. 

While plain docker setup has also such tools, like [Portainer](https://www.portainer.io/), I think it caters to different needs and portainer becomes platform-in-a-platform sort of tool and it doesn't make it easier to deploy things, merely makes it more GUI based.

We also don't have to use K8s directly, there are distributions like [k3s](https://k3s.io/) or [k0s](https://k0sproject.io/) (I wonder what will be next - `k8-8s`?). The biggest difference between full-blown k8s, and distribution like k3s is that k3s bundles everything in a single binary, so we don't have to care about deploying / provisioning all of that. It provides sane defaults on how to manage it. While for production clusters it might be desirable to use k8s (never deployed it myself for production, always done using managed control plane solutions), k3s is mostly compatible with existing kubernetes supported projects which you will see later on in article.

## Requirements

It's always good to know what do you want to achieve by the end of the day, and for me this is it:
- **Disaster Recovery** - in case of a hardware failure causing full halt of our service we want to be able to recover easily.
  - [**k3s backup&resotre**](https://rancher.com/docs/k3s/latest/en/backup-restore/)
  - [**restic**](https://restic.readthedocs.io/en/stable/) - encrypted backups for anything else 
  - [**b2**](https://www.backblaze.com/b2/cloud-storage.html) - for storing the backups
- [**sanic**](https://meme.fandom.com/wiki/Sanic_Hegehog?file=1385136139955.png) **feedback loop** when it comes to adding / removing / changing things
  - Thinking between following solutions
    - [**Eclipse Che**](https://www.eclipse.org/che/)
    - [**gitpod**](https://www.gitpod.io/)
    - [**code-server**](https://github.com/cdr/code-server)
  - I want the IDE/Editor to be there always, independently of which device I use / where I am. And I want it to be preconfigured because each time I need to configure it on different device, my motivation to keep home server running drops significantly 
- **Secure external access** - this is hard requirement for me. 
  - While I could go through the hops of using wireguard to tunnel the traffic and make it invisible on the internet, not every piece of software supports that flow (like HomeAssistant), and having VPN connected all the times drains the battery. I'm lazy, and I prefer things which don't require me thinking. 
  - [**SSO Authelia**](https://github.com/authelia/authelia)
- **My ISP's IP is hidden**
  - I could expose everything through my IP, I've IPv4 assigned and can port forward whatever I want, but I consider it to be a too big of security risk to expose myself to the internet like that. I might forgot to patch some zero day, or expose something without auth that allows [RCE](https://blog.sqreen.com/remote-code-execution-rce-explained/) 
  - Recently discovered [**frp (fast reverse proxy)**](https://github.com/fatedier/frp) which seems to be a perfect solution to my problem.
- **Freedom** and **privacy**
  - This comes as a result of doing it manually, but in the days of [CSAM-like scanning](https://twitter.com/matthew_d_green/status/1423071186616000513) I think its important to start regaining full privacy to your content. 
  - It's not about having illegal stuff hidden from the cops (and I don't intend to hide anything like that [it's what people who do say, huh?]), its about their ability to be able to convict you based solely on the content you have. Now it's only CSAM scanning for clear purpose - but can you trust your authorities to not screw up by accident? Or by intention if you become political enemy? I can't. 
  - And also tracking and advertisments. I make pictures of reciepts that I take from shops - how do I know that cloud provider I use to store pictures doesn't scan them? I simply can't know that. 

## External Access Architecture

This is what I did. It doesn't have to be the same for you. You might want to expose http of frp directly for example.

{{<figure src="http access diagram.svg" height="500px">}}

## Provisioning cluster

For the cluster to be running and accepting external traffic several things need to be done. Read about them below.
Quick summary of what will be done:
- Setting up HTTP frp server
- Setting up frp client and forwarding traffic to traefik
- Setting up SSO portal and accessing it from outside world

### Setting up frp server

We will be using frp server to be able to access our private addressed cluster from the outside world. We intend to only use http forwarding for now, but it can be expanded for https and more. 

Setting up the frp server is pretty straightforward. They provide you with [binary for all OSes](https://github.com/fatedier/frp/releases).
As I use external shell provider which shares single IP across multiple accounts, I had to reserve the specific port that I'll be using for gainig external access.
They also have shared http/https server, which allows reverse_proxy functionality. What I did was:
- Download the frp compressed package for freeBSD (provider's OS)
- Run new screen session using `screen -S frp_server` command
- Create new directory for `mkdir ~/frps`
- Create configuration file `frps.ini`

My configuration file for `frp server` has following configuration:

```ini
[common]
bind_addr = <external_ip>
bind_port = <port_for_frp_server>

kcp_bind_port = <port_for_frp_server>

vhost_http_port = <port_for_frp_server>
vhost_https_port = <port_for_frp_server>

log_file = <home_dir>/frps/frps.log

log_max_days = 7
log_level = info

authentication_method = token

token = <your_custom_token>

allow_ports = <port for services other than http, can be left same as bind_port>
``` 

Great thing about frp is that it's smart. It's smart to the point that it knows the difference between tunneling traffic and user traffic. 
Thanks to that, it allows you to utilize single port for all the functionality required for forwarding http. 
As I only had a single port reserved on shared hosting, it was great for that purpose. 

To run the frp server in the background, I simply run `./frps -c frps.ini` and leave the screen session with key combination `ctrl + a | d` (that means `ctrl + a` keys and then `d` key)

For going back to frp session you can `screen -r frp_server`

#### Setting up reverse proxy for frp

Because I used shell provider, they've had a nice propertiary GUI for setting up the reverse proxy. Equivalent of that setup would be something along this in `nginx` (assuming nginx and frp are running on the same host).

```nginx
  server { # simple reverse-proxy
    listen  80;
    server_name  frp.your_domain.com;

    location / {
      proxy_pass      http://127.0.0.1:<port_for_frp_server>;
    }
  }
```

I'm using `frp.your_domain.com` for matching the virtual host through whole guide.

Although, **if you use VPS provider**, you should just directly expose the frp proxy on http and https ports by specyfing `vhost_http_port` and `vhost_https_port` as respectively 80 and 443 ports. 
You might also need to run frp as `root` in that case (using `sudo ./frps -c frps.ini` for example) since ports 80 and 443 are only allowed for elevated access.

### Setting up k3s on the home server

I'm assuming you've got the server up and running, configured in your network with private static IP, and that machine has full access to the internet. I personally used Ubuntu 20.04 OS.

To install k3s on that server, all you have to do is run [commands on the k3s site](https://k3s.io/).

```bash
curl -sfL https://get.k3s.io | sh -
# Check for Ready node,
takes maybe 30 seconds
k3s kubectl get node
```

! Warning - always check the content of the shell scripts you're running. Never run untrusted shell scripts directly from the internet.

If you've got it right you should see single node output in `k3s kubectl get node` command. That means it's all working and ready to use.

### Accessing your k3s from outside the machine (but inside the network)

I'm assuming you're using a machine that is in the same network that your home server is. 

Doing everything on the server itself can be tedious so we will use external access to kubernetes cluster.
For that we need to copy a file that was created by k3s in `/etc/rancher/k3s/k3s.yaml`. For that we can simply do `scp <user>@<server>:/etc/rancher/k3s/k3s.yaml .` and that will copy the file onto your local machine.

You also need to change one line in it:

```yaml
server: https://127.0.0.1:6443
```

This needs to be changed to IP address of your home server, in my case it's `10.5.10.5`

```yaml
server: https://10.5.10.5:6443
```

Change it like so, and save the file.

Now you have to install `kubectl`, just [follow the official guide for your OS](https://kubernetes.io/docs/tasks/tools/). In case of arch linux / manjaro, I used `yay kubectl` and installed the available package.

After you get kubectl installed, all that is left to do is to replace your `~/.kube/config` file with the one you just downloaded from your server. Simply run `cp <path_to_k3s.yaml> ~/.kube/config`, in case the directory doesn't exist create it using `mkdir ~/.kube`. 

Now you should see the same output when running `kubectl get nodes` on your PC.

```
NAME             STATUS   ROLES                  AGE   VERSION
intel-nuc        Ready    control-plane,master   21h   v1.21.3+k3s1
```

### Adding frp client to the cluster

As we've got frp up and running, accessing the frp endpoint should yield following output:
{{<figure src="frps-output-unconfigured.png" >}}

That means nothing is yet connected to frp and it is just serving the default page. That also means it's working correctly. 

For setting up frp server in the cluster, I created following k8s manifest `frpc.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: frp
---
apiVersion: v1
kind: Secret
metadata:
  name: frpc-config
  namespace: frp
stringData:
  frpc.ini: |
    [common]
    server_addr = <frps_ip_or_domain>
    server_port = <frps_port>
    token = <your_custom_token>

    [web01]
    type = http
    local_ip = traefik.kube-system.svc
    local_port = 80

    custom_domains = frp.your_domain.com
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: frpc
  namespace: frp
  labels:
    app: frpc
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frpc
  template:
    metadata:
      labels:
        app: frpc
    spec:
      containers:
        - name: frpc
          image: snowdreamtech/frpc:0.37.0
          volumeMounts:
            - name: config
              mountPath: "/etc/frp"
              readOnly: true
      volumes:
        - name: config
          secret:
            secretName: frpc-config
```

If you create `frpc.yaml` file and paste the manifest in it, you should be able to run `kubectl apply -f frpc.yaml` to get `frp` client up and running.

After that, you should see `traefik` error when accessing `frp.your_domain.com` domain. 

```404 page not found```

That means `frp` works correctly and that you're able to access it from the outside. 

#### Storing k8s manifests in git

A nice feature of kubernetes manifests is that you can store them in git repository. 
That means when next time you want to setup a new cluster, or recreate existing one, all you have to do is to just reapply the manifests you stored in git.
That is one of the things that make **Disaster Recovery** faster. You don't have to recreate the setup yourself, you just apply what you already have/had.
This will be even more powerful later on. 