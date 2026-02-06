from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
import math
import random

# --- Data Models ---

@dataclass
class Track:
    id: str
    title: str
    artist: str
    bpm: float
    # Simulated vector embedding (3 dimensions for simplicity)
    vector_embedding: List[float] 
    
    def to_json(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "title": self.title,
            "artist": self.artist,
            "bpm": self.bpm
        }

# --- Service Interfaces (Ports) ---

class VectorStore:
    """Abstract interface for Vector Database (e.g., pgvector, Pinecone)."""
    def find_nearest_neighbors(self, vector: List[float], limit: int = 20) -> List[Track]:
        # Implementation would call actual DB
        raise NotImplementedError

class MetadataStore:
    """Abstract interface for SQL/NoSQL Metadata Store."""
    def get_track_by_id(self, track_id: str) -> Optional[Track]:
        raise NotImplementedError

# --- Mock Implementations (for demonstration) ---

class MockVectorStore(VectorStore):
    def __init__(self, all_tracks: List[Track]):
        self.all_tracks = all_tracks

    def find_nearest_neighbors(self, vector: List[float], limit: int = 20) -> List[Track]:
        # Simple Cosine Similarity simulation
        def cosine_sim(v1, v2):
            dot = sum(a*b for a, b in zip(v1, v2))
            norm_a = math.sqrt(sum(a*a for a in v1))
            norm_b = math.sqrt(sum(b*b for b in v2))
            return dot / (norm_a * norm_b) if norm_a and norm_b else 0
        
        # Sort by similarity desc
        sorted_tracks = sorted(
            self.all_tracks, 
            key=lambda t: cosine_sim(vector, t.vector_embedding), 
            reverse=True
        )
        return sorted_tracks[:limit]

class MockMetadataStore(MetadataStore):
    def __init__(self, tracks: List[Track]):
        self.tracks = {t.id: t for t in tracks}
    
    def get_track_by_id(self, track_id: str) -> Optional[Track]:
        return self.tracks.get(track_id)

# --- CORE SERVICE LOGIC ---

class RecommendationService:
    def __init__(self, vector_store: VectorStore, metadata_store: MetadataStore):
        self.vector_store = vector_store
        self.metadata_store = metadata_store

    def get_recommendations(
        self, 
        seed_track_id: str, 
        user_history_ids: List[str], 
        limit: int = 5
    ) -> List[Dict[str, Any]]:
        """
        Generates 'Endless Mode' recommendations based on a seed track.
        Prioritizes 'Vibe Continuity' (BPM matching).
        """
        
        # Step A: Vector Lookup
        seed_track = self.metadata_store.get_track_by_id(seed_track_id)
        if not seed_track:
            # Fallback if seed not found in mock DB: pick a random one or error
            # For robustness in demo, let's just pick the first track in store if available
            # Or simpler: return empty list
            print(f"[Warn] Seed track {seed_track_id} not found. Using defaults.")
            return []
        
        seed_vector = seed_track.vector_embedding
        seed_bpm = seed_track.bpm
        
        # Step B: Candidate Generation
        # Fetch 4x limit to allow for filtering
        candidates = self.vector_store.find_nearest_neighbors(seed_vector, limit=limit * 4)
        
        # Step C: Hard Filtering
        filtered_candidates = [
            track for track in candidates 
            if track.id not in user_history_ids and track.id != seed_track_id
        ]
        
        # Step D: Vibe Re-Ranking (The Core Logic)
        scored_candidates = []
        
        for track in filtered_candidates:
            score = 1.0 
            
            # --- VIBE LOGIC ---
            # BPM Continuity
            bpm_diff = abs(track.bpm - seed_bpm)
            
            if bpm_diff <= 10:
                score *= 1.5  # Boost
            elif bpm_diff > 30:
                score *= 0.5  # Penalize
            
            scored_candidates.append((track, score))

        # Sort by final score
        scored_candidates.sort(key=lambda x: x[1], reverse=True)
        
        # Select top N
        final_selection = [item[0] for item in scored_candidates[:limit]]
        
        return [t.to_json() for t in final_selection]

# --- Demo Data Setup ---
def create_demo_service() -> RecommendationService:
    tracks_db = [
        Track("1", "Chill Lo-Fi Beat", "Lofi Girl", 85.0, [0.1, 0.2, 0.9]),
        Track("2", "Fast Techno", "Rave Master", 140.0, [0.9, 0.8, 0.1]),
        Track("3", "Smooth Jazz", "Jazz Cat", 90.0, [0.15, 0.25, 0.85]),
        Track("4", "Heavy Metal", "Metal head", 130.0, [0.8, 0.9, 0.2]),
        Track("5", "Acoustic Pop", "Indie Boy", 88.0, [0.2, 0.3, 0.8]),
        Track("6", "Deep House", "Club DJ", 120.0, [0.7, 0.6, 0.4]),
        Track("7", "Piano Ballad", "Sad Artist", 80.0, [0.1, 0.1, 0.92]),
        # Adding some that match "Tyla" vibes (Pop/RnB/Afrobeats - Mid BPM)
        Track("uLK2r3sG4lE", "Tyla - PUSH 2 START", "Tyla", 100.0, [0.3, 0.6, 0.5]),
        Track("XoiOOiuH8iI", "Tyla - Water", "Tyla", 102.0, [0.3, 0.65, 0.55]),
        Track("SZpiiixlHWY", "Tyla - IS IT", "Tyla", 105.0, [0.3, 0.6, 0.5]),
    ]
    
    vector_store = MockVectorStore(tracks_db)
    meta_store = MockMetadataStore(tracks_db)
    return RecommendationService(vector_store, meta_store)
