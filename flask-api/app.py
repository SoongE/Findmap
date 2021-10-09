from main.runner import creating

app = creating.create_app("dev")
app.app_context().push()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)