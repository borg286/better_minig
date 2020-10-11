# tl;dr
To provide a turn-key setup that streamlines writing microservices and pushing them to kubernetes in an intent-based pipeline. This setup pulls together the following technologies
1. Kubernetes for infrastructure abstraction and microservice management
1. Bazel for fast and correct builds
1. K8s_rules to bridge the above 2
1. Grpc and protobuf for enabling cross micro service communication written in nearly any language
1. Redis for lightweight database, caching, and fun stateful storage and processing
1. Prometheus and Graffana for monitoring and alerting
1. Jsonnet and json for configuration language


# How to run
## Install k3d if necessary
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

## Create a network for a fixed IP for node 1
docker network create --subnet=172.19.0.0/26 k3d-network

## Create kubernetes cluster
k3d cluster create --volume ./registries.yaml:/etc/rancher/k3s/registries.yaml --network k3d-network

## Setup
bazel run //prod:apply

## Create a java grpc hello world client and recursively create all dependencies
bazel run //java/com/examples/grpc-redis/client:myns-deep.apply

# What is going on under the hood

##  K3d
K3d is a tool to run k3s (lightweight kubernetes cluster, supporting multi-node) in a docker container with support for common extras like ingress.

### Why k3s vs minikube vs. GKE
k3s runs in GCP Cloud Shell, and minikube doesn’t. GKE costs and the overhead doesn’t leave much on a small VM. K3s can run anywhere.

## Docker
Docker is a container management tool that provides a sandbox for binaries to run in, as well as streamlining downloading chains of images that contain the data needed for the binary. Lots of systems have docker avaliable on them. We end up using it to run an entire kubernetes cluster, with the capability of exposing ports to the web. In our case the web would be our host system.

## docker network and registries.yaml
I want to do local development, which includes pushing to a local docker repository. Since K3d runs crictl inside its node and doesn’t share images with the host docker system I need to push to a self-hosted docker registry. Since I don’t get a dns name available on my host I opted for direct IP address. I tried securing it with tls but found go-containerregistry library treats ip ranges for localhost virtual networks as insecure (http) I downgraded all systems to access the private registry using http. Of course when you deploy this in production you’ll deploy a secure one, but for local development it doesn’t expose a port on the host so it is secure. The registries.yaml instructs k3s to use the http schema when fetching images hosted with the private registry.

## bazel
Bazel is a build system capable of building in virtually every language. It is very opinionated in how build rules behave deterministically from the same input. The benefit is fast and correct builds. 

### WORKSPACE
Bazel reads a top level WORKSPACE file to understand the external dependencies and set of rules that are available for your code to call upon. These external dependencies are fixed with SHAs or well known github commits and point to other bazel workspaces with dependencies of their own.

I included dependencies for building a grpc service in various languages (see below), creating kubernetes configs, maven jars for a handful of libraries, jsonnet with a jsonnet library for making kubernetes config files.

### run
Bazel’s main purpose is to build artifacts, many of which are the end executables you want to push. We are building a script to use kubect and push configs to kubernetes, and then having bazel run it.

### //prod:setup.apply
Artifacts are specified by build targets, starting with // which means the top directory, then any folders. The last folder must have a BUILD file which contains the config for a particular build target you want. In this case under prod/BUILD there is a target with name=”setup”. This is a wrapper around other k8s_objects that each are scripts. These scripts have create, apply, and delete variant.  The k8s_objects rule takes the name and generates a setup.create, setup.apply, and setup.delete script which do their respective action with kubectl on any of the manifests generated from the dependencies.  This rule is meant to wrap around all the manifests that should get pushed to kubernetes as a prerequisite for other resources.  Namespaces and Custom Resource Definitions often belong under this umbrella.

### prod/registry.jsonnet
One of the leaf steps that setup does is generate a json file that would make kubernetes run a private docker registry. Jsonnet is a way to output json but by using a language that supports inheritence, importing, computation, lambdas, functions, libraries, and general fancy stuff. The tool to render the json file is contained within a bazel dependency declared in the WORKSPACE file. We use a bazel rule that enables a wide range of data routing options. It also allows for outputting multiple files, which we use to produce a deployment and service. If we were using tls we would modify the jsonnet to add a volume to a secret that you would store asychronously and independently of easily accessable code.

### k8s_object (name=”local-registry”)
After the jsonnet_to_json rule, we consume its output in a bazel k8s_object rule. This rule generates a script that uses kubectl under the hood, passing a reference to a copy of the json file. Note the reference it has to the json file is not in our codebase, but is an artifact that bazel creates in a separate directory. In fact all the files passed to kubectl are contained in some subdirectory in bazel’s bazel-out folder. This can theoretically be packaged up and ran on its own with the exact same behavior. A future improvement would be to pack it into a docker image, push to a private registry and ran by a worker with restricted ACLs to the cluster, thus eliminating the need for developers/ops people from keeping wide ACLs on their local machine.

