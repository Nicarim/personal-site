---
title: "Living in the IDE - or Why I Really Like HCL and Loathe YAML"
date: 2021-08-05T17:07:59+02:00
draft: false
---

There are things that I enjoy when working as a professional. 
One of them is that when the tooling is so good that it just makes want to write the code.
Example of state-of-the-art integration of IDE into a language is what Hashicorp has done to the Terraform and its integration with IntelliJ IDEA.

An example of that you can find below

{{< figure src="autocomplete-works-out-of-the-box.png" title="Autocomplete works out of the box, no configuration needed" >}}

One might say "yeah, its just a simple gimmick, it will fall apart for more complex things!" like it often can be the case with dynamic languages.

### Simple autocomplete

{{< video src="screencast-aws-instance" height="400px" width="auto" >}}

That looks good. Autocomplete tells us what basic blocks can we use to build our terraform module. How far can we stretch it?

### Autocomplete of variables

{{< video src="screencast-var" height="500px" width="auto" >}}

You can see that variables are not a problem for autocomplete.

### Autocomplete of resources

{{< video src="screencast-resource-dependency" height="500px" width="auto" >}}

This is a little bit harder - autocomplete is aware of the resource type and can propose its variables too!

### Autcomplete of modules

This is something I would not expect out of autocomplete. Terraform is able to index available modules (as long as you install them `terraform init`) and gives you autocomplete for that too!

{{< video src="screencast-module-autocomplete" height="500px" width="auto" >}}

If I'm familiar with the module - I don't have to go to the documentation at all. I have all variables at my disposal and ready to be used. Its like magic for me.

### Using IDE is easier than using AWS dashboard

This is somewhat a stretch, but what I mean by that is that if I know how a certain service works in AWS, for me personally its a lot easier to write terraform modules instead of clicking around in AWS. I don't want to dismiss the dashboard completely. If there is a service I didn't use yet, I explore its options using AWS dashboard, maybe even do a test run, and then go back to terraform file to write it down. 

