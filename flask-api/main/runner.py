import os

# external package
from flask import Flask
from flask import Flask, url_for, redirect, render_template, request, abort

from main.config import config_by_name
from main.api_url import api_urls


def create_app(config_name):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_object(config_by_name[config_name])

    # apply url
    for url in api_urls:
        app.register_blueprint(url)

    return app