### ENVS for loop in prod/BUILD
It is common to separate out production from staging, dev, and even local testing. This is envisioned as kubernetes namespaces. Kubernetes doesn’t stop pods from talking to other pods in different namespaces. Cross namespace communication often happens when one team has fewer or more levels of environments than others. It is left up to you to monitor traffic and enforce standards.

The local testing is set up so that each developer can either point to a local kubernetes cluster and do whatever, or use a shared cluster but keep their testing to their own namespace. This is achieved by using the linux $USER as the name for the namespace. We’ll see reference to this later.

### Custom Resource Definitions
Custom Resource Definitions allow for kubernetes to know about arbitrary resources, and for other systems to rely on common structure for when their special resources are instantiated onto a cluster.  Prometheus and graffana use these for helping create dashboards.  Microservices can then create “grafana dashboard” definitions and “prometheus rules” definitions specific for ther microservice. Before the grafana and prometheus servers and turn up these definitions we must teach kubernetes what these definitions look like.

## //java/com/examples/grpc-redis/client.apply
### java
This repository is meant to provide some groundwork for some common languages by making a hello world client-server stack that uses grpc.

### grpc-redis
On top of using the routeguide client and server example, I swapped out the database it used (text file read by both client and server) for a redis database. The server populates it when it starts up and waits for requests.

###  client
The Routeguide hello world example is composed of showcasing how to use grpc to define a service that can accept RPCs of protobufs and return other well defined protobufs. The .proto file is stored centrally in the proto folder. 

### client/BUILD
This file is broken down into 4 parts
1. Java docker image
1. Constants
1. Jsonnet_to_json
1. k8s_object[s]

#### Java docker image
Bazel knows how to compile java, and can bundle all dependencies into a fat jar. this would be done with a build rule java_binary(...). Another bazel import we use allows us to package up docker images and mirrors these _binary rules with _image rules with effectivly the same signature.

#### Constants
BUILD files are technically python under the hood, but limit most python programming to be put in rules files called .bzl. However you can have constants and have loops in the form of list comprehensions. I end up using list comprehensions on the list of environments ENVS which is imported from the cluster_constants.bzl file. The other constants I have are mostly for reuse so I only have to specify it once rather than having another build rule need to tease it out of an artifact from the first. We also declare image tags for each environment.  

We made the choice of having intent drive production rather than having some imperitive system carry binaries to different environments. You’ll note that there is a map, mapping environment names to docker image tags. The expectation is that there is some agent on a VM that is pulling from head the repository and trying to push the binary belonging to the environment it needs to push. If instructed to push prod, the prod image tag will be the one that makes it into the prod manifest rather than using a tag that the code at head. Whereas the myns, or deveoper, environment ends up getting its docker tag replaced at push time with the sha of the docker image from the _image build rule.

#### Jsonnet_to_json
This is the powerhouse of routing data into my manifests. It handles importing json files and artifacts. It handles importing jsonnet libraries. I handles pulling in strings as raw data, as well as parsing it into json objects. I use this latter feature by dynamically constructing a json map parsed from python formatting a python map using the “%s”. This enables me to route the namespace names, which could be hard coded, except for the developer specific one which uses $USER instead. I also use this to route the docker image tags into the manifest so it produces different versions, one for each environment. Often developers want to handle different environments in one place. I opted for having a better programming language to support this handling, namely jsonnet, as the python in bazel is very restrictive. Thisbrings us to the jsonnet itself that produces the json we feed into kubectl.

#### client.jsonnet
This is where we have our configuration code that produces our json kubernetes manifests.
I import some jsonnet functions to make it easier to have different values used dependent on the environment.
I also import some jsonnet libraries that simplify making common kubernetes resources like services,deployments, statefulsets, container descriptions, volumes, secrets…
Jsonnet provides us with the language verbosity to span json as well as be more programatic in how we construct, inherit, and modify json objects.

Lastly we package all the kubernetes json objects into a list, keyed by the filename, which is relied on by the jsonnet_to_json rule.

One thing that our client is dependent on is the service name and port number of the hello world server it is availiable through. We use bazel dependencies to pull out the service.yaml file from this dependency and extract the service name and port. This enables us to change the service name in one place, and then let bazel figure out what dependent service was using it and route the new value to them so they get updated as soon as possible. I opted for using the service.yaml file as an abstraction layer rather than referencing python constants as that felt leaky.

#### k8s_object
k8s_rules is a bit opionated w.r.t. how your manifests are broken down. In yaml files kubernetes allows you to smush multiple resource configs together separated only with ---, but json doesn’t allow this, nor does k8s_rules make this easy. Rather you track each and every yaml/json manifest and wrap it with a k8s_object rule and specifically declare its type. It uses this type to know which manifests might have docker image references in them which might need to be swapped out for one that bazel just barely built and pushed to a registry. In our case only the myns, or development, manifest gets this treatment.  All others get an empty map for what substitutions to perform.

