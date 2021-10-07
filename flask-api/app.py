from main.runner import create_app
import fasttext

app = create_app("dev")
app.app_context().push()
model = fasttext.load_model('./morphnamunaver.bin')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)