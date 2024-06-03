# Verdict-as-a-Service Helm Chart

Vaas helm is a chart for deploying Verdict-as-a-Service on-premise.

## Install Verdict-as-a-Service

1. Create a minimal values.yaml file:

To access the VaaS docker containers, the image pull secret has to be set in the `global.secret.dockerconfigjson` variable.

`values`-File for a minimum example deployment:

```yaml
global:
  imagePullSecrets:
    - registry
  secret:
    dockerconfigjson: "$$_BASE64_ENCODED_JSON_CONTAINING_TOKEN_$$"
```

2. Install Verdict-as-a-Service:

```bash
helm install vaas oci://ghcr.io/gdatasoftwareag/charts/vaas -f values.yaml -n vaas --create-namespace
```

### Updating Verdict-as-a-Service

```bash
helm upgrade vaas oci://ghcr.io/gdatasoftwareag/charts/vaas -f values.yaml -n vaas
```

# Verdict-as-a-Service on-premise

## Getting started

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

* Check the "Workload status" in the Minikube dashboard and wait until it is green

### Use Verdict-as-a-Service with the Java SDK

* Make sure that Java 17 & Gradle is installed

* Set these environment variables for testing your local instance

```bash
export CLIENT_ID=vaas # default client id for self-hosted vaas
export CLIENT_SECRET=$(kubectl get secret -n vaas vaas-client-secret -o jsonpath="{.data.secret}" | base64 -d) # extracts the client secret from the k8s secret
export SCAN_PATH=./build.gradle # path to the file you want to scan
export VAAS_URL=ws://vaas/ws # URL of the VaaS instance you set earlier in your /etc/hosts
export TOKEN_URL=http://vaas/auth/protocol/openid-connect/token # URL of the token endpoint you set earlier in your /etc/hosts
```

* Execute FileScan example in Java SDK example folder

```bash
gradle fileScan
```

## Configuring Verdict-as-a-Service

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

### File size limit

If you want to scan larger files, you have to adjust the deployments body size limit in `vaas.gateway.ingress.annotations`. Should looks like this:

```yaml
nginx.ingress.kubernetes.io/proxy-body-size: <your maximum filesize>
nginx.ingress.kubernetes.io/proxy-request-buffering: "off"
```

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

### Other values

| Parameter                                  | Description                                                                                                 | Value                            |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | -------------------------------- |
| `global.imagePullSecrets`                  | List of image pull secrets                                                                                  | `- name: registry`               |
| `global.secret.dockerconfigjson`           | Docker authentication configuration                                                                         | `""`                             |
| `cloud.hashLookup.enabled`                 | Enable/Disable the cloud hash lookup                                                                        | `true`                           |
| `cloud.allowlistLookup.enabled`            | Enable/Disable the cloud allowlist lookup                                                                   | `true`                           |
| `gateway.ingress.enabled`                  | Enable/Disable the Ingress resource                                                                         | `false`                          |
| `gateway.ingress.annotations`              | Additional annotations for Ingress                                                                          | `{}`                             |
| `gateway.ingress.hosts`                    | Hostnames and paths for Ingress                                                                             | `[]`                             |
| `gateway.ingress.tls`                      | TLS configuration for Ingress                                                                               | `[]`                             |
| `gateway.ingress.className`                | Class name for Ingress                                                                                      | `""`                             |
| `gateway.authentication.authority`         | Authority for authentication                                                                                | `""`                             |
| `gateway.nameOverride`                     | Overrides the application name                                                                              | `""`                             |
| `gateway.fullnameOverride`                 | Overrides the full name                                                                                     | `""`                             |
| `gateway.networkPolicy.enabled`            | Enable/Disable the default Network Policy                                                                   | `false`                          |
| `gateway.service.type`                     | Type of Kubernetes service                                                                                  | `""`                             |
| `gateway.service.http.port`                | HTTP port for the service                                                                                   | `8080`                           |
| `gateway.service.ws.port`                  | WebSocket port for the service                                                                              | `9090`                           |
| `gateway.podDisruptionBudget.minAvailable` | Minimum available pods in case of disruption                                                                | `1`                              |
| `gateway.replicaCount`                     | Number of replicas                                                                                          | `1`                              |
| `gateway.revisionHistoryLimit`             | Number of revisions in history                                                                              | `1`                              |
| `gateway.resources.limits.memory`          | Maximum memory usage                                                                                        | `512Mi`                          |
| `gateway.resources.requests.cpu`           | Requested CPU performance                                                                                   | `0.5`                            |
| `gateway.resources.requests.memory`        | Requested memory usage                                                                                      | `256Mi`                          |
| `gateway.containerSecurityContext.enabled` | Enable/Disable container security context                                                                   | `false`                          |
| `gateway.uploadUrl`                        | URL for the upload service                                                                                  | `"http://localhost:8080/upload"` |
| `gateway.podAnnotations`                   | Annotations for pods                                                                                        | `{}`                             |
| `gateway.nodeSelector`                     | Node labels for pod assignment                                                                              | `{}`                             |
| `gateway.affinity`                         | Affinity settings for pods                                                                                  | `{}`                             |
| `gateway.terminationGracePeriodSeconds`    | Max time in seconds for scans to complete                                                                   | `30`                             |
| `gdscan.nodeSelector`                      | gdscan node labels for pod assignment                                                                       | `{}`                             |
| `gdscan.replicaCount`                      | Number of replicas for the gdscan deployment                                                                | `1``                             |
| `gdscan.terminationGracePeriodSeconds`     | Max time in seconds for scans to complete. Set to same value as ```gateway.terminationGracePeriodSeconds``` | `30`                             |
| `mini-identity-provider.nodeSelector`      | mini-identity-provider Node labels for pod assignment                                                       | `{}`                             |
| `mini-identity-provider.ingress.className` | Class name for Ingress                                                                                      | `""`                             |

### Production environment

In production you will have to configure a few values.

#### Ingress
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

Replace the "vaas" with your hostname in the following values:

* mini-identity-provider.issuer
* mini-identity-provider.ingress.hosts.0.host
* gateway.ingress.0.host
* gateway.ingress.1.host
* gateway.uploadUrl

If you require a different ingressClassName than "default", set:

* gateway.ingress.className
* mini-identity-provider.ingress.className

#### Zero-trust network configurations

If you are using a zero-trust network configuration, network policies have to be enabled (default). The update
CronJob requires access to the Kubernetes API. If the update fails with logs like

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
