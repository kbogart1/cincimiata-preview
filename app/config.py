# Placeholder for configuration
# SMTP, PayPal sandbox, etc. can be configured here
import os

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-key")
    PAYPAL_ENV = os.getenv("PAYPAL_ENV", "sandbox")
    PAYPAL_CLIENT_ID = os.getenv("PAYPAL_CLIENT_ID", "")
    PAYPAL_SECRET = os.getenv("PAYPAL_SECRET", "")
    EMAIL_SMTP_SERVER = os.getenv("EMAIL_SMTP_SERVER", "localhost")
    EMAIL_USER = os.getenv("EMAIL_USER", "")
    EMAIL_PASS = os.getenv("EMAIL_PASS", "")
