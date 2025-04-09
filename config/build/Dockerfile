FROM oven/bun:1.2.18-alpine AS base

WORKDIR /app

COPY ./config/build/rollup.build.js ./config/build/rollup.build.js
COPY ./config/build/rollup.config.js ./config/build/rollup.config.js
COPY ./config/build/rollup.shared.js ./config/build/rollup.shared.js
COPY ./config/.env ./config/.env
COPY package.json ./
COPY tsconfig.json ./
ENV DOCKER=true

RUN bun install --production

FROM base AS app-watch
ENV ROLLUP_WATCH=true
ENV ENABLE_POLLING=true
# ENTRYPOINT ["/bin/sh", "-c", "sleep 3 && bun run watch"] 
ENTRYPOINT ["bun", "run", "watch"]

FROM base AS app-build
ENTRYPOINT ["bun", "run", "build"]

FROM base AS admin-watch
ENV ROLLUP_WATCH=true
ENV ENABLE_POLLING=true
# ENTRYPOINT ["/bin/sh", "-c", "sleep 3 && bun run watch:admin"] 
ENTRYPOINT ["bun", "run", "watch:admin"]

FROM base AS admin-build
ENTRYPOINT ["bun", "run", "build:admin"]