I often lean on the side of [KISS](https://en.wikipedia.org/wiki/KISS_principle) when it comes working with technologies. For me its often easier to use provider's dashboard than to use CLI or god forbid API when documentation is not clear. It's the same for me in Python - I always try to add annotations where possible so that I don't have to go out of the editor to find out about variable. But not every package in python is annotated.

But using terraform? I can do everything inside IDE without going out of it and keep being focused as I create thinks using magic dust of autocomplete. 

I can't say the same about other infra automation tools.

### It's all intentional

Hashicorp has made explicit decision to support this kind of flow. They provide their [own official language server](https://github.com/hashicorp/terraform-ls) for VSCode and other products that use LSP protocol

While writing this paragraph I also wanted to mention IntelliJ support being official, but it looks like the [plugin is quite outdated](https://plugins.jetbrains.com/plugin/7808-hashicorp-terraform--hcl-language-support/reviews). While reviews are harsh and I have myself sometimes faced with the fact that something is not recognized - I still think its good enough for what I uset it for. Although I would appreciate if HashiCorp and/or Jetbrains has put some more effort into keeping this good and not to outdate this post praising their technology for free ;)

## Comparing terraform to other projects

I might be harsh to the ansible. I still consider the tool to be great and really helpful when working on infra automation. However, I just can't use it without frustrating myself.

### Documentation
I was mainly focused on autocomplete features, but let's take a moment to compare both documentations of resources.

{{< figure src="terraform-resources-docs.png" title="Here is how it looks like in terraform. Beware - search on the left works immediately and precisely." height="500px">}}

How does it look like in Ansible?

{{< figure src="ansible-docs.png" title="Ansible - here is the best overview you can get" height="500px">}}

I just don't know, I had to include this rant here. I really enjoy how easy it is to get an overview in terraform and how I lack it in ansible. I've to make at least 3 clicks more to get into the same informations and search at best looks like this

{{< figure src="ansible-user-search.png" title="Looking for user module is like looking for needle in the haystack...">}}

Why do I mention documentation? You will see in a moment

## Working in IDE with Ansible

This has and is a big frustration of mine. I like Ansible, I like its simplicity and that you can easily make it for many things. But IDE support? Is non existent.

Let's consider the same things I considered in terraform example.
Again, using IntelliJ.

### Ansible IDE plugin

There are actually two plugins available. Or three, or four, I don't know. None of them are considered official by any means for IntelliJ. 

{{< figure src="ansible-ide-plugin.png" title="Which one should I choose?" height="300px">}}

There are three plugins which you can consider:
- YAML/Ansible support - free but outdated (last update Oct. 2020)
- OrchidE Ansible Language - Paid (!) (I don't have anything against paying, but if I were paid customer of Ansible, and then I have to pay for plugin created independently...)
- Ansible - this one is quite new and I just discovered it now.

Opinions on the last choice were promising so I went with that one. 

### Simple autocomplete

{{< figure src="ansible-autocomplete-simple.png" title="We got some suggestions" >}}

Just so you're aware, this is [quite fresh](https://github.com/MSDehghan/AnsiblePlugin) plugin, with init commit 12 months ago. Before that things were not as easy. 

### Autocomplete of resources

{{< figure src="ansible-copy-autocomplete.png" title="How nice">}}

I didn't expect that, last time I checked at best there was nothing at this stage. Let's move further.

{{< figure src="ansible-copy-params.png" title="And we can see params too!" >}}

Another nice surprise, we got support for the params. 

### Autocomplete of variables

{{< figure src="ansible-no-vars.png" title="Aaand it fails" >}}

I very often work with variables in ansible, and autocomplete of that could be a blessing. Sadly no such nice things when using ansible.

### Autocomplete of roles 

Following the same expectations from terraform - let's try autocomplete when it comes to community-made modules - called roles in ansible.

For that I downloaded a role from a really popular role creator [geerlingguy/ansible-role-apache](https://github.com/geerlingguy/ansible-role-apache)

{{< figure src="ansible-role-name-autocomplete.png" title="We got list of available roles!" >}}

I've to give a big shoutout here to the creator of [this Ansible plugin](https://github.com/MSDehghan/AnsiblePlugin) - really great job on making such things working at all! This is article is by no means criticism of lacking features in that plugin. Intention of this article was to point out such a big lack of support in YAML based tools and in fact, I'm really happy to discover that it exists and will probably start to use it when working with Ansible. 
However, my point is that I'd really **expect Red Hat** to actually make it work and make it good for the sanity of all developers working with Ansible. 

But good things always comes to an end - I've tried to get list of variables that are accepted by the role and there is nothing :(.

{{< figure src="ansible-role-vars-no.png" title="And we don't get any info about the role's defaults" >}}

This is yet again that thing that hinders my productivity a lot - when I've to shuffle through many things to get to actually know what are my choices even. I just really enjoy that when without switching tabs (context) and always scratching my head "where can I find this info?" I can get all the info from autocomplete. That is why I even bother using IDE at all. 

## Final notes

I think I have an idea where does the difference come from. There are two things that come to my mind:
- HashiCorp just cares about developers experience, and RedHat is just too big of a company to even care about it
- HCL was made with the premise in mind that [YAML is not good enough for configuration language](https://github.com/hashicorp/hcl#why). Parsing HCL and knowing from the context what values are accepted where is just a lot easier. 

Of course, there are a lot of criticizm for HCL lang. Just a quick search on [the internet](https://www.google.com/search?hl=en&q=hcl%20lang%20is%20bad) gives you some negativity on HCL, with comments being like

> Lol I totally agree. HCL combines the worst aspects of JSON and YAML into a single language! [src](https://www.reddit.com/r/webdev/comments/i1jhl6/why_does_hashicorp_have_their_own_config_language/fzy1gdg/?utm_source=reddit&utm_medium=web2x&context=3)

> HCL is a bad idea... Coming from a JSON/XML-only (read .NET) world, I've found YAML to be straight-forward with a shallow learning-curve. Why not unify Hashicorp's config languages under YAML? [src](https://github.com/hashicorp/hcl/issues/151#issue-176182414)

Be ware that this comments come from old days of HCL when it was pretty new idea. 
And based on the comparison above I could say following thing:
**Be careful what you wish for**

HCL may have its issues, it may not be the best in class, but alternatives? 
YAML Is not any better, at best autocompletion for it is far worse because its structure is just arbitrary "dicts of lists of values". HCL at least made it easier to be able to tell "This is Resource, hence it accepts specific values". Even if its just fancy wrapper for JSONs. Makes life easier for everyone.




