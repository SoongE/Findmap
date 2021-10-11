from flask import Blueprint, request

from utils import make_response

from search import main_method

search_api = Blueprint("search", __name__, url_prefix="/search")
SUCCESS = "success"
FAILURE = "failure"

@search_api.route('/')
def main():
    mp = main_method.Mainmethod()
    search_list = mp.main()
    resources = {"search_html" : search_list}
    return make_response(SUCCESS,resources)

@search_api.route('/name', methods=['GET'])
def name():
    name = request.args["name"]
    body = {"message" : f'FLASK SEND: Hello, {name}!'}
    return make_response(SUCCESS, body)

@search_api.route('/post', methods=['POST'])
def post():
    data =  request.get_json()
    print(f"title: {data['title']}")
    body = {"log" : "Check your flask log"}
    return make_response(SUCCESS, body)