from flask import Blueprint, request

from utils import make_response
from recommend import fasttext_word
from recommend import item_filter


recommend_api = Blueprint("recommend", __name__, url_prefix="/recommend")
SUCCESS = "success"
FAILURE = "failure"

@recommend_api.route('/')
def main():
    ft = fasttext_word.model
    resources = ft.give_recommend
    return make_response(SUCCESS,resources)


@recommend_api.route('/recofeed')
def main():
    item_f = item_filter.Item_filtered()
    resources = item_f
    return make_response(SUCCESS,resources)
