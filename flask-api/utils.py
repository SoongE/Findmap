import json

def make_response(status,body):
    res = json.dumps({"status":status, "body":body})
    return res