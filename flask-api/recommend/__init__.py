from flask import Blueprint, request
from pymysql import NULL

from utils import make_response
from recommend import fasttext_word
from recommend import item_filter
from search import model

recommend_api = Blueprint("recommend", __name__, url_prefix="/recommend")
SUCCESS = "success"
FAILURE = "failure"

@recommend_api.route('/')
def main():
    param_value = request.args["keyword"]
    ft = fasttext_word.model(param_value)    
    rec_list = ft.give_recommend()
    temp_str = ""
    for item in rec_list :
        temp_str = temp_str + "," + item
    resources = {"model" : temp_str}
    return make_response(SUCCESS,resources)


@recommend_api.route('/recofeed')
def recommend():
    param_value = int(request.args["useridx"])
    item_c = item_filter.Item_filtered(param_value)
    item_f = item_c.make_list()
    temp_str = ""
    for item in item_f :
        temp_str = temp_str + "," + str(item)
    resources =  {"model" : temp_str }
    return make_response(SUCCESS,resources)


@recommend_api.route('/initrecom')
def protorecom() :
    param_value = int(request.args["useridx"])
    item_c = item_filter.Item_filtered(param_value)
    
    temp_str = ""

    item_f = item_c.make_list()
    
    for item in item_f :
       