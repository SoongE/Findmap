class Config:
    DEBUG = True


class DevelopmentConfig(Config):
    # uncomment the line below to use postgres
    # SQLALCHEMY_DATABASE_URI = postgres_local_base
    DEBUG = True


class TestingConfig(Config):
    DEBUG = True
    TESTING = True
    PRESERVE_CONTEXT_ON_EXCEPTION = False


class ProductionConfig(Config):
    DEBUG = False


config_by_name = dict(dev=DevelopmentConfig, test=TestingConfig, prod=ProductionConfig)