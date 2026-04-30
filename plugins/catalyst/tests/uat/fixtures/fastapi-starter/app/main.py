from fastapi import FastAPI
from app.routes import health

app = FastAPI(title="FastAPI Starter")

app.include_router(health.router)


@app.get("/")
def root():
    return {"message": "FastAPI Starter"}
