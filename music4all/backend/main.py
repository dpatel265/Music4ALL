from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from service import create_demo_service
from ytmusicapi import YTMusic

app = FastAPI()

# Initialize Service
service = create_demo_service()
yt = YTMusic()

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

@app.get("/search")
def search_tracks(query: str, filter: str = "songs"):
    try:
        results = yt.search(query, filter=filter)
        cleaned_results = []
        for result in results:
            # Safely extract thumbnails
            thumbnails = result.get('thumbnails', [])
            thumbnail_url = thumbnails[-1]['url'] if thumbnails else ""

            # Safely extract artists
            artists = result.get('artists', [])
            artist_name = ", ".join([a.get('name', '') for a in artists])

            # Safely extract album
            album = result.get('album', {})
            album_name = album.get('name', '') if album else ""

            cleaned_results.append({
                "videoId": result.get('videoId'),
                "title": result.get('title'),
                "artist": artist_name,
                "album": album_name,
                "thumbnail": thumbnail_url,
                "duration": result.get('duration', ''),
                "isExplicit": result.get('isExplicit', False)
            })
        return cleaned_results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/lyrics/{videoId}")
def get_lyrics(videoId: str):
    try:
        # 1. Get watch playlist to find lyrics ID
        watch_playlist = yt.get_watch_playlist(videoId)
        lyrics_id = watch_playlist.get('lyrics')

        if not lyrics_id:
            raise HTTPException(status_code=404, detail="Lyrics not available")

        # 2. Get lyrics
        lyrics_data = yt.get_lyrics(lyrics_id)
        return {"lyrics": lyrics_data.get('lyrics')}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
