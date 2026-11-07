import os
from pathlib import Path

from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

env_file = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(env_file, override=False)

db = SQLAlchemy()


class Message(db.Model):
    __tablename__ = "messages"

    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.String(500), nullable=False)
    created_at = db.Column(
        db.DateTime,
        server_default=db.func.now(),
        nullable=False,
    )


def create_app(test_config=None):
    app = Flask(__name__)

    app.config.update(
        SQLALCHEMY_DATABASE_URI=os.getenv("DATABASE_URL"),
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
    )

    # La configuration de test peut remplacer celle par défaut.
    if test_config is not None:
        app.config.update(test_config)

    if not app.config.get("SQLALCHEMY_DATABASE_URI"):
        raise RuntimeError(
            "DATABASE_URL must be configured before starting the application."
        )

    db.init_app(app)

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

    @app.get("/health/db")
    def database_health():
        try:
            db.session.execute(text("SELECT 1"))
            return jsonify(status="healthy", database="connected"), 200
        except Exception:
            db.session.rollback()
            return jsonify(
                status="unhealthy",
                database="disconnected",
            ), 503

    @app.post("/messages")
    def create_message():
        data = request.get_json(silent=True)

        if not isinstance(data, dict):
            return jsonify(error="A JSON object is required"), 400

        content = data.get("content")

        if not isinstance(content, str) or not content.strip():
            return jsonify(error="Content is required"), 400

        if len(content) > 500:
            return jsonify(error="Content must not exceed 500 characters"), 400

        message = Message(content=content.strip())

        db.session.add(message)
        db.session.commit()

        return jsonify(
            id=message.id,
            content=message.content,
            created_at=message.created_at.isoformat(),
        ), 201

    @app.get("/messages")
    def get_messages():
        messages = db.session.execute(
            db.select(Message).order_by(Message.created_at.desc())
        ).scalars().all()

        return jsonify(
            messages=[
                {
                    "id": message.id,
                    "content": message.content,
                    "created_at": message.created_at.isoformat(),
                }
                for message in messages
            ]
        )

    return app
