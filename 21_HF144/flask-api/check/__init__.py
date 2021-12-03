from flask import Blueprint, request

from utils import make_response

check_api = Blueprint("check", __name__, url_prefix="/test")
SUCCESS = "success"
FAILURE = "failure"


@check_api.route('/')
def main():
    return f'!FLASK TEST PAGE!'

@check_api.route('/name', methods=['GET'])
def name():
    name = request.args["name"]
    body = {"message" : f'FLASK SEND: Hello, {name}!'}
    return make_response(SUCCESS, body)

@check_api.route('/post', methods=['POST'])
def post():
    data =  request.get_json()
    print(f"title: {data['title']}")
    body = {"log" : "Check your flask log"}
    return make_response(SUCCESS, body)