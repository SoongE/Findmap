from main.runner import create_app

app = create_app("dev")
app.app_context().push()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)