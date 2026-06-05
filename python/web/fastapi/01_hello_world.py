from fastapi import FastAPI

app = FastAPI()
"""
uvicorn example_simple:app --reload

"""


@app.get("/")
def hello():
    return {"message": "hello fastapi"}
