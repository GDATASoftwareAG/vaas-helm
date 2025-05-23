# Verdict-as-a-Service
## Verdict-as-a-Service Helm Chart

Vaas helm is a chart for deploying Verdict-as-a-Service on-premise.

<!-- tag::InstallVaaSHelm[] -->

### Install Verdict-as-a-Service via helm

* Create a minimal values.yaml file. 

To access the VaaS docker containers, you have to provide at least one imagePullSecret.

To set the image pull secret, you need to create a custom values.yaml file that includes the necessary configurations for image pull secrets. Here's how you can do it:

  1. **Direct Image Pull Secrets**: If you have a direct image pull secret (a base64 encoded JSON containing Docker auth config), you can set it directly in the values.yaml file under either of these keys
    * `global.secret.dockerconfigjson`
    * `global.secret.imagePullSecret`
    * `imagePullSecret`

```yaml
global:
  secret:
    dockerconfigjson: "BASE64_ENCODED_JSON_CONTAINING_DOCKER_AUTH_CONFIG"
    imagePullSecret: "BASE64_ENCODED_JSON_CONTAINING_DOCKER_AUTH_CONFIG"
imagePullSecret: "BASE64_ENCODED_JSON_CONTAINING_DOCKER_AUTH_CONFIG"
```

You can generate this value with a bash command like this
```bash
echo '{
        "auths": {
                "ghcr.io": {
                        "auth": "TO_BE_REPLACED"
                }
        }
}' | sed "s/TO_BE_REPLACED/$(echo "username:token" | base64 -w 0 )/g" | base64 -w 0
```

You need to substitute the username and password with the credentials we provided to you.

  2. **Global Image Pull Secrets**: You can specify a list of predeployed image pull secrets under the global.imagePullSecrets key. These are the names of Kubernetes secrets that contain the registry credentials.

```yaml
global:
  imagePullSecrets:
    - my-image-pull-secret
```


* Install Verdict-as-a-Service:

```bash
helm install vaas oci://ghcr.io/gdatasoftwareag/charts/vaas -f values.yaml -n vaas --create-namespace
```

* Updating Verdict-as-a-Service

```bash
helm upgrade vaas oci://ghcr.io/gdatasoftwareag/charts/vaas -f values.yaml -n vaas
```
<!-- end::InstallVaaSHelm[] -->

<!-- tag::GettingStarted[] -->

## Getting started with Verdict-as-a-Service on-premise

Tested prerequisites:

* Ubuntu 22.04
* Minikube 1.32.0
* Java 17
* Vaas Java SDK 6.1.0

### Deploy Verdict-as-a-Service in a Minikube test-environment

* Start Minikube:

```bash
minikube start --cpus="6" --memory="8g" --addons ingress
```

* Check your Minikube IP: ```minikube ip```

* Add Minikube IP to your /etc/hosts:

```
<your-minikube-ip> vaas
```

* Run ```minikube dashboard```

*  Deploy the VaaS helm chart: ```./helm.sh```

* Check the "Workload status" in the Minikube dashboard and wait until it is green.

<!-- end::GettingStarted[] -->

<!-- tag::UseVaaSJavaSDK[] -->
### Use Verdict-as-a-Service with the Java SDK

* Make sure that Java 17 & Gradle is installed.

* Set these environment variables for testing your local instance

```bash
export CLIENT_ID=vaas # default client id for self-hosted vaas
export CLIENT_SECRET=$(kubectl get secret -n vaas vaas-client-secret -o jsonpath="{.data.secret}" | base64 -d) # extracts the client secret from the k8s secret
export SCAN_PATH=./build.gradle # path to the file you want to scan
export VAAS_URL=http://vaas # URL of the VaaS instance you set earlier in your /etc/hosts
export TOKEN_URL=http://vaas/auth/protocol/openid-connect/token # URL of the token endpoint you set earlier in your /etc/hosts
```

