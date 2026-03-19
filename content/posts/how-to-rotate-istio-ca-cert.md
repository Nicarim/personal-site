---
title: How to rotate Istio TLS certificates without downtime in ambient mode 
date: 2026-03-19T10:00:00+02:00
---

This is rather short note on how to do the certification rotation, as official istio documentation is really sparse on details.

This has been tested on Istio 1.28.1, in Kind cluster, running ambient mode with ztunnel and waypoints.

Issue I've been facing was that whenever I tried to replace the CA Certificates used by istio, Istio Waypoints were unable to communicate with Istio Ztunnel.

It turns out that istio has two options that has to be enabled to make the transition seamless, and you also need to know how to properly modify the certificate chain that you're providing.

## Prerequisites

You have to enable two options in istio before you're able to do it successfully. 

First is [ISTIO_MULTIROOT_MESH](https://istio.io/latest/docs/reference/commands/pilot-agent/#istio-multiroot-mesh). 
This allows istio to properly recognize multiple root certificates as trusted. Without that option, Istio only trusts the first root certificate it has in its configuration (as defined in `root-cert.pem` that you put in `cacerts` secret). 

Second option, is [PROXY_CONFIG_XDS_AGENT](https://istio.io/latest/docs/reference/commands/pilot-agent/#proxy-config-xds-agent) which is not strictly necessary, but makes it much easier and smoother than if you would do without it. If you don't set that option, you will have to make sure that you restart all istio envoy proxies, that is waypoints, gateways, sidecars, what have you, because they won't recognize new certificate.


## Applying the new CA Certificate
Apart from that, follow the procedure found in [Istio/Plug in CA Certificates](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/). Make sure you pull the currently used root certificate with `tools/certs/Makefile.k8s.mk`. You will need it later.

Tl;dr procedure is:

1. Generate the new root certificate
2. Generate the intermediate certificate, which you will likely need if you do multi cluster mesh.
3. Generate the bundle with `<cluster_name>-cacerts` makefile task. 
4. In the generated bundle, copy existing public certificate of currently used root CA and append it to `root-cert.pem`

Once you apply the `cacerts` secret, restart `istiod` first, then `ztunnel` daemonset, and then all the envoy istio proxies (the last step is probably optional with `PROXY_CONFIG_XDS_AGENT`).

Useful command to ensure that your certificates are correctly configured:

```
> istioctl zc certificates <your ztunnel pod>

CERTIFICATE NAME                                        TYPE             STATUS        VALID CERT     SERIAL NUMBER                                NOT AFTER                NOT BEFORE
spiffe://cluster.local/ns/test-server-ns/sa/httpbin     Leaf             Available     true           1c7650353c6c0a4052717827d059d05d             2026-03-20T13:01:53Z     2026-03-19T12:59:53Z
spiffe://cluster.local/ns/test-server-ns/sa/httpbin     Intermediate     Available     true           251091b4f1c4271ee0104c3b5148d6231505d08e     2036-03-16T12:59:51Z     2026-03-19T12:59:51Z
spiffe://cluster.local/ns/test-server-ns/sa/httpbin     Intermediate     Available     true           11334def88f8e6fe9497351504f9db7abe23006a     2036-03-16T12:59:42Z     2026-03-19T12:59:42Z
spiffe://cluster.local/ns/test-server-ns/sa/httpbin     Root             Available     true           11334def88f8e6fe9497351504f9db7abe23006a     2036-03-16T12:59:42Z     2026-03-19T12:59:42Z
spiffe://cluster.local/ns/test-server-ns/sa/httpbin     Root             Available     true           5a17f42f44e6f1fceab06f80b199831cfd3549f2     2036-03-16T11:50:36Z     2026-03-19T11:50:36Z
```

You should see two root certificates, just the ones that you configured. You might need to check multiple ztunnel pods, because if you don't have traffic on a given node - they won't contain any configuration.

This should help you successfully replace existing CA Certificate with a new one, without losing trust in your mTLS mesh traffic. 

