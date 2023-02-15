---
title: 4. Deploying to Azure
---

# 4. :cloud: Deploying to Azure

Now that we've got a working continuous deployment pipeline taking changes to our code and pushing Docker images up into the GitHub Container Registry, we can deploy our application to the cloud as a cloud-native web service.

To do this, we're going to use [Microsoft's Azure](https://azure.microsoft.com/en-gb){target="_blank" rel="noopener noreferrer"} cloud computing service - in particular, a service called [Azure App Service](https://azure.microsoft.com/en-us/products/app-service/){target="_blank" rel="noopener noreferrer"}.

## Recap - cloud and Azure

Before we dig into Azure App Service, let's have a quick recap on what we discussed earlier about the cloud in general and Azure specifically.

"Cloud" is a phrase that gets thrown around a lot, but what does it [actually mean](https://xkcd.com/908/)?

Some people like to say that "the cloud is other people's computers" - and this is kind of true. It's a massive network of computers linked together by complex software-based networking and redundancy, but it's still other people's computers.

These computers are physical things you can go visit. If you can get past Microsoft's security team, that is. (Which you probably can't.) I'd recommend visiting virtually, instead - you can do a [full virtual tour of an Azure data centre](https://news.microsoft.com/stories/microsoft-datacenter-tour/) - it's pretty neat!

![Satellite view of Des Moines data centre](images/4-deploying-to-azure/microsoft-des-moines-data-centre.png){: style="width: 100%"}

**Microsoft's Des Moines data centre, a.k.a. "US Central"️<br>© Google Maps**
{: style="font-size: small; margin-top: -25px; width: 100%; text-align: center;"}

### Economies of scale

The main advantage of the cloud is economy of scale. If I wanted to start a business that does machine learning, I'd need to buy a bunch of expensive GPUs (i.e.a big capital investment) before I could start to do any good research which I could then sell on. With the cloud, I can just tap into some of Microsoft's existing GPUs and pay an hourly rate for just the time I need.

Because Microsoft have thousands of servers and GPUs, they're able to manage them much more cost and time efficiently, and thus pass on those scaling efficiencies to end users.

### Managed services and SEP theory

One of the main advantages of using cloud service providers like Microsoft's Azure is that you can utilise what are referred to as managed services. This means that Microsoft take care of all of the effort of maintaining a particular application like a database or web server or whatever, and give you a nice self-service interface to be able to use this service.

For instance, if you want to host your own PostgreSQL database, you could spin up a fresh VM and install PostgreSQL on it - sounds simple, right? Managing a production database at scale with high available is immensely difficult. With Azure's "Azure Databases for PostgreSQL" managed service, Microsoft handle all the management, maintenance, replication, failover, etc. and give you a button that says "New database", saving you many, many days of installing, debugging, monitoring and so on. You still need to do some monitoring and management, obviously, but nothing like you need to do if you're rolling your own database.

This is referred to[^1] as SEP theory - by using managed services, you're making more things Somebody Else's Problem.

We will be using the managed service called "Azure App Service" which we're using essentially as "running a Docker container as a service". (App Service also supports uploading your code only and selecting a runtime.)

[^1]: By me

### Azure terminology

**Tenant:** This identifies the Azure "directory" that you are in. A single account can log into multiple directories and each directory is entirely separately from each other. Typically, your company will have one (or more) directories dedicated to it. The tenant is the highest level container within Azure - everything in Azure from accounts to subscriptions to resource groups to individual resources are all contained within a tenant.

**Subscription:** A tenant has one or more subscriptions within in. Each subscription is essentially a "costing centre" - it's how Azure ties your payment details (e.g. your credit card) into Azure. Costing is done at the subscription level and all resource groups and individual resources live within a subscription. It's essentially the layer below the tenant.

**Resource group:** Individual resources like databases and apps cannot live freely but live within a particular resource group. A resource group is a way of grouping together different resources that relate to a particular product or feature. For instance, you might want to have a "web portal" resource group that contains the API, frontend and database for your web portal, while another resource group called "data pipeline" contains all the resources for your data processing pipeline.

**Resource:** A resource is the individual instance of a service that you are using in Azure. An app in Azure App Service is a resource. An instance of Azure SQL is a resource, and so on.

### Getting set up with the Azure CLI

We're going to be using the Azure CLI to create our app. You can use the portal too, but we're using the CLI.

First things first, make sure the Azure CLI is installed - if you're using the GitHub codespace, this should come pre-installed. You can check this with:

```bash
az --version
```

If it's not installed, follow the instructions here to install it: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#installation-options

You should've received or have access to a tenant, subscription, username and password to login to Azure. Let's use that to login to the Azure CLI:

```bash
tenant_id="our tenant ID"
subscription_id="our subscription ID"
sp_app_id="your username"
sp_password="your password"

az login --service-principal --tenant "$tenant_id" -u "$sp_app_id" -p "$sp_password"
```

To verify that you're successfully logged in, run:

```bash
az account show
```

To make sure you're in the right subscription, you can run:

```bash
az account set --subscription "$subscription_id"
```

!!! info "What's a Service Principal (SP)?"
    Azure has normal users associated with emails, and it also has accounts designed to be used by machines like CI pipelines. These are called "Service Principals" or SPs for short.
    
    We're using one of these accounts for the purpose of this Explain course. This is basically just for convenience - if you're managing your Azure resources in real life, you'll be logged in with your email address instead of a service principal. Everything else is the same between them apart from your can't log into the Azure Portal in your browser using a service principal. We can still use the Azure CLI, though!

### Creating the Azure App Service app

Now that we're logged into Azure, let's create our app.

We are putting our app into a resource group that we've created especially called `hncdi-explain-supercharge`. It has to be in this resource group because the service principal we're using has its permissions restricted to that resource group.

Before we can create our app, we need to create a service plan for this app to be associated with. A service plan is how Azure decides what resources to allocate to your app. You can scale up your service plan after you've created it, so you can dynamically scale your resource based on your requirements.

This is great because it means that you can start off on a cheap (or even free) plan, then only scale up to more expensive plans when you need to!

Let's create our app service plan in the ["B2" tier](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/) using Linux, which means that we get 2 vCPUs, 3.5 GB of RAM and 10 GB of storage. That should be plenty for our purposes.

```bash
my_app_name="put something unique to you in here, like your name or random string"

az appservice plan create --name "$my_app_name-plan" --resource-group "$resource_group" --sku B2 --is-linux
```

Now we're ready to create our actual app:

```bash
my_github_username="put your GitHub username here"

az webapp create --name "$my_app_name-app" \
    --resource-group "$resource_group" \
    --plan "$my_app_name-plan" \
    --deployment-container-image-name "ghcr.io/$my_github_username/distilgpt2-api:latest"
```

This might take a couple of while to complete. This is because our Docker image is about 1.5 GB, mostly of which is pytorch runtime dependency files. Be patient with it and if you think it's actually stuck, just let us know and we can debug it together over Zoom.

Once it finishes, you should be able to access your API using the URL https://$my_app_name-app.azurewebsites.net where you replace `$my_app_name` with the name you decided to use for your application.
