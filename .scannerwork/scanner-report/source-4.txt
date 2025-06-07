import os
from fastapi import FastAPI, status
from fastapi.responses import Response
import psycopg2

app = FastAPI()

def get_db_connection():
    DATABASE_URL = os.getenv("DATABASE_URL")
    return psycopg2.connect(DATABASE_URL)

@app.get("/health")
def health_check():
    try:
        conn = get_db_connection()
        conn.close()
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    except Exception as err:
        return Response(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, content=str(err))
