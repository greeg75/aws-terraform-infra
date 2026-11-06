import pytest

from main import create_app, db


@pytest.fixture()
def app():
    app = create_app(
        {
            "TESTING": True,
            "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:",
            "SQLALCHEMY_TRACK_MODIFICATIONS": False,
        }
    )

    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()


@pytest.fixture()
def client(app):
    return app.test_client()


def test_home_returns_application_information(client):
    response = client.get("/")

    assert response.status_code == 200

    data = response.get_json()
    assert data["application"] == "AWS-Terraform-Infra"
    assert data["status"] == "running"
    assert data["environment"] == "local"


def test_health_returns_healthy_status(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_database_health_returns_connected(client):
    response = client.get("/health/db")

    assert response.status_code == 200
    assert response.get_json() == {
        "status": "healthy",
        "database": "connected",
    }


def test_create_message(client):
    response = client.post(
        "/messages",
        json={"content": "Hello AWS"},
    )

    assert response.status_code == 201

    data = response.get_json()
    assert data["id"] == 1
    assert data["content"] == "Hello AWS"
    assert "created_at" in data


def test_create_message_rejects_empty_content(client):
    response = client.post(
        "/messages",
        json={"content": "   "},
    )

    assert response.status_code == 400
    assert response.get_json() == {"error": "Content is required"}


def test_create_message_rejects_content_over_500_characters(client):
    response = client.post(
        "/messages",
        json={"content": "A" * 501},
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": "Content must not exceed 500 characters"
    }


def test_create_message_rejects_non_json_object(client):
    response = client.post(
        "/messages",
        data="not json",
        content_type="text/plain",
    )

    assert response.status_code == 400
    assert response.get_json() == {
        "error": "A JSON object is required"
    }


def test_get_messages_returns_saved_messages(client):
    client.post("/messages", json={"content": "First message"})
    client.post("/messages", json={"content": "Second message"})

    response = client.get("/messages")

    assert response.status_code == 200

    messages = response.get_json()["messages"]
    assert len(messages) == 2
    assert {message["content"] for message in messages} == {
        "First message",
        "Second message",
    }
