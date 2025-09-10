# Placeholder for configuration
# SMTP, PayPal sandbox, etc. can be configured here




import os

class Config:
    # Secret key for sessions / CSRF
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-key")

    # PayPal settings
    PAYPAL_ENV = os.getenv("PAYPAL_ENV", "sandbox")  # "sandbox" or "production"
    PAYPAL_CLIENT_ID = os.getenv("PAYPAL_CLIENT_ID", "")
    PAYPAL_SECRET = os.getenv("PAYPAL_SECRET", "")

    # Email settings
    EMAIL_SMTP_SERVER = os.getenv("EMAIL_SMTP_SERVER", "localhost")
    EMAIL_PORT = int(os.getenv("EMAIL_PORT", 587))
    EMAIL_USE_TLS = os.getenv("EMAIL_USE_TLS", "True") == "True"
    EMAIL_USER = os.getenv("EMAIL_USER", "")
    EMAIL_PASS = os.getenv("EMAIL_PASS", "")

    # Database (SQLite by default)
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL", "sqlite:///site.db")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Environment label for debugging/logging
    ENV_LABEL = os.getenv("ENV_LABEL", "staging")  # can be "staging" or "production"
