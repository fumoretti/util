# Airbyte install

Steps for airbyte install with helm.

## requirements

- a kubernetes cluster
- kuberctl and helm clients configured
- a certificate if using https (custom CA for *.local.lan in this example)

## install airbyte via helm

```
helm repo add airbyte https://airbytehq.github.io/helm-charts

helm repo update
```

Check __values.yml__ and change setthings as you need before next commands... Then install airbyte:

```
helm install \
airbyte \
airbyte/airbyte \
--namespace default \
--values ./values.yaml
```

This kubernetes is dedicated for this airbyte deploy so i'm using the default namespace. Make sure to create a dedicated one if you are installing it in no dedicated kubernetes cluster.

## create ingress and first user secret

Apply the manifests and kubectl commands as follow.

### client password secret

Change password as needed in __client-password-secret.yml__ and than apply it with kubectl:

```
kubectl apply -f client-password-secret.yml
```

### create tls secret for ingress

If you want to use HTTPs to access airbyte (recommended), change airbyte.crt and airbyte.key with your own files and than create the secret with kubectl:

```
kubectl create secret tls airbyte-tls \
--cert=airbyte.crt --key=airbyte.key \
--namespace=default
```

### create ingress

For a HTTPS/TLS ingress with HTTP to HTTPS redirect, change the host value in __ingress-tls.yml__ and apply then with kubectl. You need to use the same host as defined in __values.yml__.

I'm using k3s as kubernetes and traefik as igress, so make sure you make necessary changes in the follow digests.

```
kubectl apply -f ingress-tls.yml
```

For a plain HTTP ingress (without TLS), you need to change and use __ingress.yml__, than apply with kubectl.

```
kubectl apply -f ingress.yml
```

## Conclusion

Now if all OK you can access airbyte, for the first access you will be asked to setup a new user providing an email address. This email address will be the default admin of airbyte and can be used with the password defined in the __client password secret__ step.




