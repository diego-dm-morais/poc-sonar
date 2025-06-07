import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture
def test_client():
    """Fixture para fornecer um cliente de teste FastAPI."""
    with TestClient(app) as client:
        yield client


@pytest.fixture
def mock_db_connection():
    """Fixture para mockar a conexão com o banco de dados."""
    with patch("app.main.get_db_connection") as mock:
        mock.return_value = MagicMock()  # Fornece um mock padrão
        yield mock


def test_health_check_success(test_client):
    """Testa o endpoint de health check quando tudo está funcionando."""
    response = test_client.get("/health")
    assert response.status_code == 204


def test_health_check_failure(test_client, mock_db_connection):
    """Testa o endpoint de health check quando o banco de dados está inacessível."""
    mock_db_connection.side_effect = Exception("DB down")
    response = test_client.get("/health")
    
    assert response.status_code == 503
    assert "DB down" in response.text