Alternatively, if you are using an SDK version that still supports websockets, you have to set another host for the VAAS_URL:

```bash
export VAAS_URL=ws://vaas/ws # URL of the VaaS instance you set earlier in your /etc/hosts
```

* Execute FileScan example in Java SDK example folder

```bash
gradle fileScan
```

<!-- end::UseVaaSJavaSDK[] -->

## Configuring Verdict-as-a-Service

<!-- tag::CloudLookups[] -->

### Cloud lookups

The default configurations are set to provide the best verdict. When you have the need to run this helm-chart without sending the file hashes to our cloud, you can deactivate the cloud lookups with these options:

```yaml
cloud:
  hashLookup:
    enabled: false
  allowlistLookup:
    enabled: false
```

With the `hashLookup`, VaaS uses the G DATA Cloud to obtain additional information about a file and thus enrich the quality of the verdict. Without the hashLookup, this additional information is omitted and files that would ONLY be recognized via the cloud are therefore not recognized.

The `allowlistLookup` is a request of the hash to the G DATA Cloud, against a list of files that we know for sure are not malicious, to prevent false positives. Some clean files are still detected by the scanners signatures and the `allowlistLookup` will prevent these files to be detected as `malicious` or `pup`.

<!-- end::CloudLookups[] -->

<!-- tag::FileSize[] -->

### File size limit
The current file size limit is set to 2G. If you want to adjust the file size for your use case, you have to set the deployments body size limit in `vaas.gateway.ingress.annotations`:

```yaml
gateway:
  ingress:
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: <your maximum filesize>
```

<!-- end::FileSize[] -->

<!-- tag::ConfigureMonitoring[] -->

### Configure monitoring with Sentry

To enable Sentry monitoring, you have to set at least your DSN in the `sentry` section of your `values` file like in the following example. 
ASP.NET Core should be selected as the platform for creating a Sentry project.

```yaml
sentry:
  dsn: "<your sentry dsn>"
```

If nothing is set except the DSN, the defaults lead to the following settings:

- Environment: `Production`
- MaxBreadcrumbs: `50`
- MaxQueueItems: `50`
- EnableTracing: `true`
- TracesSampleRate: `0.5`

These values can be overwritten in the `values` file:
  
```yaml
sentry:
  dsn: "<your sentry dsn>"
  environment: "<your environment>"
  maxBreadcrumbs: <your maxBreadcrumbs>
  maxQueueItems: <your maxQueueItems>
  enableTracing: <your enableTracing>
  tracesSampleRate: <your tracesSampleRate>
```

In addition, Sentry will always behave as follows:

- AttachStacktrace: `true`
- ShutdownTimeout: `5s`
- SendDefaultPii: `false`
- MinimumBreadcrumbLevel: `Debug`
- MinimumEventLevel: `Warning`

<!-- end::ConfigureMonitoring[] -->

### Other values

<!-- tag::OtherValues[] -->

