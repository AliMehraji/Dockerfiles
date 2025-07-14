# Offline Python Dockerfile Build

Build Docker images in a fully offline environment using Docker BuildKit and Artifactory authentication via `.netrc` secrets.

Artifactory user and token must have read access to all required repositories, including:

- Python (e.g., PyPI proxy)
- Debian or Ubuntu base images

Secure Build with Docker BuildKit Instead of exposing credentials via ARG or ENV (which is insecure), use BuildKit secrets:

Enable BuildKit (if not already)

```bash
export DOCKER_BUILDKIT=1
```

Local Build Example

```bash
docker build --secret id=netrc,src=artifactory_credentials -f /path/to/Dockerfile -t image-name:version .
```

Where `artifactory_credentials` is a `.netrc`-formatted file

```conf
machine artifactory.mycompany.com
login my-username
password my-token
```

> Never write credentials directly in Dockerfile or shell commands or in repository.

## GitLab CI/CD Integration

Define a [file-type CI variable][file type var] in `.gitlab-ci.yml` (e.g., `ARTIFACTORY_NETRC`) that holds the `.netrc` content.

> GitLab CI uses [BuildKit][gitlab-ci-buildkit] by default, and `docker build` is an alias to `docker buildx build`.

Then use it in the build step:

```yaml
build:
  stage: build
  image: docker:latest
  variables:
    DOCKER_BUILDKIT: 1
  services:
    - docker:dind
  script:
    - docker build --secret id=netrc,src=${ARTIFACTORY_NETRC} -f /path/to/Dockerfile -t image-name:version .
```

## Read More

- [Offline, Multistage Python Dockerfile][OMPD]

[file type var]: https://about.gitlab.com/blog/impact-of-the-file-type-variable-change-15-7/
[gitlab-ci-buildkit]: https://docs.gitlab.com/ci/docker/using_buildkit/
[OMPD]: https://dev.to/alimehr75/offline-multistage-python-dockerfile-n2j
