import os

from flask import Flask, request, jsonify
from flask_pymongo import PyMongo

MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongodb:27017/requests")

app = Flask(__name__)
app.config["MONGO_URI"] = MONGO_URI

mongo = PyMongo(app)

DEFAULT_METHODS = ["GET", "POST"]


@app.route("/echo", methods=DEFAULT_METHODS)
def echo():
    args = request.args
    body = request.get_json()
    mongo.db.requests.insert_one({"args": args, "body": body})
    return jsonify(dict(ok=True, args=args, body=body))


if __name__ == "__main__":
    app.run(port=os.getenv("PORT", 5000), debug=os.getenv("DEBUG", "0") == "1")
