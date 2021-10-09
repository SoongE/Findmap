from main.runner import create_app
import fasttext

mod = fasttext.load_model('.recommend/morphnamunaver.bin')

app = create_app("dev")
app.app_context().push()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)