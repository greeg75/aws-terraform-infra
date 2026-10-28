from main import app


def test_home_returns_application_information():
    app.config["TESTING"] = True
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200

    data = response.get_json()
    assert data["application"] == "AWS-Terraform-Infra"
    assert data["status"] == "running"
    assert data["environment"] == "local"


def test_health_returns_healthy_status():
    app.config["TESTING"] = True
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}
