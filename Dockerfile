# PantryKind on Railway: upstream AngelHuang5335/pantrykind (MIT) at a pinned commit, app files unmodified.
# Single container, SQLite on the /data volume. Railway volumes mount root-owned, so the container runs as root
# (upstream drops to uid 10001; here /data ownership would otherwise block writes).
FROM python:3.12-slim
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/pantrykind"
ARG PANTRYKIND_REF=aa2b5a0038f83f2984377c593f6f60af38862ecb
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 \
    BIND_HOST=0.0.0.0 PORT=8000 DEBUG=false HTTPS_ONLY=true \
    DATABASE_PATH=/data/pantry.sqlite3 \
    DJANGO_SETTINGS_MODULE=railway_settings PYTHONPATH=/app/railway \
    PANTRYKIND_OWNER_USERNAME=owner PANTRYKIND_ALLOW_SIGNUP=false
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/* \
 && git clone https://github.com/AngelHuang5335/pantrykind.git /app && git checkout "$PANTRYKIND_REF" && rm -rf .git \
 && pip install --no-cache-dir -r requirements.txt && mkdir -p /data \
 && apt-get purge -y git && apt-get autoremove -y
COPY railway /app/railway
RUN chmod +x /app/railway/railway-start.sh && DEBUG=true python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["/app/railway/railway-start.sh"]
