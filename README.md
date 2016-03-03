## docker Makefile

Sometimes you need a Makefile to build a set of Docker Images.

Some very good examples are, where you need to do some "stuff" before or after a docker image is built.

``docker-compose`` does a very good job for making, running and stitching together Docker images.

But for other times, you just need a ``Makefile``

We want
- build all the docker images in _this_ directory
- a `Dockerfile` to be a dependant file on the "image" (the entry in `docker images`)
  eg: change the `Dockerfile` and it builds just that _image_ again
- a way to encode the user/name:version to be used
- `make` to handle the "dependant" docker images
- not have to make any changes to the `Makefile` for adding another docker image

We don't need to
- worry about pulling a remote docker image (docker can do that just fine)
- care about running them (often the run is VERY complex.. use ``docker-compose``

### TODO

Work out a clever way to create the "depends" setup.
It will involve writing a .depends `Makefile` for `sinclude`


### Some Conventions

#### Image Version

We need a way to "encode" a version of the _to be built_ docker image.
So we use a LABEL inside the Dockerfile

```
LABEL build.publish.version="0.2"
```

#### Image "User" Prefix

We need a way to "encode" the "user" of the _to be built_ docker image.
So we use a LABEL inside the Dockerfile

```
LABEL build.publish.username="otheruser"
```

### Example
```
rbuckland@ve2:~/projects/personal/docker-makefile$ make
::: Creating otheruser/image1:0.2
Sending build context to Docker daemon 2.048 kB
Step 1 : FROM alpine
 ---> 70c557e50ed6
Step 2 : LABEL build.publish.version "0.2"
 ---> Running in 6bebe2c2f774
 ---> e28a6bee8c58
Removing intermediate container 6bebe2c2f774
Step 3 : LABEL build.publish.username "otheruser"
 ---> Running in 79d0f203673b
 ---> 2367905f3fe0
Removing intermediate container 79d0f203673b
Step 4 : RUN touch foobar
 ---> Running in 7b1a2ea07ac0
 ---> d78126b6a410
Removing intermediate container 7b1a2ea07ac0
Successfully built d78126b6a410
::: Creating image2:0.2
Sending build context to Docker daemon 2.048 kB
Step 1 : FROM alpine:3.3
 ---> 70c557e50ed6
Step 2 : LABEL build.publish.version "0.2"
 ---> Using cache
 ---> e28a6bee8c58
Step 3 : RUN touch image2
 ---> Running in b97b9a38c399
 ---> 8e730db66cf5
Removing intermediate container b97b9a38c399
Successfully built 8e730db66cf5
::: Creating image3:latest
Sending build context to Docker daemon 2.048 kB
Step 1 : FROM alpine
 ---> 70c557e50ed6
Step 2 : RUN touch foobar
 ---> Running in cfd43ba5e04b
 ---> f7a97b7d74d1
Removing intermediate container cfd43ba5e04b
Successfully built f7a97b7d74d1
::: Creating myuser/image4:latest
Sending build context to Docker daemon 2.048 kB
Step 1 : FROM alpine
 ---> 70c557e50ed6
Step 2 : LABEL build.publish.username "myuser"
 ---> Running in 10d19e60acc1
 ---> 07c3218cf3c6
Removing intermediate container 10d19e60acc1
Step 3 : RUN touch foobar
 ---> Running in 364fe2dbcace
 ---> 15f0babf0a93
Removing intermediate container 364fe2dbcace
Successfully built 15f0babf0a93
rbuckland@ve2:~/projects/personal/docker-makefile$ touch image3/Dockerfile
rbuckland@ve2:~/projects/personal/docker-makefile$ make
::: Creating image3:latest
Sending build context to Docker daemon 3.072 kB
Step 1 : FROM alpine
 ---> 70c557e50ed6
Step 2 : RUN touch foobar
 ---> Using cache
 ---> f7a97b7d74d1
Successfully built f7a97b7d74d1
rbuckland@ve2:~/projects/personal/docker-makefile$ make clean
find . -name .docker-identity | xargs cat | sed 's/sha256://g' | xargs docker rmi --force ; \
find . -type f -name .docker-identity -exec rm {} \;
Untagged: otheruser/image1:0.2
Deleted: sha256:d78126b6a410991908351ef53bc9fac3adf2a68cceba466aa4669f21df55eed5
Deleted: sha256:03642e26c4af804db7eabe2ac26c328119cb84b3f58b2541d6a289202d320a62
Deleted: sha256:2367905f3fe092aa70d96afe79627517825bed4e09c05a5c8a379fc53530c0a1
Untagged: image2:0.2
Deleted: sha256:8e730db66cf51a3105872fb9b0a49ab8ba5d6b1fbe6d3c6c05446f6769cb99be
Deleted: sha256:ec83855254ee58ac766b5428f60d72e9ab3796325faacc0c898deaf8c4af5f41
Deleted: sha256:e28a6bee8c58af554121ea20a1af602e03ae3fad11d4e91d172cfc092e34eb88
Untagged: image3:latest
Deleted: sha256:f7a97b7d74d15d51434405ce36c59c6dfc873e420053474a478f221658216583
Untagged: myuser/image4:latest
Deleted: sha256:15f0babf0a938d27ab7be09f7946faef75883f1e59e60ec9829ba06904bf88c9
Deleted: sha256:bb833e7004c1a214b2cead408f6de4c58f01c8c490dfbbe940317a395ec962d6
Deleted: sha256:07c3218cf3c661f27e6df282f862b2dcba240a9c9d3c33f1cbc3116a51bcf063
```
