ARG PYTHON_VERSION=3.12.3
ARG JFROG=jfrog.example.com
FROM ${JFROG}/docker/python:${PYTHON_VERSION}-slim

ARG JFROG

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_INDEX_URL=https://${JFROG}/artifactory/api/pypi/python/simple/

RUN sed -i -e "s,http:\/\/deb.debian.org,https:\/\/${JFROG}/artifactory/debian,g" /etc/apt/sources.list.d/debian.sources \
    && sed -i -e "s,^Signed-By:.*,Trusted: yes,g" /etc/apt/sources.list.d/debian.sources \
    && echo 'Acquire::https::Verify-Peer "false";' > /etc/apt/apt.conf.d/trusted-apt.conf \
    && apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
      build-essential \
    && apt-get clean \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/*
