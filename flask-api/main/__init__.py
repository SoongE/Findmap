import json
from flask import Blueprint, jsonify

from utils import make_response


main_api = Blueprint("main", __name__, url_prefix="/")
SUCCESS = "success"
FAILURE = "failure"

@main_api.route("/", methods=["GET"])
def main():
    body = {"answer":"FINDMAP FLASK SERVER"}
    return make_response(SUCCESS, body)


