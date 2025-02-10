import pytest
from fastapi.testclient import TestClient

from backend.lambdas.front_service.handler import app  # Ensure this path is correct


client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}


def test_create_item():
    response = client.post("/items/", json={"name": "Test Item", "price": 10.5})
    assert response.status_code == 200
    assert response.json() == {"name": "Test Item", "price": 10.5}


def test_list_clusters(emr_client):
    response = client.get("/api/clusters")
    assert response.status_code == 200
    # Add assertions based on expected response


def test_terminate_cluster(emr_client):
    # Assuming a cluster with ID 'j-1234567890' exists
    response = client.post("/api/clusters/j-1234567890/terminate")
    assert response.status_code == 200
    assert response.json() == {"message": "Cluster terminated successfully"}
