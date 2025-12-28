# Scoreboard Leaderboard System

A modern, real-time leaderboard system built with Rust (Actix-web), PostgreSQL 16, and a beautiful HTML frontend. Features automatic top 10 ranking, real-time updates, and a RESTful API.

See live demo at: [https://scoreboard.andierni.ch](https://scoreboard.andierni.ch)

## 🏗️ Architecture

- **Backend**: Rust (Actix-web) REST API
- **Database**: PostgreSQL 16 with views, triggers, and functions
- **Frontend**: Single-page HTML application with auto-refresh
- **Deployment**: Docker Compose for backend, static hosting for frontend

## 📁 Project Structure

```
scoreboard/
├── main.rs                    # Rust backend API server
├── index.html                 # Frontend single-page application
├── scoreboard_creation.sql    # Database schema, views, triggers, functions
├── ScoreboardAPI.md           # Complete API documentation
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- PostgreSQL 16 (via Docker)
- Rust toolchain (for local development)
- Access to your vserver for deployment

### Local Development Setup

1. **Clone or navigate to the project directory**

2. **Set up the database** (if not already done):
   ```bash
   # Connect to your PostgreSQL container
   docker exec -i statustracker_postgres psql -U statustracker_user -d statustracker_db < scoreboard_creation.sql
   ```

3. **Start the backend services**:
   ```bash
   cd statustracker  # If docker-compose.yml is in a subdirectory
   docker-compose up -d
   ```

4. **Open the frontend**:
   - Simply open `index.html` in your browser, or
   - Serve it with any static file server:
     ```bash
     # Python 3
     python3 -m http.server 8000
     
     # Node.js (http-server)
     npx http-server
     
     # Or use any web server (nginx, Apache, etc.)
     ```

### API Endpoints

All endpoints require the `x-api-key: statustracker-apisecret` header.

- `POST /api/scoreboard/enter_score` - Submit a new score
- `GET /api/scoreboard/show_scores` - Get top 10 leaderboard
- `DELETE /api/scoreboard/empty_scoreboard` - Clear all scores

See [ScoreboardAPI.md](./ScoreboardAPI.md) for complete API documentation.

## 📦 Deployment

### Backend Deployment (vserver)

1. **Upload the main.rs file to your server**:
   ```bash
   rsync -avz ./main.rs administrator@host.com:/usr/local/sbin/statustracker/main.rs
   ```

2. **SSH into your server and navigate to the project directory**:
   ```bash
   ssh administrator@host.com
   cd /usr/local/sbin/statustracker
   ```

3. **Rebuild and restart the Docker containers**:
   ```bash
   docker-compose down
   docker-compose up --build -d
   ```

4. **Verify the service is running**:
   ```bash
   docker-compose ps
   curl http://localhost:8080/health
   ```

### Frontend Deployment

The `index.html` file can be served from anywhere:

- **Static file hosting** (GitHub Pages, Netlify, Vercel, etc.)
- **Web server** (nginx, Apache, etc.)
- **CDN** (Cloudflare, AWS CloudFront, etc.)
- **Any HTTP server**

**Important**: Update the `API_BASE` constant in `index.html` if your API is hosted at a different URL:

```javascript
const API_BASE = window.location.hostname === 'localhost' 
    ? 'http://localhost:8083/api' 
    : 'https://statustracker.ernilabs.com/api';
```

### Database Setup (First Time)

If setting up the database for the first time:

```bash
# Connect to PostgreSQL container
docker exec -it statustracker_postgres psql -U statustracker_user -d statustracker_db

# Or run the SQL script directly
docker exec -i statustracker_postgres psql -U statustracker_user -d statustracker_db < scoreboard_creation.sql
```

The SQL script creates:
- `scoreboard_entries` table
- `top_10_scoreboard` view
- `get_top_10_scores()` function
- `insert_scoreboard_entry()` function
- `empty_scoreboard()` function
- Trigger for automatic logging

## 🔧 Configuration

### Environment Variables

The backend uses the following environment variable (set in `docker-compose.yml`):

- `DATABASE_URL`: PostgreSQL connection string
  - Format: `postgresql://user:password@host:port/database`
  - Default (Docker network): `postgresql://statustracker_user:password@statustracker-postgres:5432/statustracker_db`

### API Key

The API key is hardcoded in `main.rs`:
- Default: `statustracker-apisecret`
- Change it in the `main()` function if needed

### Ports

- Backend API: `8080` (internal), `8083` (external)
- PostgreSQL: `5432` (internal), `5433` (external)

## 🎮 Features

- ✅ Real-time leaderboard (auto-refreshes every 5 seconds)
- ✅ Top 10 automatic ranking
- ✅ Beautiful, responsive UI
- ✅ RESTful API with authentication
- ✅ PostgreSQL views, triggers, and functions
- ✅ Automatic timestamp tracking
- ✅ Empty state handling
- ✅ Error handling and user feedback

## 🗄️ Database Schema

### Tables

- **scoreboard_entries**: Stores all score submissions
  - `id` (SERIAL PRIMARY KEY)
  - `name` (VARCHAR(255))
  - `score` (INTEGER)
  - `created_at` (TIMESTAMP WITH TIME ZONE)

### Views

- **top_10_scoreboard**: Automatically updated view showing top 10 scores

### Functions

- `get_top_10_scores()`: Returns top 10 scores with ranks
- `insert_scoreboard_entry(name, score)`: Inserts a new score and returns entry with `is_top_10` flag
- `empty_scoreboard()`: Clears all entries and returns count

### Triggers

- `after_scoreboard_insert`: Logs new score entries

## 🧪 Testing

### Test the API endpoints:

```bash
# Enter a score
curl -X POST http://localhost:8083/api/scoreboard/enter_score \
  -H "Content-Type: application/json" \
  -H "x-api-key: statustracker-apisecret" \
  -d '{"name": "TestPlayer", "score": 1000}'

# Get top 10 scores
curl -X GET http://localhost:8083/api/scoreboard/show_scores \
  -H "x-api-key: statustracker-apisecret"

# Clear scoreboard
curl -X DELETE http://localhost:8083/api/scoreboard/empty_scoreboard \
  -H "x-api-key: statustracker-apisecret"
```

## 📝 Development

### Building Locally

```bash
# Install Rust dependencies
cargo build

# Run the server
cargo run
```

### Dependencies

See `Cargo.toml` for Rust dependencies:
- `actix-web`: Web framework
- `sqlx`: PostgreSQL driver
- `serde`: Serialization
- `chrono`: Date/time handling

## 🔒 Security

- API key authentication required for all `/api/*` endpoints
- CORS configured for cross-origin requests
- SQL injection protection via parameterized queries
- XSS protection in frontend (HTML escaping)

## 📚 Documentation

- [API Documentation](./ScoreboardAPI.md) - Complete API reference
- [Database Schema](./scoreboard_creation.sql) - SQL schema and functions

## 🐛 Troubleshooting

### Backend not starting

1. Check Docker containers:
   ```bash
   docker-compose ps
   docker-compose logs
   ```

2. Verify database connection:
   ```bash
   curl http://localhost:8083/api/db -H "x-api-key: statustracker-apisecret"
   ```

### Frontend can't connect to API

1. Check CORS settings in `main.rs`
2. Verify API URL in `index.html`
3. Check browser console for errors
4. Ensure API key is correct

### Database errors

1. Verify database is running:
   ```bash
   docker exec statustracker_postgres psql -U statustracker_user -d statustracker_db -c "SELECT 1;"
   ```

2. Check if tables exist:
   ```bash
   docker exec statustracker_postgres psql -U statustracker_user -d statustracker_db -c "\dt"
   ```

3. Re-run the SQL script if needed

## 📄 License

This project is provided as-is for personal or commercial use.

## 🤝 Contributing

Feel free to submit issues or pull requests for improvements!

---

**Happy scoring! 🏆**

