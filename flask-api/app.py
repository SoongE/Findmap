from flask import Flask, escape, request

app = Flask(__name__)

@app.route('/')
def index():
    return 'Flask Server'

@app.route('/whoyouare')
def whoyouare():
    name = request.args.get("name")

    return {"message" : f'FLASK SEND: Hello, {name}!'}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)