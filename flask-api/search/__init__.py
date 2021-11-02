from flask import Blueprint, request
from pymysql import NULL
import fasttext

from utils import make_response
from search import main_method, model, crawler

import warnings
warnings.filterwarnings("ignore")
fasttext.FastText.eprint = lambda x: None

search_api = Blueprint("search", __name__, url_prefix="/search")
SUCCESS = "success"
FAILURE = "failure"

crw = crawler.Crawler()
pororo = model.PororoModel()
fasttext_model = fasttext.load_model('/root/search/0826101710_model.bin')

@search_api.route('/')
def main():
    keyword = request.args["keyword"]
    userIdx = request.args["userIdx"]
  
    mp = main_method.Mainmethod(keyword, userIdx, fasttext_model)
    search_list = mp.main()

    for search in search_list:
        search['contentUrl'] = search.pop('link')
        search['summary'] = search.pop('description')

    resources = {"search_html" : search_list}
    print("Search Result")
    print(f"Input: {keyword}")
    print(f"Sorted result: {search_list}")
    return make_response(SUCCESS,resources)

@search_api.route('/categorize')
def categorize():
    keyword = request.args["keyword"]
     
    search_idx_cl = model.Categorization(fasttext_model)
    param_value = search_idx_cl.get_category_of_keyword(keyword)
    
    body = {"ctg" : param_value}
    return make_response(SUCCESS, body)

@search_api.route('/share', methods=['GET'])
def share():
    param_value = request.args["url"]
    body = main_method.share(param_value, crw, pororo)

    if body == 0:
        return make_response(FAILURE, body)
    return make_response(SUCCESS, body)
