import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify(
        application="AWS-Terraform-Infra",
        status="running",
        environment=os.getenv("APP_ENV", "local"),
    )


@app.get("/health")
def health():
    return jsonify(status="healthy")