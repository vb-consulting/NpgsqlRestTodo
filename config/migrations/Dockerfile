FROM oven/bun:1.2.8-alpine

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    apk update && \
    apk add --no-cache postgresql17-client

WORKDIR /app

RUN bun install -g @vbilopav/pgmigrations@0.43.0
COPY ./config/migrations/pgmigrations.js ./
COPY ./config/.env ./config/.env
COPY ./src/backend ./src/backend