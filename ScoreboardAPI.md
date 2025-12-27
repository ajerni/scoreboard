# Scoreboard API Documentation

This document describes the Scoreboard API endpoints for the leaderboard system.

## Authentication

All API endpoints require authentication via the `x-api-key` header:
```
x-api-key: statustracker-apisecret
```

## Base URL

- Local development: `http://localhost:8083`
- Production: `https://statustracker.ernilabs.com`

## Endpoints

### 1. Enter Score

Submit a new score entry to the leaderboard.

**Endpoint:** `POST /api/scoreboard/enter_score`

**Request Body:**
```json
{
  "name": "PlayerName",
  "score": 1000
}
```

**Example Request:**
```bash
curl -X POST http://localhost:8083/api/scoreboard/enter_score \
  -H "Content-Type: application/json" \
  -H "x-api-key: statustracker-apisecret" \
  -d '{"name": "Alice", "score": 1500}'
```

**Response:**
```json
{
  "id": 1,
  "name": "Alice",
  "score": 1500,
  "created_at": "2024-01-15T10:30:00Z",
  "is_top_10": true
}
```

**Response Fields:**
- `id`: Unique identifier for the score entry
- `name`: Player name
- `score`: Score value
- `created_at`: Timestamp when the entry was created
- `is_top_10`: Boolean indicating if this entry made it into the top 10 leaderboard

---

### 2. Show Scores

Retrieve the top 10 scores from the leaderboard.

**Endpoint:** `GET /api/scoreboard/show_scores`

**Example Request:**
```bash
curl -X GET http://localhost:8083/api/scoreboard/show_scores \
  -H "x-api-key: statustracker-apisecret"
```

**Response:**
```json
[
  {
    "rank": 1,
    "id": 5,
    "name": "Charlie",
    "score": 2000,
    "created_at": "2024-01-15T09:00:00Z"
  },
  {
    "rank": 2,
    "id": 1,
    "name": "Alice",
    "score": 1500,
    "created_at": "2024-01-15T10:30:00Z"
  },
  {
    "rank": 3,
    "id": 3,
    "name": "Bob",
    "score": 1200,
    "created_at": "2024-01-15T11:00:00Z"
  }
  // ... up to 10 entries
]
```

**Response Fields:**
- `rank`: Position in the leaderboard (1-10)
- `id`: Unique identifier for the score entry
- `name`: Player name
- `score`: Score value
- `created_at`: Timestamp when the entry was created

**Note:** Scores are ordered by:
1. Highest score first
2. Earliest timestamp first (for ties)

---

### 3. Empty Scoreboard

Clear all entries from the scoreboard.

**Endpoint:** `DELETE /api/scoreboard/empty_scoreboard`

**Example Request:**
```bash
curl -X DELETE http://localhost:8083/api/scoreboard/empty_scoreboard \
  -H "x-api-key: statustracker-apisecret"
```

**Response:**
```json
{
  "message": "Scoreboard cleared successfully",
  "deleted_count": 25
}
```

**Response Fields:**
- `message`: Success message
- `deleted_count`: Number of entries that were deleted

---

## Error Responses

All endpoints may return the following error responses:

### 401 Unauthorized
```json
{
  "error": "Invalid or missing x-api-key header"
}
```

### 500 Internal Server Error
```json
{
  "error": "Failed to [operation]"
}
```

---

## Database Schema

The scoreboard system uses the following PostgreSQL components:

- **Table:** `scoreboard_entries` - Stores all score submissions
- **View:** `top_10_scoreboard` - Automatically updated view of top 10 scores
- **Functions:**
  - `insert_scoreboard_entry(name, score)` - Inserts a new score
  - `get_top_10_scores()` - Returns top 10 scores with ranks
  - `empty_scoreboard()` - Clears all entries

---

## Notes

- The leaderboard automatically maintains the top 10 scores
- When a new score is entered, it's automatically checked against the top 10
- Scores are ranked by highest score first, with earliest timestamp as tiebreaker
- The `is_top_10` flag in the enter_score response indicates if the new entry made it to the leaderboard

