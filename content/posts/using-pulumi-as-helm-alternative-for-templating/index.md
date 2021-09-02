---
title: "Using Pulumi as Helm Alternative for Templating"
date: 2021-09-02T14:23:03+02:00
draft: false
---

# I hate Helm
I truly hate helm. It's not because it's a bad idea, core idea of Helm does actually solve a problem that you often meet with deploying manifest (customization). It's not because I don't know how to use it - I used it to create many deployments and I truly appreciate its existence.

But I hate it to the heart.

Why you might ask?

It's because most of the time Helm tends to become total customization of the chart. Literally. If you try to use any off the shelf helm charts you will often meet with following dilemma:
- Should I customize that helm according to my need?
	- If yes, I need to untangle the spaghetti monster
	- If not then see:
- Should I create a new chart for my own needs?
	- If yes - I need to add just so much customization to fit my needs
	- If not - I'm left with kustomize or directly using manifests

## Spaghetti monster
Grafana helm chart:
{{<figure src="Pasted image 20210902093820.png">}}

I mean yeah, if you're familiar with what helm does and you've done quite a few you will quickly come to understanding to what is going on. 

The thing is it's loser's game.

Initially you use helm to be able to customize the image version, then you add image name because you might use your own registry, then you need to customize labels because you need to enable some traefik based rules, then you need to add tolerations and affinity, then you need to make conditional deployments based on environment....

The list goes on.

In the end you end up with totally customizing the manifests that were simple in the beginning. And you do it to achieve ... what exactly? 

**I have this feeling we do helm charts so we can have dumbed down manifests**

And Helm doesn't help us much in that regards.

Public helm charts are especially in the worst place. They simply CANNOT cater to everyone needs. Yet they try to do that. It's nice when you want to experiment, but you need to understand what the chart is doing, what are its params and using public charts is just asking for disaster (in terms of maintainability) IMO.

## Ready made manifests
Some projects decide it's not worth the trouble and they provide ready-made manifests [like ArgoCD](https://github.com/argoproj/argo-cd/releases/tag/v2.1.1)

This is nice if you want to get started, as that manifest will get you up and running. But that becomes a problem if you decide to customize it. You basically have to copy and paste it's content and customize, write your own manifests or fallback onto creating helm chart out of the values you want to customize. Basically either use the ready made manifest, or DIY, no middleground. (Some might say kustomize is a middleground, but I don't buy it)

There is [community maintained helm chart](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd) for argocd - but again, it provides you with ... almost whole templating of the manifest.

{{<figure src="Pasted image 20210902101339.png">}}

Am I delusional or what we're actually solving here is just making DRY packages out of manifests? Like if you want to change the name of the app, you could edit it in 3 places in manifests or single value in helm. That's all? My god. 

Example in the image could've been replaced with just providing ability to put whole `dict` as `livenessProbe` value... And if `livenessProbe` has additional property added that's not here, you're out of luck, make your own chart!

...


# Looking for alternatives

