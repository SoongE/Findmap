from flask import Blueprint, request

from utils import make_response
from recommend import fasttext_word
from recommend import item_filter


recommend_api = Blueprint("recommend", __name__, url_prefix="/recommend")
SUCCESS = "success"
FAILURE = "failure"

@recommend_api.route('/',methods=["GET"])
def main():
    ft = fasttext_word.model
    resources = {"model" : "hi"}
    return make_response(SUCCESS,resources)


@recommend_api.route('/recofeed',methods=["GET"])
def recommend():
    item_f = item_filter.Item_filtered()
    resources =  {"model" : item_f }
    return make_response(SUCCESS,resources)
