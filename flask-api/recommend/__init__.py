from flask import Blueprint, request
from pymysql import NULL

from utils import make_response
from recommend import fasttext_word
from recommend import item_filter
from recommend import numtoStr
from recommend import Recofee

import warnings
warnings.filterwarnings("ignore")

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
    print("Recommend Search Keyword")
    print(f"Input: {param_value}")
    print(f"Recommend keywords: {rec_list}")
    return make_response(SUCCESS,resources)


@recommend_api.route('/recofeed')
def recommend():
    param_value = int(request.args["useridx"])
    item_c = Recofee.Recc(param_value)
    item_f = item_c.recommend_Feed()
    #temp_str = ""
    #for item in item_f :
        #temp_str = temp_str + "," + str(item)
    resources =  {"model" : item_f }
    print(f"Recommend Feeds")
    print(f"Input: user_idx {param_value}")
    print(f"Recommend feeds idxs: {item_f}")
    return make_response(SUCCESS,resources)


@recommend_api.route('/initrecom')
def protorecom() :
    param_value = int(request.args["useridx"])
    item_c = item_filter.Item_filtered(param_value)
    item_f = item_c.make_list()
    
    numtostr_C = numtoStr.Recommend(item_f)
    i_strlist = numtostr_C.give_result()
    total_list = list()
    # print(list(i_strlist))
    for item in i_strlist :
      temp_f = fasttext_word.model(item)
      t_ftext = temp_f.give_recommend()
      
      for item in  t_ftext:
        total_list.append(item)
    temp_str = ""
    # print(total_list)
    for item in total_list :
        temp_str = temp_str + "," + item
 
    resources =  {"searchinit" : temp_str}
    return make_response(SUCCESS,resources)
      
       
