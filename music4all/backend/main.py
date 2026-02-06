from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from service import create_demo_service, RecommendationService

app = FastAPI()

# Initialize Service
service = create_demo_service()

class RecommendationRequest(BaseModel):
    seed_track_id: str
    user_history_ids: List[str] = []
    limit: int = 5

@app.get("/")
def read_root():
    return {"status": "Music4All Backend is running"}

@app.post("/recommendations")
def get_recommendations(request: RecommendationRequest):
    try:
        recommendations = service.get_recommendations(
            seed_track_id=request.seed_track_id,
            user_history_ids=request.user_history_ids,
            limit=request.limit
        )
        return {"tracks": recommendations}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
