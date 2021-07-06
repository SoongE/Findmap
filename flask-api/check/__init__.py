from flask import Blueprint, request

from utils import make_response

check_api = Blueprint("check", __name__, url_prefix="/test")
SUCCESS = "success"
FAILURE = "failure"


@check_api.route('/')
def main():
    body = {"body" : f'!FLASK TEST PAGE!'}
    return f'!FLASK TEST PAGE!'

@check_api.route('/name')
def name():
    name = request.args.get("name")
    body = {"message" : f'FLASK SEND: Hello, {name}!'}
    return make_response(SUCCESS, body)