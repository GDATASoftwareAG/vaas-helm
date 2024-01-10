# Verdict-as-a-Service Helm Chart

Vaas helm is a chart for deploying Verdict-as-a-Service on-premise.

## Install Verdict-as-a-Service

1. Create a minimal values.yaml file:

The token has to be set in the `secret.dockerconfigjson` variable on deployment.

```yaml
# values.yaml
secret: 
    dockerconfigjson: $$_BASE64_ENCODED_JSON_CONTAINING_TOKEN_$$
```

Example of the dockerconfigjson

```json
{
    "auths": {
            "ghcr.io": {
                    "auth": "$$_BASE64_ENCODED_USERNAME_AND_TOKEN_$$"
            }
    }
}
```

2. Add the helm repository:

```bash
helm repo add vaas https://gdatasoftwareag.github.io/vaas/
```

3. Install Verdict-as-a-Service:

```bash
helm install vaas gdatasoftware/vaas -f values.yaml
```

TODO: 

### Updating Verdict-as-a-Service

```bash
helm repo update
helm upgrade gdscan  gdscan/gdscan -f values.yaml
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
| `networkPolicy.enabled` | Enable/Disable the Network Policy | `false` |
| `secret.dockerconfigjson` | Docker authentication configuration | `""` |
| `service.type` | Type of Kubernetes service | `""` |
| `service.http.port` | HTTP port for the service | `8080` |
| `service.ws.port` | WebSocket port for the service | `9090` |
| `metrics.enabled` | Enable/Disable metrics | `false` |
| `metrics.port` | Port for metrics | `8080` |
| `metrics.path` | Path for metrics | `/metrics` |
| `autoscaling.enabled` | Enable/Disable automatic scaling | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `2` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `20` |
| `autoscaling.targetCPU` | Target CPU usage for automatic scaling | `75` |
| `autoscaling.metrics` | Metrics for automatic scaling | |
| `podDisruptionBudget.minAvailable` | Minimum available pods in case of disruption | `1` |
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Number of revisions in history | `1` |
| `resources.limits.memory` | Maximum memory usage | `512Mi` |
| `resources.requests.cpu` | Requested CPU performance | `0.5` |
| `resources.requests.memory` | Requested memory usage | `256Mi` |
| `containerSecurityContext.enabled` | Enable/Disable container security context | `false` |
| `image.repository` | Docker image repository | `ghcr.io/gdatasoftwareag/vaas/gateway` |
| `image.pullPolicy` | Docker image pull policy | `Always` |
| `image.tag` | Docker image tag | `1` |
| `cloudhashlookup.enabled` | Enable/Disable cloud hash lookup | `false` |
| `hashlookup.enabled` | Enable/Disable local hash lookup | `false` |
| `hashlookup.apikey.value` | API key for local hash lookup | `""` |
| `usageevents.enabled` | Enable/Disable usage events | `false` |
| `gdscanUrl` | URL for the GDScan service | `"http://gdscan:8080/scan/body"` |
| `uploadUrl` | URL for the upload service | `"http://localhost:8080/upload"` |
| `options.url` | URL for options | `"wss://gateway.production.vaas.gdatasecurity.de"` |
| `options.tokenurl` | Token URL for options | `"https://account.gdata.de/realms/vaas-production/protocol/openid-connect/token"` |
| `options.credentials.granttype` | Grant type for options | `"ClientCredentials"` |
| `options.credentials.clientid` | Client ID for options | `""` |
| `options.credentials.clientsecret.value` | Client secret for options | `""` |
| `imagePullSecrets` | List of image pull secrets | `- name: registry` |
| `podAnnotations` | Annotations for pods | `{}` |
| `nodeSelector` | Node selector for pods | `{}` |
| `tolerations` | Tolerations for pods | `[]` |
| `affinity` | Affinity settings for pods | `{}` |



## TODO

### Getting started

To install a development environment:

* Minikube
* helm add repo
* helm login
* Create values.yaml with

imagePullSecrets: ONLY 1

* helm install
* NOTES.txt include script lines to get URLs and credentials link to SDKs
  * NodeIP

### Production environment

In production you will have to configure stuff.

#### Ingress

ingress:
  enable: true (affects gateway, midp)
  host:
    vaas.local
      auth
      upload
      verdicts
      ws

#### Scale workers

#### Deny worker intra cluster access (no forUrl)

#### NodeSelectors

####