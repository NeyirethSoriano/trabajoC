# ---- Fase 1: Contenerización segura ----
# Imagen base ligera (Alpine ~5x más pequeña que la imagen estándar de Node)
FROM node:20-alpine

# Metadatos
LABEL maintainer="aprendiz-adso"
LABEL description="API Node.js endurecida para plan de mejoramiento"

# Variables de entorno de producción
ENV NODE_ENV=production
ENV PORT=8080

# 1. Directorio de trabajo
WORKDIR /usr/src/app

# 2. Copiamos SOLO los manifiestos primero (aprovecha la caché de capas:
#    si el código cambia pero las dependencias no, no se reinstala nada)
COPY --chown=node:node package*.json ./

# 3. Instalación limpia y solo de dependencias de producción.
#    npm ci exige package-lock.json  -> genera y commitea el lock con: npm install
RUN npm ci --omit=dev && npm cache clean --force

# 4. Copiamos el resto del código ya con dueño 'node' (no root)
COPY --chown=node:node . .

# 5. HARDENING: usuario sin privilegios (el usuario 'node' ya existe en la imagen oficial)
USER node

# 6. Puerto documentado
EXPOSE 8080

# Chequeo de salud interno del contenedor
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/ || exit 1

# 7. Arranque directo con node (NO uses "npm start": npm no propaga
#    correctamente las señales SIGTERM/SIGINT al proceso hijo)
CMD ["node", "index.js"]
