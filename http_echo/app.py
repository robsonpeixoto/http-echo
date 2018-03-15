import os

from flask import Flask, jsonify, request, json
from flask_pymongo import PyMongo

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/http_echo")

DEFAULT_METHODS = ["GET", "POST"]

app = Flask(__name__)
app.config["MONGO_URI"] = MONGO_URI
mongo = PyMongo(app)


@app.route("/echo", methods=DEFAULT_METHODS)
def echo():
    data = dict(
        path=request.path,
        method=request.method,
        headers=list(request.headers.items()),
        form=list(request.form.items()),
        args=list(request.args.items()),
        remote=dict(
            address=request.environ['REMOTE_ADDR'],
            port=request.environ['REMOTE_PORT'],
        ),
        content_type=request.content_type,
        files=[(f[0], f[1].filename) for f in request.files.items()],
        json=request.json,
    )

    mongo.db.requests.insert(data)
    return jsonify(data)


if __name__ == "__main__":
    app.run(port=os.getenv("PORT", 5000), debug=os.getenv("DEBUG", "0") == "1")
