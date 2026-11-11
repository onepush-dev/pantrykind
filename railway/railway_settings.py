# Railway overlay on top of upstream config.settings (upstream files unmodified).
# - Railway's edge terminates TLS and sets X-Forwarded-Proto, so trust it for request.is_secure().
# - Public sign-up is closed unless PANTRYKIND_ALLOW_SIGNUP=true (upstream asks you to protect registration
#   at the proxy); the owner account is created on boot by railway-start.sh.
import os
from config.settings import *  # noqa: F401,F403
from config.settings import MIDDLEWARE

SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
MIDDLEWARE = list(MIDDLEWARE) + ["railway_settings.SignupGateMiddleware"]


class SignupGateMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.allow = os.environ.get("PANTRYKIND_ALLOW_SIGNUP", "false").lower() == "true"

    def __call__(self, request):
        if not self.allow and request.path.rstrip("/") == "/accounts/signup":
            from django.http import HttpResponseForbidden
            return HttpResponseForbidden(
                "Sign-up is disabled on this instance. Ask the owner to set PANTRYKIND_ALLOW_SIGNUP=true."
            )
        return self.get_response(request)
