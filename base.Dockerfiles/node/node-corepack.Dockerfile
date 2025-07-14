ARG NODE_VERSION=20
ARG JFROG=jfrog.example.com

FROM ${JFROG}/docker/node:${NODE_VERSION}-alpine AS base

ARG JFROG
ENV PATH="$PATH:/pnpm"

RUN sed -i "s,dl-cdn.alpinelinux.org/alpine,${JFROG}/artifactory/alpine,g" /etc/apk/repositories &&\
    apk --no-cache add curl git \
    && npm install -g corepack \
    && corepack enable \
    && corepack prepare pnpm@latest --activate \
    && echo registry=https://${JFROG}/artifactory/api/npm/npm/ > ~/.npmrc


# .npmrc

# always-auth = false # if a registry has no authentication
# registry=https://${JFROG}/artifactory/api/npm/npm/
