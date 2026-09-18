# 4. Copiamos el resto del código ya con dueño 'node' (no root)
COPY --chown=node:node . .

# 5. HARDENING:
#    a) Parchear CVEs del sistema operativo base (libssl3/libcrypto3, etc.)
#    b) Eliminar npm/npx/corepack de la imagen final: la app arranca con
#       "node index.js", nunca con npm, y npm trae sus propias dependencias
#       (tar, glob, minimatch, pacote...) que generan falsos positivos en Trivy
RUN apk update && apk upgrade --no-cache \
    && rm -rf /usr/local/lib/node_modules/npm \
              /usr/local/lib/node_modules/corepack \
              /usr/local/bin/npm \
              /usr/local/bin/npx \
              /usr/local/bin/corepack \
              /opt/yarn-v1.22.22

# 6. Usuario sin privilegios (el usuario 'node' ya existe en la imagen oficial)
USER node
