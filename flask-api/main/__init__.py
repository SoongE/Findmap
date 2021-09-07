import json
from flask import Blueprint, jsonify

from check import check_api
from Search import search_api
from recommend import recommend_api

from utils import make_response


main_api = Blueprint("main", __name__, url_prefix="/")
SUCCESS = "success"
FAILURE = "failure"

@main_api.route("/", methods=["GET"])
def main():
    body = {"answer":"FINDMAP FLASK SERVER"}
    return make_response(SUCCESS, body)

api_urls = [
    main_api,
    check_api,
    search_api,
    recommend_api
]