from flask import Blueprint, request

from utils import make_response

from search import main_method

from search import model

search_api = Blueprint("search", __name__, url_prefix="/search")
SUCCESS = "success"
FAILURE = "failure"

@search_api.route('/')
def main():
    param_dict = request.args.to_dict()
    param_value = NULL

    for key in param_dict.keys() :
      param_value = request.args[key]#### 검색어 param

    mp = main_method.Mainmethod(param_value)
    search_list = mp.main()
    resources = {"search_html" : search_list}
    return make_response(SUCCESS,resources)

@search_api.route('/categorize',)
def categorize():
    param_dict = request.args.to_dict()
    param_value = NULL

    for key in param_dict.keys() :
      param_value = request.args[key]#### 검색어 param

    search_idx_cl = model.Categorize(param_value)
    search_idx = search_idx_cl.ctg()
    body = {"ctg" : search_idx}
    return make_response(SUCCESS, body)