| Parameter                                 | Description                                                                                           | Value                          |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------ |
| imagePullSecret                           | Image pull secret                                                                                     | "e30K"                         |
| global.imagePullSecrets                   | List of image pull secrets                                                                            | []                             |
| global.secret.dockerconfigjson            | Docker authentication configuration                                                                   | "e30K"                         |
| global.secret.imagePullSecret             | Image pull secret                                                                                     | "e30K"                         |
| cloud.hashLookup.enabled                  | Enable/Disable the cloud hash lookup                                                                  | true                           |
| cloud.allowlistLookup.enabled             | Enable/Disable the cloud allowlist lookup                                                             | true                           |
| gateway.ingress.enabled                   | Enable/Disable the Ingress resource                                                                   | false                          |
| gateway.ingress.annotations               | Additional annotations for Ingress                                                                    | {}                             |
| gateway.ingress.hosts                     | Hostnames and paths for Ingress                                                                       | []                             |
| gateway.ingress.tls`                      | TLS configuration for Ingress                                                                         | []                             |
| gateway.ingress.className                 | Class name for Ingress                                                                                | ""                             |
| gateway.authentication.authority          | Authority for authentication                                                                          | ""                             |
| gateway.nameOverride                      | Overrides the application name                                                                        | ""                             |
| gateway.fullnameOverride                  | Overrides the full name                                                                               | ""                             |
| gateway.networkPolicy.enabled             | Enable/Disable the default Network Policy                                                             | false                          |
| gateway.networkPolicy.ingressNSMatchLabels    | Labels to match to allow traffic from other namespaces                                                | {}                             |
| gateway.networkPolicy.ingressNSPodMatchLabels | Pod labels to match to allow traffic from other namespaces                                            | {}                             |
| gateway.service.type                      | Type of Kubernetes service                                                                            | ""                             |
| gateway.service.http.port                 | HTTP port for the service                                                                             | 8080                           |
| gateway.service.ws.port                   | WebSocket port for the service                                                                        | 9090                           |
| gateway.podDisruptionBudget.minAvailable` | Minimum available pods in case of disruption                                                          | 1                              |
| gateway.replicaCount                      | Number of replicas                                                                                    | 1                              |
| gateway.revisionHistoryLimit              | Number of revisions in history                                                                        | 1                              |
| gateway.resources.limits.memory           | Maximum memory usage                                                                                  | 512Mi                          |
| gateway.resources.requests.cpu            | Requested CPU performance                                                                             | 0.5                            |
| gateway.resources.requests.memory         | Requested memory usage                                                                                | 256Mi                          |
| gateway.containerSecurityContext.enabled  | Enable/Disable container security context                                                             | true                           |
| gateway.podSecurityContext.enabled        | Enable/Disable pod security context                                                                   | true                           |
| gateway.uploadUrl                         | URL for the upload service                                                                            | "http://localhost:8080/upload" |
| gateway.podAnnotations                    | Annotations for pods                                                                                  | {}                             |
| gateway.nodeSelector                      | Node labels for pod assignment                                                                        | {}                             |
| gateway.affinity                          | Affinity settings for pods                                                                            | {}                             |
| gateway.terminationGracePeriodSeconds     | Max time in seconds for scans to complete                                                             | 30                             |
| gdscan.networkPolicy.enabled                  | Enable/Disable the default Network Policy                                                             | false                          |
| gdscan.networkPolicy.ingressNSMatchLabels     | Labels to match to allow traffic from other namespaces                                                | {}                             |
| gdscan.networkPolicy.ingressNSPodMatchLabels  | Pod labels to match to allow traffic from other namespaces                                            | {}                             |
| gdscan.nodeSelector                       | gdscan node labels for pod assignment                                                                 | {}                             |
| gdscan.replicaCount                       | Number of replicas for the gdscan deployment                                                          | 1                              |
| gdscan.terminationGracePeriodSeconds      | Max time in seconds for scans to complete. Set to same value as gateway.terminationGracePeriodSeconds | 30                             |
| mini-identity-provider.nodeSelector       | mini-identity-provider Node labels for pod assignment                                                 | {}                             |
| mini-identity-provider.ingress.className  | Class name for Ingress                                                                                | ""                             |

<!-- end::OtherValues[] -->

<!-- tag::ProductionEnviroment[] -->

## Production environment

In production you will have to configure a few values.

<!-- tag::ConfHostname[] -->

### Ingress

The default hostname is "vaas". To change it and provide a tls configuration, add this to your values.yaml:

```yaml
mini-identity-provider:
  issuer: "http://vaas/auth"
  ingress:
    className: ""
    hosts:
    - host: vaas
      paths:
      - path: /auth(/|$)(.*)
        pathType: ImplementationSpecific
        service:
          name: provider
          port: 8080
    tls: []

gateway:
  ingress:
    className: ""
    hosts:
      - host: vaas
        paths:
          - path: /ws
            pathType: ImplementationSpecific
            service:
              name: gateway
              port: 9090
      - host: vaas
        paths:
          - path: /
            pathType: ImplementationSpecific
            service:
              name: gateway
              port: 8080
    tls: []
  uploadUrl: "http://vaas/upload"
```

