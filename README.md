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

```
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

* Extract Client secret with this command

```
export CLIENT_SECRET=$(kubectl get secret -n vaas vaas-client-secret -o jsonpath="{.data.secret}" | base64 -d)
```

* Set these environment variables for testing your local instance

```
export CLIENT_ID=vaas
export SCAN_PATH=<filepath-to-scan>
export VAAS_URL=ws://vaas/ws
export TOKEN_URL=http://vaas/auth/protocol/openid-connect/token
```

* Execute FileScan example in Java SDK example folder

```
./gradlew fileScan
```

## Configuring Verdict-as-a-Service

| Parameter | Description | Value |
|-------------|-------------|-------|
| `ingress.enabled` | Enable/Disable the Ingress resource | `false` |
| `ingress.annotations` | Additional annotations for Ingress | `{}` |
| `ingress.hosts` | Hostnames and paths for Ingress | `[]` |
| `ingress.tls` | TLS configuration for Ingress | `[]` |
| `authentication.authority` | Authority for authentication | `""` |
| `nameOverride` | Overrides the application name | `""` |
| `fullnameOverride` | Overrides the full name | `""` |
| `networkPolicy.enabled` | Enable/Disable the default Network Policy | `false` |
| `secret.dockerconfigjson` | Docker authentication configuration | `""` |
| `service.type` | Type of Kubernetes service | `""` |
| `service.http.port` | HTTP port for the service | `8080` |
| `service.ws.port` | WebSocket port for the service | `9090` |
| `podDisruptionBudget.minAvailable` | Minimum available pods in case of disruption | `1` |
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Number of revisions in history | `1` |
| `resources.limits.memory` | Maximum memory usage | `512Mi` |
| `resources.requests.cpu` | Requested CPU performance | `0.5` |
| `resources.requests.memory` | Requested memory usage | `256Mi` |
| `containerSecurityContext.enabled` | Enable/Disable container security context | `false` |
| `cloudhashlookup.enabled` | Enable/Disable cloud hash lookup | `false` |
| `uploadUrl` | URL for the upload service | `"http://localhost:8080/upload"` |
| `imagePullSecrets` | List of image pull secrets | `- name: registry` |
| `podAnnotations` | Annotations for pods | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `gdscan.nodeSelector` | gdscan Node labels for pod assignment | `{}` |
| `mini-identity-provider.nodeSelector` | mini-identity-provider Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for pods | `[]` |
| `affinity` | Affinity settings for pods | `{}` |
| `gateway.terminationGracePeriodSeconds` | Max time in seconds for scans to complete | `30` |
| `gdscan.terminationGracePeriodSeconds` | Max time in seconds for scans to complete. Set to same value as ```gateway.terminationGracePeriodSeconds``` | `30` |

### Production environment

In production you will have to configure a few values.

#### Ingress
The default hostname is "vaas". To change it and provide a tls configuration, add this to your values.yaml:

```yaml
mini-identity-provider:
  issuer: "http://vaas/auth"
  ingress:
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
