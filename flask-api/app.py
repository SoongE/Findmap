from main import runner
import fasttext

# mod = fasttext.load_model('recommend/morphnamunaver.bin')

app = runner.create_app("dev")
app.app_context().push()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)