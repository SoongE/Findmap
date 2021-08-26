from flask import Blueprint, request

from utils import make_response

from main import main as mp

recommend_api = Blueprint("check", __name__, url_prefix="/recommend")
SUCCESS = "success"
FAILURE = "failure"


@recommend_api.route('/')
def main():
    resources =  mp()
    return make_response(SUCCESS,resources)

@recommend_api.route('/name', methods=['GET'])
def name():
    name = request.args["name"]
    body = {"message" : f'FLASK SEND: Hello, {name}!'}
    return make_response(SUCCESS, body)

@recommend_api.route('/post', methods=['POST'])
def post():
    data =  request.get_json()
    print(f"title: {data['title']}")
    body = {"log" : "Check your flask log"}
    return make_response(SUCCESS, body)