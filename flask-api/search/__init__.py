from flask import Blueprint, request

from utils import make_response

from search import main_method

from search import model

search_api = Blueprint("search", __name__, url_prefix="/search")
SUCCESS = "success"
FAILURE = "failure"

@search_api.route('/')
def main():
    mp = main_method.Mainmethod()
    search_list = mp.main()
    resources = {"search_html" : search_list}
    return make_response(SUCCESS,resources)

@search_api.route('/categorize',)
def categorize():
    search_idx_cl = model.Categorize("아이언맨")
    search_idx = search_idx_cl.ctg()
    body = {"ctg" : search_idx}
    return make_response(SUCCESS, body)

