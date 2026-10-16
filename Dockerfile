FROM oven/bun:1.3.13-alpine AS builder

WORKDIR /app

# Install dependencies separately so Docker can cache this layer until the
# dependency manifest changes.
COPY package.json bun.lock bunfig.toml ./
RUN bun install --frozen-lockfile

COPY . .

# Lovable defaults to a Cloudflare build. Coolify needs Nitro's Node server.
ENV NITRO_PRESET=node-server
RUN bun run build

FROM node:24-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000

COPY --from=builder --chown=node:node /app/.output ./.output

USER node

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
