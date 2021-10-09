from flask import Blueprint, request

from utils import make_response
from recommend import fasttext_word
from recommend import item_filter


recommend_api = Blueprint("recommend", __name__, url_prefix="/recommend")
SUCCESS = "success"
FAILURE = "failure"

@recommend_api.route('/')
def main():
    ft = fasttext_word.model()    
    rec_list = ft.give_recommend()
    temp_str = ""
    for item in rec_list :
        temp_str = temp_str + "," + item
    resources = {"model" : temp_str}
    return make_response(SUCCESS,resources)


@recommend_api.route('/recofeed')
def recommend():
    item_c = item_filter.Item_filtered
    item_f = item_c.give_list()
    temp_str = ""
    for item in item_f :
        temp_str = temp_str + "," + item
    resources =  {"model" : temp_str }
    return make_response(SUCCESS,resources)
