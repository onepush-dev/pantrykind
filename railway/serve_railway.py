# Same as upstream serve.py, but trusts Railway's edge for X-Forwarded-Proto (Waitress strips it by default),
# so Django sees HTTPS requests as secure and HTTPS_ONLY does not redirect-loop.
import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "railway_settings")
from config.wsgi import application
from waitress import serve

if __name__ == "__main__":
    serve(
        application,
        host=os.environ.get("BIND_HOST", "0.0.0.0"),
        port=int(os.environ.get("PORT", "8000")),
        threads=int(os.environ.get("THREADS", "4")),
        max_request_body_size=2 * 1024 * 1024,
        trusted_proxy="*",
        trusted_proxy_headers={"x-forwarded-proto"},
        clear_untrusted_proxy_headers=True,
    )