If you want to use only the HTTP API, it is sufficient to set the port to 8080 for the standard route:
```yaml
mini-identity-provider:
  issuer: "http://vaas/auth"
  ingress:
    className: ""
    hosts:
    - host: vaas
      paths:
      - path: /auth(/|$)(.*)
        pathType: ImplementationSpecific
        service:
          name: provider
          port: 8080
    tls: []

gateway:
  ingress:
    className: ""
    hosts:
      - host: vaas
        paths:
          - path: /
            pathType: ImplementationSpecific
            service:
              name: gateway
              port: 8080
    tls: []
```

To check out, which of the SDKS supports the HTTP API, please check out this [table](https://github.com/GDATASoftwareAG/vaas?tab=readme-ov-file#sdks).

Replace the "vaas" with your hostname in the following values:

* mini-identity-provider.issuer
* mini-identity-provider.ingress.hosts.0.host
* gateway.ingress.0.host
* gateway.ingress.1.host
* gateway.uploadUrl

<!-- end::ConfHostname[] -->

If you require a different ingressClassName than "default", set:

* gateway.ingress.className
* mini-identity-provider.ingress.className

### Zero-trust network configurations

If you are using a zero-trust network configuration, network policies have to be enabled (default). The update
CronJob requires access to the Kubernetes API. If the update fails with logs like:

```
E0603 09:35:50.444603       1 memcache.go:265] couldn't get current server API group list: Get "https://10.96.0.1:443/api?timeout=32s": dial tcp 10.96.0.1:443: i/o timeout
```

you have to configure the k8sApiPort:

```
gdscan:
  autoUpdate:
    networkPolicy:
      k8sApiPort: 6443
```

## Managing the secrets in the values.yaml

By default all secrets are generated by the helm chart. If you want to manage them yourself or you are using ArgoCD, you can
specify the secrets in the values.yaml.

| Parameter                                     | Description                                                                                                                                                                    | Value  |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ |
| mini-identity-provider.auth.existingSecret    | Use existing secret for auth details (auth.secret will be ignored and picked up from this secret). The secret has to contain the keys id and secret                            | ""     |
| mini-identity-provider.auth.secret            | The client secret                                                                                                                                                              | ""     |
| mini-identity-provider.auth.id                | The Client id                                                                                                                                                                  | "vaas" |
| mini-identity-provider.signing.existingSecret | Use existing secret for signing details (signing.cert and signing.key will be ignored and picked up from this secret). The secret has to contain the keys tls.cert and tls.key | ""     |
| mini-identity-provider.signing.crt            | The signing/encryption certificate in PEM format                                                                                                                               | ""     |
| mini-identity-provider.signing.key            | The signing/encryption private key in PEM format                                                                                                                               | ""     |
| gateway.uploadToken.existingSecret            | Use existing secret for signing the upload token                                                                                                                               | ""     |
| gateway.uploadToken.key                       | The upload token signing key                                                                                                                                                   | ""     |

Provide your own secret:

* mini-identity-provider.auth.existingSecret   
* mini-identity-provider.signing.existingSecret
* gateway.uploadToken.existingSecret

Specify secret in the values.yaml:

* mini-identity-provider.auth.secret           
* mini-identity-provider.auth.id               
* mini-identity-provider.signing.crt           
* mini-identity-provider.signing.key
* gateway.uploadToken.key

You can generate the certificate and private key with

```bash
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl req -new -x509 -key private_key.pem -out certificate.pem -days 3650 -subj "/CN=Mini Identity Provider Server Signing Certificate"
```

You can generate the upload token signing key with

```bash
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 256 | head -n 1
```

<!-- end::ProductionEnviroment[] -->
