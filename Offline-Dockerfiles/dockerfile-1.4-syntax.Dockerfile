# syntax=docker/dockerfile:1.4 # Required for heredocs [3, 4]

ARG PYTHON_VERSION=3.12.3
ARG JFROG=jfrog.example.com

FROM ${JFROG}/docker/python:${PYTHON_VERSION}-slim AS base
SHELL ["/bin/bash", "-c", "-o", "pipefail", "-o", "errexit"]

ARG JFROG=jfrog.example.com

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_INDEX_URL=https://${JFROG}/artifactory/api/pypi/python/simple/

# Using DEB822 format (.sources files) - for newer systems
RUN <<EOF

CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f2)
DISTRO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)

cat > /etc/apt/sources.list.d/debian.sources <<SOURCE_FILE_CONTENT
Types: deb
URIs: https://${JFROG}/artifactory/debian/debian/
Suites: ${CODENAME} ${CODENAME}-updates
Components: main
Trusted: true

Types: deb
URIs: https://${JFROG}/artifactory/debian/debian-security/
Suites: ${CODENAME}-security
Components: main
Trusted: true
SOURCE_FILE_CONTENT
EOF

# securely copy .netrc using BuildKit secrets
RUN --mount=type=secret,id=netrc,target=/root/.netrc && \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    curl \
    && { apt-get clean || rm -rf /var/lib/apt/lists/*; }

FROM base AS build

# securely copy .netrc using BuildKit secrets
RUN --mount=type=secret,id=netrc,target=/root/.netrc && \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
    rm { apt-get clean || rm -rf /var/lib/apt/lists/*; }

WORKDIR /app

RUN python -m venv .venv
ENV PATH="/app/.venv/bin:$PATH"

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --timeout 100 --no-cache-dir --upgrade pip \
    && pip install --timeout 100 --no-cache-dir -r requirements.txt

FROM base AS runtime

WORKDIR /app

RUN addgroup --gid 1001 --system nonroot && \
    adduser --no-create-home --shell /bin/false \
    --disabled-password --uid 1001 --system --group nonroot

USER nonroot:nonroot

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

COPY --from=build --chown=nonroot:nonroot /app/.venv /app/.venv
COPY --chown=nonroot:nonroot src /app/src
COPY --chown=nonroot:nonroot main.py .

CMD ["python", "/app/main.py"]