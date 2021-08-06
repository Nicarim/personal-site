---
title: "Infra as a Code Is Cloud Lock-In"
date: 2021-08-04T20:23:53+02:00
draft: false
---

UPDATE (2021-08-06): In a hindsight I think I choose wrong title to describe the concept. More appropriate would be "Modern infra automation state management is gateway drug for using more cloud provided services" or something along these lines. Initial thought on title came from the fact that I considered terraform/pulumi to be truly "Infra as a code" solution, while Ansible (second tool that I use for automation) being subpar in that experience (and hence more of "commands over SSH" thing than true infra state manager).  

I'm a big fan of using IaaC tooling in all of my DevOps jobs.
It's a great pleasure to be able to define your infrastructure in a code and exactly know 
what do you have in your cloud. It helps you avoid the situation where you have to ask people in the company to know where something lives. You can simply `CTRL+F` through the project (assuming you store it in a single repo) and you always know where something is.

Two(three?) biggest tools in that area are [Terraform](https://www.terraform.io/) (best with [Terragrunt](https://terragrunt.gruntwork.io/)) and [Pulumi](https://www.pulumi.com/). These tools allow for (almost) full idempotency when setting up environment in your cloud provider. Once things are deployed, you can be sure that what is in the cloud - is in fact there. You can then create different environments for your service and work based on that assumption.

However, these things are best when used with well documented and well developed cloud providers such as AWS, Azure, GCP, DigitalOcean and so on. 

And they work best IF you use services provided by them. 

You can for example set up SSO guarded access to services using [AWS Cognito](https://aws.amazon.com/cognito/) and passing that traffic through [App Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) to make your services inaccessible without proper access. All that can be written in a code stored in a Git repository and make it reproducible and even modularize it to use with different services.

## Putting off rose-colored glasses

However, things start to get sketchy when you consider that you would like to set same thing up using off-the-shelf solutions like [Caddy](https://caddyserver.com/). There is a great plugin for Caddy called [caddy-auth-portal](https://github.com/greenpau/caddy-auth-portal) which more or less can provide same functionality as the setup mentioned in previous paragraph.

And how do you use it with your like... on-premise infrastructure? Or just your cloud instances like EC2?

## Welcome to the land of mess

If you have worked with infrastructure, your first bet will be to just use infra automation tools like [Ansible](https://docs.ansible.com/ansible/latest/index.html). 

However you won't find anything in ansible to manage Caddy, or to manage anything at all. Ansible in this case will be just a fancy SSH command runner with some modules that make your life easier, all wrapped in a all-loved YAML and Jinja2 templates.

## How does Terraform comapre to Ansible?

Let's take these two cases. 

We would like to setup SSO access to application which doesn't support it out of the box. For sake of argument let's assume its Prometheus dashboard with default settings. 

### Terraform

First you setup your AWS_ACCESS_KEY and AWS_SECRET. 

After that you can start working with AWS.

For cognito setup I've just found already made module by community:

https://github.com/trussworks/terraform-aws-saml-cognito/blob/main/main.tf

Not going into much detail - you setup resources for AWS Cognito user pool with SAML identity provider. 

Then you setup load balancer targeting your service (be it in internal network) using ready-made example in [terraform documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener#authenticate-cognito-action)

```
resource "aws_lb" "front_end" {
  # ...
}

resource "aws_lb_target_group" "front_end" {
  # ...
}

resource "aws_cognito_user_pool" "pool" {
  # ...
}

resource "aws_cognito_user_pool_client" "client" {
  # ...
}

resource "aws_cognito_user_pool_domain" "domain" {
  # ...
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.pool.arn
      user_pool_client_id = aws_cognito_user_pool_client.client.id
      user_pool_domain    = aws_cognito_user_pool_domain.domain.domain
    }
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}
```

Assuming you tweak things here and there - viola, your service is now SSO enabled. 


### Ansible

Well, you first need to know your instance that you will be setting up. You need to have it running and define it upfront, because ansible is just automation around running commands in SSH.

Your computer also needs proper SSH access to that server (and this can differ depending if you're behind firewall or not). 

After that, you need to know which operating system you will target. And there can be differences between different providers of these operating systems too! 

Now let's assume you are using Ubuntu 20.04. There will be a difference between using fresh Ubuntu server and already setup ubuntu server, and also a difference if you're using it without sudo access.

If you got Ansible setup right, you can now use some ready-made community role like https://github.com/caddy-ansible/caddy-ansible

But setting up these parameters wil require you writing down a jinja based template for configuration if role variables are not sufficient for setting it up. 

You also need to think about how to get public IP access to the server - if your server is behind firewall you will need to maybe setup some kind of firewall rules? IDK

But let's continue, now these role only installs ansible itself, we need to specify `caddy_package` in its variable to install `greenpau/caddy-auth-portal`

I don't want to make it too long - but you can clearly see my point. This land is undocumented, not standarized, and just plain hard. That's why terraform in my opinion is so powerful. Providers there and their documentation just helps tremendously, and the fact you have everything in a single place is also a big plus.

## Cleaning up

### Terraform

`terraform destroy`

### Ansible

:)

Ansible is just fancy ssh command runner remember? it can't tell a damn thing about current state of the system or reverse its changes. Your best bet is to just reinstall the OS.

## Summary

Terraform is great when it works, infra as a code is a blessing when you want to create maintainable infrastructure in a cloud provider of your choice. Just don't get your hope too high if you step off the rails and try to use something NOT provided by the cloud services. You're then in a land of despair.

And IMO there is huge land for improvement here.