# Offline, Multistage, and Base Dockerfiles

This repository contains a collection of secure, production-ready Dockerfiles designed for:

- Fully offline / air-gapped environments
- Multistage builds for optimized image sizes
- Base images customized for internal use
- Secure access to Artifactory and other private registries

These Dockerfiles follow best practices to ensure:

- No credentials or tokens are ever baked into image layers
- Dependency sources (e.g., PyPI, OS packages) are fetched from private, authenticated repositories
- Builds remain portable between local and CI environments
