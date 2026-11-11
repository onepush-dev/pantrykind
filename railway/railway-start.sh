#!/bin/sh
# PantryKind on Railway: derive host settings from the Railway domain, migrate, create/sync the owner, serve.
set -e
DOMAIN="${RAILWAY_PUBLIC_DOMAIN:-localhost}"
export ALLOWED_HOSTS="${ALLOWED_HOSTS:-$DOMAIN,healthcheck.railway.app,localhost,127.0.0.1}"
export CSRF_TRUSTED_ORIGINS="${CSRF_TRUSTED_ORIGINS:-https://$DOMAIN}"
cd /app
python manage.py migrate --noinput
if [ -n "$PANTRYKIND_OWNER_PASSWORD" ]; then
python manage.py shell -c "
import os
from django.contrib.auth import get_user_model
U = get_user_model(); name = os.environ.get('PANTRYKIND_OWNER_USERNAME', 'owner')
u, created = U.objects.get_or_create(username=name)
u.set_password(os.environ['PANTRYKIND_OWNER_PASSWORD']); u.save()
print('[railway] owner account', 'created' if created else 'password synced', 'for', name)
"
fi
# Opt-in inbox reminders: upstream asks for both commands every minute.
( while true; do sleep 60; python manage.py enqueue_reminders >/dev/null 2>&1; python manage.py reminder_worker --limit 100 >/dev/null 2>&1; done ) &
exec python /app/railway/serve_railway.py
