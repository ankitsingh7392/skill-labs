import json
from fastapi import FastAPI

app = FastAPI()
"""uvicorn user:app --reload

"""
@app.get("/")
def hello():
    return {"message": "hello user"}

def read_json():
    with open("user.json", "r") as f:
        data = json.load(f)
    return data

@app.get("/users")
def get_users():
    data = read_json()
    return {"users": data}

@app.post("/users")
def create_user(user: dict):
    data = read_json()
    data.append(user)
    with open("user.json", "w") as f:
        json.dump(data, f, indent=4)
    return {"message": "User created successfully", "user": user}