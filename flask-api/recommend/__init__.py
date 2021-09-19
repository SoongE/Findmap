from flask import Blueprint, request

from utils import make_response
from recommend import fasttext_word


recommend_api = Blueprint("recommend", __name__, url_prefix="/recommend")
SUCCESS = "success"
FAILURE = "failure"

@recommend_api.route('/')
def main():
    ft = fasttext_word.model
    resources = ft.give_recommend
    return make_response(SUCCESS,resources)

