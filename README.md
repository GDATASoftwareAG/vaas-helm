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

TODO

| Name                               | Description                                                                                                           | Value                    |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `service.type`                     | service type                                                                                                          | `ClusterIP`              |
