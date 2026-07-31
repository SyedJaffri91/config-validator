from fastapi import FastAPI
from pydantic import BaseModel
import yaml

app = FastAPI(title="Config Validator")

class ConfigInput(BaseModel):
    content: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/validate")
def validate(payload: ConfigInput):
    try:
        parsed = yaml.safe_load(payload.content)
    except yaml.YAMLError as e:
        return {"valid": False, "errors": [str(e)]}

    errors = []
    if not isinstance(parsed, dict):
        errors.append("Top level must be a mapping (key: value)")
    else:
        for field in ("name", "owner"):
            if field not in parsed:
                errors.append(f"Missing required field: {field}")
    return {"valid": len(errors) == 0, "errors": errors}