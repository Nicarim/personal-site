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