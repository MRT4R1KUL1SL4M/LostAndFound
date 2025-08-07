import os
import certifi

# Secret key for session management.
SECRET_KEY = 'a8f5b1e7c9d3b2a4f6e8c1d0b9a7f5e3d2c4b1a0f9e8d7c6b5a4f3e2d1c0b9a8'

# =================================================================
# SQLAlchemy Database Configuration
# =================================================================
DB_USER = '3uDzzHcjcrUDZro.root'
DB_PASSWORD = 'AUJp1phBUSfXgb0J'
DB_HOST = 'gateway01.ap-southeast-1.prod.aws.tidbcloud.com'
DB_PORT = 4000
DB_NAME = 'test'

# --- Universal SSL Configuration ---
ssl_ca_path = certifi.where()

# Full connection string with SSL arguments
SQLALCHEMY_DATABASE_URI = (
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    f"?ssl_ca={ssl_ca_path}"
)

SQLALCHEMY_POOL_RECYCLE = 280
SQLALCHEMY_TRACK_MODIFICATIONS = False


# =================================================================
# Mail Configuration
# =================================================================
MAIL_SERVER = 'smtp.gmail.com'
MAIL_PORT = 587
MAIL_USE_TLS = True
MAIL_USERNAME = 'mrtarikulislamtarekgcolab@gmail.com'
MAIL_PASSWORD = 'rjkm wgqw qgpj nggc'
MAIL_DEFAULT_SENDER = ('CampusFind', 'mrtarikulislamtarekgcolab@gmail.com')
