# PantryKind — self-hosted kitchen and pantry companion. Deploy on Railway with one click.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template/TBD)

[PantryKind](https://github.com/AngelHuang5335/pantrykind) (MIT) tracks what is in your fridge and pantry, expiry
dates, recipes you can cook with what you have, a meal planner, shopping lists and shared households.

Image: `ghcr.io/onepush-dev/pantrykind:aa2b5a0` (upstream commit `aa2b5a0`, app files unmodified, plus a Railway
settings overlay and start script in `railway/`).

## What the template sets up
- One service `pantrykind` (Waitress on port 8000, health check `/healthz/`), SQLite on a volume at `/data`
- `SECRET_KEY` generated per deploy; `ALLOWED_HOSTS` / `CSRF_TRUSTED_ORIGINS` derived from the Railway domain
- Owner account created on boot: username `owner`, password = generated `PANTRYKIND_OWNER_PASSWORD`
  (service Variables tab). Sign in, then name your kitchen.
- Public sign-up is closed (upstream asks you to protect registration). Set `PANTRYKIND_ALLOW_SIGNUP=true`
  temporarily to let household members create accounts.
- Opt-in inbox reminders run every minute inside the container.

PostgreSQL is optional upstream; this template uses the default SQLite file for a single small household.
