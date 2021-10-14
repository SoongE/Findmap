from flask import Blueprint, request
from pymysql import NULL

from utils import make_response
from recommend import fasttext_word
from recommend import item_filter
from recommend import numtoStr

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
    item_f = item_c.make_list()
    
    temp numtostr_C = numtoStr.Recommend(item_f)
    i_strlist = numtostr_C.give_result()
    total_list = list()

    for item in i_strlist :
      temp_f = fasttext_word.model(item)
      for item in temp_f.give_recommend() :
        total_list.append(item)
    temp_str = ""

    for item in total_list :
        temp_str = temp_str + "," + item
    temp_str = item_f
    print(temp_str)
    resources =  {"searchinit" : temp_str}
    return make_response(SUCCESS,resources)
      
       