The k8s_object is a rule generated in the WORKSPACE file because it depends on the kubernetes cluster you are using. I reuse cluster_constants.bzl to route that data in. This produces a rule that must be imported separatly from the others that come with k8s_rules.

#### k8s_objects and shallow vs. deep
This standard k8s_rules rule simply packages up multiple manifests into one unit that mirrors the kubectl actions of create, apply, and delete. It even can pull in other k8s_objects, which we use to declare both a shallow and deep target. The shallow target only includes the manifests for the client and anything that it needs within its sphere of microservice.  The deep target pulls in the manifests of the services direct dependencies, notably their deep target. If those dependencies’ deep targets include others, then it recurses till you have a full stack. This entire stack can be deployed in a single command.

#### bazel run //java/com/examples/grpc-redis/client:myns-deep.apply
Bazel compiles and runs a script which relies on kubectl existing on the host and is configured to talk to whatever cluster we used in cluster_constants. The script will push the java_image to our private docker registry running in kubernetes itself, because this is the myns environment. The prod/staging/dev targets rely on a fixed image sha. It will then do any stamping and image replacement in the manifest. It then runs kubectl using the apply action on the provided manifests. Note that the order of files is arbitrary, and should remain so.  Kubernetes is an intent based system rather than imperative one. Creating a service w/o first creating the pods that the service fronts should not generate an error but simply result in the service being non-functional until the pods come up. All manifests may have dependencies on other resources being up, but should be written in such a way that they simply wait gracefully for their dependencies.  Any harder dependencies, like the existence of the namespace or a custom resource definition, should be put in the //prod:setup build rule.

#### Kubernetes world
Bazel should have pushed the docker images into our private registry using the http schema rather than https, and k3s should know to pull them down with http thanks to the registries.yaml we fed it earlier. Kubernetes then schedules the pods and creates the services. These include a service for the java hello world route guide server, as well as a service for the redis cluster. These services will be unavailable until the java server is up, which itself is unhealthy till it can connect to the redis service. The service only connects to healthy endpoints. 

#### Redis as a database
Each redis endpoint only responds healthy to accepting traffic if the CLUSTER INFO command to redis returns with “cluster_status: ok”. This is dependent on there being a quorum of masters it can connect to. This is dependent on turning up enough nodes. This is dependent on the first node getting brought up in a healthy state thanks to it being a stateful set. The stateful set uses etcd in kubernetes to confidently assert that there is only one node being turned up at a time and that node 0 is turned up and is healthy first.

A database is only as good as it's commitments, including resilience to disruptions. These can be node failures and network partitions. Obviously our single k3s cluster-on-a-stick container is far from reliable, and persistence is intentionally limited to make starting from a clean slate easier. But in a proper kubernetes cluster and taint applied to Redis masters and a proper persistent volume service, you would enjoy proper reliability. Redis gives high availability thanks to fast failovers. It offers not-quite-acid, which is technically no acid, guarantees on data. Later I'll sort out a more acid database. But with the local storage kubernetes gives we can update Redis without losing data, even if we have a full service outage and all Redis pods go down, we can confidently restart from the persistent data owned by each Redis pod.

#### Deep dependency chain turnup
After redis comes up healthy and a cluster is formed it signals the service it can take traffic, the java server connects and opens its service to route requests. The client keeps trying to send RPCs to the server which, when opened up, make the server fetch data from redis, on whichever shard that data belongs to. The client then logs its results which you can read with kubectl logs <insert pod id>.

#TODO
Main doc that hosts my thoughts https://docs.google.com/document/d/15_0YQdT_D2lpTCC2OfhxECfLNjz9Pt6a8bGbhF3pQ7Q/edit#heading=h.uzpgfj40m626


# Services to incorperate

* Sandstorm or Appscale
* Cassandra for a blobstore-like service
* Kubernetes ScheduledJob documentation
* Etcd at a global service
* Gerrit for code review
* opentelemetry.io
* Spark for offline processing
* ScyllaDB for eventual high-write rate
* Spark Streaming
* leveldb/hyperdb/rocksdb/lmdb or something to handle packing data/protobufs into files

# Neet to implement services
* FCM for alert notifications, as well as irc chats.
* Silence Manager, I think that an existing alert manager with prometheus has one.
* url shortener
* canary analysis that feeds off of prometheus data and gives verdict if there is stastical difference betwen the 2 streams.
* load shedding library
* ACL library
* weekly summary of work in md format
* meta channel
  * Rate limiting
  * Experiment data
  * Auth tokens
* Playbook service
* dos protection
* Lamprey services
  * Pubsub
  * cache
  * Quota checker
  * Logging (log4j2 with prometheus defaults)
* rpcz (context routed around to report count of RPCs broken down by incomming service,method and outgoing method,service.
* Jira or something like that
* IRC with FCM push capabilities


