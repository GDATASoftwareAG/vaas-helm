# VaaS Docker Compose Setup Guide

This guide explains how to set up and run the VaaS (Verdict as a Service) system using Docker Compose.

## Prerequisites

- Docker and Docker Compose installed on your system
- Access to the required Docker images in the GitHub Container Registry (ghcr.io)

## Setup Process

### 1. Generate Secret Values

Before running the services, you must execute the `generate_secrets.sh` script to create necessary certificates and passwords:

```bash
# Navigate to the docker directory
cd docker

# Make the script executable if needed
chmod +x generate_secrets.sh

# Run the script
./generate_secrets.sh
```

This script will:
- Generate encryption and signing certificates for the mini-identity-provider
- Create a random secure password for the VaaS client SDKs
- Populate all `<<placeholder>>` values in the secret files

### 2. Locate the VaaS Client Secret

After running the script, the VaaS client secret (`CLIENTS__0__SECRET`) will be generated in the `mini-oidc.secrets.env` file.

You can view this secret with:

```bash
grep "CLIENTS__0__SECRET" docker/mini-oidc.secrets.env
```

### 3. Start the Services

Once secrets are generated, start all services with:

```bash
docker compose up -d
```

### 4. Test with an SDK
To test the setup, you can use a [VaaS client SDKs](https://github.com/GDATASoftwareAG/vaas). 
Use the following values:
- CLIENT_ID = vaas
- CLIENT_SECRET = 'the secret you found in step 2'
- TOKEN_URL = http://localhost:8082/protocol/openid-connect/token

For WebSocket connections:
- VAAS_URL = ws://localhost:9090 (ensure the sdk trusts self-signed certificates)

For HTTP connections:
- VAAS_URL = http://localhost:8080

## Health Monitoring

All services include health checks that will automatically restart containers on failure. You can monitor service health with:

```bash
docker compose ps
docker compose stats
```

To view service logs:

```bash
docker compose logs -f [service_name]
```