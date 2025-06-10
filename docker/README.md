# VaaS Docker Compose Setup Guide

This guide explains how to set up and run the VaaS (Verdict as a Service) system with only GdScan using Docker Compose.

## Prerequisites

- Docker and Docker Compose installed on your system
- Access to the required Docker images in the GitHub Container Registry (ghcr.io)

## Setup Process

### 1. Start the Services

Start docker compose with:

```bash
docker compose up -d
```

### 2. Run example

We provice a python example to test the setup with any files.
Before that, you have to install all requirements:

```bash
pip install -r requirements.txt
```

After that, change the path to the file, that should be analyzed.
You can run the example with:

```bash
python example.py
```

This is the response for an EICAR file:

```json
{
  "verdict": "Malicious",
  "detections": [
    {
      "engine": "Ikarus",
      "fileName": "/tmp/scan/e6952481-04e6-4346-8ce8-7e6ce5185e1f",
      "virus": "EICAR-Test-File#462103"
    },
    {
      "engine": "GData",
      "fileName": "/tmp/scan/e6952481-04e6-4346-8ce8-7e6ce5185e1f",
      "virus": "EICAR_TEST_FILE"
    }
  ],
  "isPup": false,
  "libMagic": {
    "fileType": "EICAR virus test files",
    "mimeType": "text/plain"
  }
}
```

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