There are several tools available:
- [helm](https://helm.sh/) (our main rant target)
- [kustomize](https://kustomize.io/)
- [tanka](https://tanka.dev/)
- [jsonnet](https://jsonnet.org/)
- [ksonnet](https://github.com/ksonnet/ksonnet) - unmaintaned

I only used the first two of them, but I wanted to explore more. 

Oh also, there is infra as a code tooling that you could use to manage kubernetes like:
- [ansible](https://docs.ansible.com/ansible/latest/collections/community/kubernetes/k8s_module.html) - This is some alternative, but like I mentioned in some other blog post - ansible won't be able to track removals of resources unless you explicitly ask for it (Helm handles that if you use it as package manager)
- [terraform](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#authentication) - I really tried to love terraform in that regards, but managing kubernetes resources in helm is kind of a PITA. One thing you might often stumble upon is authentication issues if you're using [kubernetes resources in same module as your kubernetes cluster definition](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources)
- [pulumi](https://www.pulumi.com/docs/intro/cloud-providers/kubernetes/) - **this is IMO a nice proposition to be able to manage your infrastructure using real language.** And this is something I want to discover today

# Pulumi as YAML manifests provider

I don't want to use full pulumi's capabilities. I'd like to first merely evaluate it's templating proposition 

## Getting started with pulumi

### Installing on Manjaro

As I use manjaro, I simply used `yay pulumi` and installed first package from AUR `aur/pulumi-bin` version `3.11.0-1`

### Configuring local state backend
By default pulumi wants you to use their service to store your state and manage it. I wanted to test it locally so I used 
```
pulumi login --local
```

### Generating basic structure
Pulumi offers ready made templates for getting started, I used 

```
pulumi new kubernetes-typescript
```

And followed the guide to setup the project.

```
├── index.ts
├── node_modules
├── package.json
├── package-lock.json
├── Pulumi.dev.yaml
├── Pulumi.yaml
└── tsconfig.json
```
This is the project structure that got generated.

```ts
import * as k8s from "@pulumi/kubernetes";

const appLabels = { app: "nginx" };
const deployment = new k8s.apps.v1.Deployment("nginx", {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: { containers: [{ name: "nginx", image: "nginx" }] }
        }
    }
});
export const name = deployment.metadata.name;
```

And this is example deployment within that structure. Let's try to apply it to `k3d` environment.

### Creating YAML provider

```
const provider = new k8s.Provider("k3d-testing", {
    renderYamlToDirectory: "output",
})
```

I've created an instance of provider which will output the objects that were created during the pulumi run to a directory called `output` instead of trying to apply it onto the cluster.

### Adding provider to resources
For resources to use the provider, I need to add that provider as `CustomResourceOptions`, it's third argument in `Deployment` specification. It accepts key called `provider` with value of provider object that we want to use.

This is final code
```diff
import * as k8s from "@pulumi/kubernetes";
import * as kx from "@pulumi/kubernetesx";

+const provider = new k8s.Provider("k3d-testing", {
+    renderYamlToDirectory: "output",
+})

const appLabels = { app: "nginx" };
const deployment = new k8s.apps.v1.Deployment("nginx", {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: { containers: [{ name: "nginx", image: "nginx" }] }
        }
    }
+}, { provider });

export const name = deployment.metadata.name;
```

### Generating YAML
Now I was able to run `pulumi up` and after confirming the plan I've got output directory with YAML files:

```
> tree output                                     
output
├── 0-crd
└── 1-manifest
    └── deployment-default-nginx-z43htl4z.yaml
```
And the YAML file is just as specified in the code.  Pretty neat.

### Moving provider configuration to global scope
Pulumi's documentation mentions 3 different ways to specify provider settings to the resource, one of them being explicit (just what we did), and other being "Default provider config" and "Dynamic Providers"

[Documentation of Default provider config](https://www.pulumi.com/docs/intro/concepts/resources/#default-provider-configuration)

It says we can setup `pulumi config set aws:region us-west-2` to change provider's region in case of AWS. 

Syntax for that is `<namespace>:<key>` but quite honest - I got lost here. Where do I get namespace from? I guess for kubernetes provider it is `kubernetes` but documentation nowhere says how are these defined. 

I can just guess by going to provider settings and checking the url `https://www.pulumi.com/docs/reference/pkg/kubernetes/provider/` and conclude that `kubernetes` is the namespace they're talking about.

Let's try to set it using CLI config.

```
pulumi config set "kubernetes:renderYamlToDirectory" "output"
```

And running `pulumi up` shows us this:

```
Previewing update (dev):
     Type                              Name                   Plan        Info
     pulumi:pulumi:Stack               pulumi-kubernetes-dev              
 +-  ├─ kubernetes:apps/v1:Deployment  nginx                  replace     [diff: ~metadata,provider]
 -   └─ pulumi:providers:kubernetes    k3d-testing            delete      
 
Resources:
    - 2 to delete
    +-1 to replace
    3 changes. 1 unchanged
```

Pretty scary, but agreeing to these changes just means it removes the custom provider and then it uses values we provided to the default config.

It again just generated yaml to `output` directory just with slightly different values in... `metadata.name: nginx-huq9n9w3`

Huh

So previously name of the nginx was `nginx-z43htl4z` but now we got `nginx-huq9n9w3` 

### Making the name of resource static
So that is no good, I want to keep track of the same nginx across changes that I make.

Let's try to add `metadata.name` to our deployment.

```diff
const deployment = new k8s.apps.v1.Deployment("nginx", {
+    metadata: {
+        name: "nginx"
+   },
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: { containers: [{ name: "nginx", image: "nginx" }] }
        }
    }
});
```

Yep, after adding it and applying to our yaml we've got static name of our deployment. Just `nginx`.

We could now apply that `nginx` config to our cluster and all would be good.

## Customization using Pulumi
But that was easy example and nothing we couldn't achieve with simple yaml. This is even more verbose than yaml thanks to `{}` everywhere. So what's the benefit?

We now need to try something more complicated like replicating Helm's behavior (just the templating part!) in Pulumi. 

I'll go with the previously mentioned ArgoCD project (which btw could replicate whole Helm's behavior of tracking changes) and try to make a customization for their provided yaml file.

### Importing ArgoCD manifests
For that, we will use [yaml](https://www.pulumi.com/docs/reference/pkg/kubernetes/yaml/) resources in Kubernetes provider.

Specifically we will use `ConfigFile`.

Let's write some code for that - first let's start with something simple like importing the file and just outputting it without changes.

First I've created a directory structure of `k8s_manifests/argocd` in our project's root.

Then I downloaded [the manifest](https://raw.githubusercontent.com/argoproj/argo-cd/v2.1.1/manifests/install.yaml) from the repository of ArgoCD. As of writing that is `v2.1.1` version. I've renamed it to `install-v2-1-1.yaml` to just reflect the version we will be using.

Here is the code to import the manifest as Pulumi object:

```ts
import * as k8s from "@pulumi/kubernetes";

const example = new k8s.yaml.ConfigFile("argocd", {
    file: "k8s_manifests/argocd/install-v2-1-1.yaml",
});
```

Let's generate it directly to our output dir.

```diff
> pulumi up          

Previewing update (dev):
     Type                                                 Name                         
     pulumi:pulumi:Stack                                  pulumi-kubernetes-dev         
+   └─ kubernetes:yaml:ConfigFile                        argocd                      
+      ├─ kubernetes:core/v1:Service                           argocd-server-metrics   
+      ├─ kubernetes:core/v1:ConfigMap                         argocd-cmd-params-cm  
 
 # (... many more resources later ...)
 
Resources:
    + 41 to create
    - 1 to delete
    42 changes. 1 unchanged

Do you want to perform this update? yes
```

Applying it yields a nice output to our `output` dir with every resource seperated into its own file.

```
> tree output
output
├── 0-crd
│   ├── customresourcedefinition-default-applications.argoproj.io.yaml
│   └── customresourcedefinition-default-appprojects.argoproj.io.yaml
└── 1-manifest
    ├── clusterrolebinding-default-argocd-application-controller.yaml
    ├── clusterrolebinding-default-argocd-server.yaml
    ├── clusterrole-default-argocd-application-controller.yaml
    ├── clusterrole-default-argocd-server.yaml
    ├── configmap-default-argocd-cmd-params-cm.yaml
    ├── configmap-default-argocd-cm.yaml
    ├── configmap-default-argocd-gpg-keys-cm.yaml
    ├── configmap-default-argocd-rbac-cm.yaml
    ├── configmap-default-argocd-ssh-known-hosts-cm.yaml
    ├── configmap-default-argocd-tls-certs-cm.yaml
    ├── deployment-default-argocd-dex-server.yaml
    ├── deployment-default-argocd-redis.yaml
    ├── deployment-default-argocd-repo-server.yaml
    ├── deployment-default-argocd-server.yaml
    ├── networkpolicy-default-argocd-application-controller-network-policy.yaml
    ├── networkpolicy-default-argocd-dex-server-network-policy.yaml
    ├── networkpolicy-default-argocd-redis-network-policy.yaml
    ├── networkpolicy-default-argocd-repo-server-network-policy.yaml
    ├── networkpolicy-default-argocd-server-network-policy.yaml
    ├── rolebinding-default-argocd-application-controller.yaml
    ├── rolebinding-default-argocd-dex-server.yaml
    ├── rolebinding-default-argocd-redis.yaml
    ├── rolebinding-default-argocd-server.yaml
    ├── role-default-argocd-application-controller.yaml
    ├── role-default-argocd-dex-server.yaml
    ├── role-default-argocd-server.yaml
    ├── secret-default-argocd-secret.yaml
    ├── serviceaccount-default-argocd-application-controller.yaml
    ├── serviceaccount-default-argocd-dex-server.yaml
    ├── serviceaccount-default-argocd-redis.yaml
    ├── serviceaccount-default-argocd-server.yaml
    ├── service-default-argocd-dex-server.yaml
    ├── service-default-argocd-metrics.yaml
    ├── service-default-argocd-redis.yaml
    ├── service-default-argocd-repo-server.yaml
    ├── service-default-argocd-server-metrics.yaml
    ├── service-default-argocd-server.yaml
    └── statefulset-default-argocd-application-controller.yaml

2 directories, 40 files
```

That's pretty neat!

It has also put CRD (Custom Resource Definition) into separate directory which is crucial for applications using CRDs. If you try to apply manifests in reverse order - first deployments and stuff and then CRD - you might meet with errors that there is no such resource or stuff like that. 

### Customizing ArgoCD manifest
Now to the meat of what we need - let's try to modify our deployments so that all deployments tolerate dedicated node for deploying argoCD. 

For that we need to apply [toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) to our deployment

#### Using transformations
Pulumi offers functionality called [transformations](https://www.pulumi.com/docs/intro/concepts/resources/#transformations) which allow you to make changes to the objects produced by your provider.

I'll be quite honest that this function is quite complicated to me at first and I've had need to reread the documentation over and over since it doesn't provide anymore examples than what you've seen.

But I was able to find [another example on awsworkshop.io](https://pulumi.awsworkshop.io/additional-content/150_deploying_argocd_to_eks/30_declare_argocd_helm_chart.html) which helped me understand it a little bit better.

Here is my explanation on how to use it:

```ts
const example = new k8s.yaml.ConfigFile("argocd", {
    file: "k8s_manifests/argocd/install-v2-1-1.yaml",
    transformations: [
        (obj: any) => {
            console.log(obj)
        }
    ]
});

```

Key `transformations` accepts a list of functions (anonymous, named, any), and every function will be called for every object generated by the resource. In case of `ConfigFile` it calls it for every resource found in the manifest. 

Example `obj` that you will on pulumi run:

```ts
obj = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
	labels: {
	  'app.kubernetes.io/component': 'server',
	  'app.kubernetes.io/name': 'argocd-server',
	  'app.kubernetes.io/part-of': 'argocd'
	},
	name: 'argocd-server'
  },
  spec: {
	selector: { matchLabels: [Object] },
	template: { metadata: [Object], spec: [Object] }
  }
}
```

That is a single call of your transformation function. 

Now what we need to do is wait for the function to be called with `kind: Deployment` and make our change to the object.

To do that we can write following code:

```diff
const example = new k8s.yaml.ConfigFile("argocd", {
    file: "k8s_manifests/argocd/install-v2-1-1.yaml",
    transformations: [
        (obj: any) => {
+           if (obj.kind == "Deployment" && obj.apiVersion == "apps/v1") {
+               // Here is our deployment, let's add toleration
+               obj.spec.template.spec.tolerations = [{
+                   key: "example-key",
+                   operator: "Exists",
+                   effect: "NoSchedule",
+               }]
            }
        }
    ]
});

```

This will generate following YAML diff (difference between previous as-is and modified YAML)

```diff
diff --git a/output/1-manifest/deployment-default-argocd-dex-server.yaml b/output/1-manifest/deployment-default-argocd-dex-server.yaml
index 16c5463..13ef072 100644
--- a/output/1-manifest/deployment-default-argocd-dex-server.yaml
+++ b/output/1-manifest/deployment-default-argocd-dex-server.yaml
@@ -63,6 +63,10 @@ spec:
         - mountPath: /tmp
           name: dexconfig
       serviceAccountName: argocd-dex-server
+      tolerations:
+      - effect: NoSchedule
+        key: example-key
+        operator: Exists
       volumes:
       - emptyDir: {}
         name: static-files
diff --git a/output/1-manifest/deployment-default-argocd-redis.yaml b/output/1-manifest/deployment-default-argocd-redis.yaml
index e281df7..5e35df1 100644
--- a/output/1-manifest/deployment-default-argocd-redis.yaml
+++ b/output/1-manifest/deployment-default-argocd-redis.yaml
@@ -49,3 +49,7 @@ spec:
         runAsNonRoot: true
         runAsUser: 999
       serviceAccountName: argocd-redis
+      tolerations:
+      - effect: NoSchedule
+        key: example-key
+        operator: Exists
diff --git a/output/1-manifest/deployment-default-argocd-repo-server.yaml b/output/1-manifest/deployment-default-argocd-repo-server.yaml
index 67f93bd..bb6c828 100644
--- a/output/1-manifest/deployment-default-argocd-repo-server.yaml
+++ b/output/1-manifest/deployment-default-argocd-repo-server.yaml
@@ -153,6 +153,10 @@ spec:
           name: argocd-repo-server-tls
         - mountPath: /tmp
           name: tmp
+      tolerations:
+      - effect: NoSchedule
+        key: example-key
+        operator: Exists
       volumes:
       - configMap:
           name: argocd-ssh-known-hosts-cm
diff --git a/output/1-manifest/deployment-default-argocd-server.yaml b/output/1-manifest/deployment-default-argocd-server.yaml
index d3d0776..80d3a5b 100644
--- a/output/1-manifest/deployment-default-argocd-server.yaml
+++ b/output/1-manifest/deployment-default-argocd-server.yaml
@@ -219,6 +219,10 @@ spec:
         - mountPath: /tmp
           name: tmp
       serviceAccountName: argocd-server
+      tolerations:
+      - effect: NoSchedule
+        key: example-key
+        operator: Exists
       volumes:
       - emptyDir: {}
         name: plugins-home

```

Now that's pretty cool. But the code is quite ugly - there is so many ifs and it is not apparent on how it works at a first glance.

How can we make the code better?

#### Making transformations mixins
We can create our own library of transformations!
Strength of the programming languge at our disposal is that we can do whatever we want. (Of course that's also our weakness, you can do *whatever you want*)

But FWIW let's make a transformation mixin. We will call it `AddDeploymentTolerationMixin` that will add to all deployments tolerations that we specify.

What we can do is we can return a prepared closure with arguments that we specify. 

```ts
const AddDeploymentTolerationMixin = (toleration: any) => {
    return (obj: any) => {
        if (obj.kind == "Deployment" && obj.apiVersion == "apps/v1") {
            // Here is our deployment, let's add toleration
            obj.spec.template.spec.tolerations = [toleration]
        }
    }
}
```
This is our mixin that will add toleration to deployments. It's pretty simple and will do most of the job so we can just forget about its implementation details. 

Now onto the eye candy

```ts
const example = new k8s.yaml.ConfigFile("argocd", {
    file: "k8s_manifests/argocd/install-v2-1-1.yaml",
    transformations: [
        AddDeploymentTolerationMixin({
            key: "new-key",
            operator: "Exists",
            effect: "NoSchedule",
        })
    ]
});
```

Now we've abstracted away the transformation and it's pretty clear what it does. We can reuse it for all of our deployments that origin from ready-made manifests!

# Wrapping up
Ok that was pretty extensive write up. I wanted to see how viable pulumi is for generating the yamls, and this looks really cool. One thing which makes it a little bit annoying is the fact that Pulumi was not made for templating only and it's best if you use full features of it (make it manage the cluster) because otherwise the tool will feel prety bulky. 

But the good news is that if you use Pulumi to manage these manifests you will probably replicate most of the functionality of Helm (since it will take care of cleaning and updating the resources).

I'm impressed by how easy it was to customize the manifest, and I honestly think we should take that approach instead of Helm's hell.
