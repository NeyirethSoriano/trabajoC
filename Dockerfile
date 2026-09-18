# ---- Fase 1: Contenerización segura ----
FROM node:20-alpine

LABEL maintainer="aprendiz-adso"
LABEL description="API Node.js endurecida para plan de mejoramiento"

ENV NODE_ENV=production
ENV PORT=8080

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci --omit=dev && npm cache clean --force

COPY --chown=node:node . .

RUN apk update && apk upgrade --no-cache \
    && rm -rf /usr/local/lib/node_modules/npm \
              /usr/local/lib/node_modules/corepack \
              /usr/local/bin/npm \
              /usr/local/bin/npx \
              /usr/local/bin/corepack \
              /opt/yarn-v1.22.22

USER node

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/ || exit 1

CMD ["node", "index.js"]
