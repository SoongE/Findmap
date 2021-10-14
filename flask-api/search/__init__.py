from flask import Blueprint, request
from pymysql import NULL

from utils import make_response

from search import main_method

from search import model

search_api = Blueprint("search", __name__, url_prefix="/search")
SUCCESS = "success"
FAILURE = "failure"

@search_api.route('/')
def main():
    param_value = request.args["keyword"]
  
    mp = main_method.Mainmethod(param_value)
    search_list = mp.main()
    resources = {"search_html" : search_list}
    return make_response(SUCCESS,resources)

@search_api.route('/categorize')
def categorize():
    param_value = request.args["keyword"]

    search_idx_cl = model.Categorize(param_value)
    search_idx = search_idx_cl.ctg()
    body = {"ctg" : str(search_idx[0])}
    return make_response(SUCCESS, body)

@search_api.route('/share', methods=['GET'])
def share():
    param_value = request.args["url"]

    result = model.shared(param_value)
    body = {"result" : result}
    return make_response(SUCCESS, body)
