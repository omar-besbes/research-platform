# Research Platform

This project is put together with turborepo and git modules.

Object storage module : https://github.com/Mahmoud-nfz/object-storage-solution

Turborepo Apps:

- Frontend: Next.js 14
- Backend: Nest.js

Each package/app is 100% [TypeScript](https://www.typescriptlang.org/).

## Technologies

This repository makes use of these technologies in order to run:

- [Docker](https://www.docker.com) | [License](https://www.docker.com/pricing/faq/)
- [Kubernetes](https://kubernetes.io) | [License](https://github.com/kubernetes/kubernetes/blob/master/LICENSE)
- [Elasticsearch](https://www.elastic.co/elasticsearch) | [License](https://www.elastic.co/licensing/elastic-license)
- [MinIO](https://min.io/product/enterpriseoverview) | [License](https://min.io/product/enterpriseoverview)
- [Postgres](https://www.postgresql.org) | [License](https://www.postgresql.org/about/licence/)

## How do I run this?

Make sure you have [Docker](https://docs.docker.com/engine/install) and [Git](https://git-scm.com/download) installed.
First, clone the repo and run the following command:

```sh
# (Optional)
# HTTPS is set as default way to fetch repositories.
# For SSH Users, you should run:
git config submodule.apps/object-storage-solution.url git@github.com:Mahmoud-nfz/object-storage-solution.git
git submodule sync

# if running for the first time:
git submodule update --init --recursive
# else:
git submodule update --remote --merge
```

Then, choose one of the following options:

### Locally, using docker compose (recommended)

```sh
docker compose up
```

You can access the platform at [http://localhost:3010/login](http://localhost:3010/login).

When finished, clean up with this command:

```sh
docker compose down
```

### Locally, using k8s

Make sure you have [Minikube](https://minikube.sigs.k8s.io/docs/start) installed.

```sh
# Make sure to add metrics api support
minikube addons enable metrics-server

# Make sure to add DNS and ingress (ngnix)
minikube addons enable ingress

# Make sure that the cluster supports `managed-csi` interface for PVs
minikube addons enable volumesnapshots
minikube addons enable csi-hostpath-driver

# Create a namespace for the services
kubectl apply -f manifests/overlays/local/namespace.yaml

# (Optional)
# If you want to build the images and push them to your own docker registry,
# make sure that you override the container registry in `manifests/base/kustomization.yaml`
# and to create credentials for the k8s cluster to connect to:
kubectl create secret docker-registry efreireg \
    --namespace=efrei-dev-local
    --docker-server=<server_name> \
    --docker-username=<username> \
    --docker-password=<pwd>

kubectl apply -k manifests/overlays/local

# It may take a while for the platform to be up and running,
# you may run this to monitor the state of the cluster.
minikube dashboard

# Once all deployments are green in `efrei-dev-local` namespace, do `Ctrl + C` and run the following command:
minikube service -n efrei-dev-local frontend
# This will open up the frontend in your browser,
# navigate to `/login` to login.
```

When finished, clean up with this command:

```sh
minikube delete
```

## Setting up an account

Now, that we have a running instance of the platform, we need to create an account to be able to login and start interacting with it.

Currently, the only supported method of doing this is by querying the backend service directly.

```sh
curl -X POST http://localhost:3011/auth/add-user \
     -H "Content-Type: application/json" \
     -d '{"email": "foulen@efrei.com"}'

curl -X POST http://localhost:3011/auth/complete-signup \
     -H "Content-Type: application/json" \
     -d '{
           "firstName": "Foulen",
           "lastName": "Fouleni",
           "password": "SomePwd@2024",
           "email": "foulen@efrei.com"
         }'
```

And that's it. Now, we have a user named Foulen with email `foulen@efrei.com` and a password `SomePwd@2024`.

> [!Note]
> All requests that might be needed during development are stored in `bruno-collections`, in the format used by [bruno](https://www.usebruno.com/).

## Turborepo

### Build

To build all apps and packages, run the following command:

```sh
pnpm build
```

### Develop

To develop all apps and packages, run the following command:

```sh
pnpm dev
```

### Remote Caching

Turborepo can use a technique known as [Remote Caching](https://turbo.build/repo/docs/core-concepts/remote-caching) to share cache artifacts across machines, enabling you to share build caches with your team and CI/CD pipelines.

By default, Turborepo will cache locally. To enable Remote Caching you will need an account with Vercel. If you don't have an account you can [create one](https://vercel.com/signup), then enter the following commands:

```sh
npx turbo login
```

This will authenticate the Turborepo CLI with your [Vercel account](https://vercel.com/docs/concepts/personal-accounts/overview).

Next, you can link your Turborepo to your Remote Cache by running the following command from the root of your Turborepo:

```sh
npx turbo link
```
