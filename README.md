# Research Platform

This project is put together with turborepo and git modules.

Object storage module : https://github.com/Mahmoud-nfz/object-storage-solution

Turborepo Apps:

- Frontend: Next.js 14
- Backend: Nest.js

Each package/app is 100% [TypeScript](https://www.typescriptlang.org/).

## How do I run this?

First, run the following command:

```sh
# Https is set as default way to fetch repositories
# For SSH Users: you should run:
# git config submodule.apps/object-storage-solution.url git@github.com:omar-besbes/object-storage-solution.git
# git submodule sync

# if running for the first time :
# git submodule update --init --recursive
git submodule update --remote --merge
```

Then, choose one of the following options:

### Locally, using docker compose (recommended)

```sh
docker compose up
```

### Locally, using k8s

```sh
# Make sure to add DNS and ingress (ngnix)
minikube addons enable ingress

# Make sure that the cluster supports `managed-csi` interface for PVs
minikube addons enable volumesnapshots
minikube addons enable csi-hostpath-driver

# Create a namespace for the services
kubectl apply -f manifests/overlays/local/namespace.yaml

# Make sure to build the images and push them to your own docker registry
kubectl create secret docker-registry efreireg \
    --namespace=efrei-dev-local
    --docker-server=<server_name> \
    --docker-username=<username> \
    --docker-password=<pwd>

kubectl apply -k manifests/overlays/local
```

## Turborepo

### Build

To build all apps and packages, run the following command:

```
pnpm build
```

### Develop

To develop all apps and packages, run the following command:

```
pnpm dev
```

### Remote Caching

Turborepo can use a technique known as [Remote Caching](https://turbo.build/repo/docs/core-concepts/remote-caching) to share cache artifacts across machines, enabling you to share build caches with your team and CI/CD pipelines.

By default, Turborepo will cache locally. To enable Remote Caching you will need an account with Vercel. If you don't have an account you can [create one](https://vercel.com/signup), then enter the following commands:

```
npx turbo login
```

This will authenticate the Turborepo CLI with your [Vercel account](https://vercel.com/docs/concepts/personal-accounts/overview).

Next, you can link your Turborepo to your Remote Cache by running the following command from the root of your Turborepo:

```
npx turbo link
```
