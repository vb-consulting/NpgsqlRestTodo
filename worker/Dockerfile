FROM oven/bun:1.2.20-alpine
WORKDIR /app
COPY /worker/package*.json ./
RUN bun install
COPY /worker/*.js ./
COPY /worker/queue_modules/*.js ./queue_modules/
CMD ["bun", "run", "index.js"]