-- ============================================
-- SCOREBOARD LEADERBOARD SYSTEM
-- ============================================

-- 1. Create the main scoreboard entries table
CREATE TABLE IF NOT EXISTS scoreboard_entries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    score INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create an index on score for faster queries
CREATE INDEX idx_scoreboard_score ON scoreboard_entries(score DESC);

-- 3. Create a view for the top 10 scores
CREATE OR REPLACE VIEW top_10_scoreboard AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY score DESC, created_at ASC) as rank,
    id,
    name,
    score,
    created_at
FROM scoreboard_entries
ORDER BY score DESC, created_at ASC
LIMIT 10;

-- 4. Create a function to get the top 10 scores
CREATE OR REPLACE FUNCTION get_top_10_scores()
RETURNS TABLE (
    rank BIGINT,
    id INTEGER,
    name VARCHAR(255),
    score INTEGER,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ROW_NUMBER() OVER (ORDER BY s.score DESC, s.created_at ASC) as rank,
        s.id,
        s.name,
        s.score,
        s.created_at
    FROM scoreboard_entries s
    ORDER BY s.score DESC, s.created_at ASC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a function to insert a new score
CREATE OR REPLACE FUNCTION insert_scoreboard_entry(
    p_name VARCHAR(255),
    p_score INTEGER
)
RETURNS TABLE (
    id INTEGER,
    name VARCHAR(255),
    score INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    is_top_10 BOOLEAN
) AS $$
DECLARE
    v_id INTEGER;
    v_created_at TIMESTAMP WITH TIME ZONE;
    v_is_top_10 BOOLEAN;
BEGIN
    -- Insert the new entry
    INSERT INTO scoreboard_entries (name, score)
    VALUES (p_name, p_score)
    RETURNING scoreboard_entries.id, scoreboard_entries.created_at 
    INTO v_id, v_created_at;
    
    -- Check if this entry is in the top 10
    v_is_top_10 := EXISTS (
        SELECT 1 FROM (
            SELECT e.id
            FROM scoreboard_entries e
            ORDER BY e.score DESC, e.created_at ASC
            LIMIT 10
        ) top_entries
        WHERE top_entries.id = v_id
    );
    
    -- Return the inserted entry with top 10 status
    RETURN QUERY
    SELECT v_id, p_name, p_score, v_created_at, v_is_top_10;
END;
$$ LANGUAGE plpgsql;

-- 6. Create a function to empty the scoreboard
CREATE OR REPLACE FUNCTION empty_scoreboard()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete all entries and return count
    DELETE FROM scoreboard_entries;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 7. Create a trigger function for logging (optional but useful)
CREATE OR REPLACE FUNCTION scoreboard_entry_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- This can be extended to do additional processing on INSERT
    -- For example, logging, notifications, etc.
    RAISE NOTICE 'New score entry: % scored %', NEW.name, NEW.score;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Create the trigger
CREATE TRIGGER after_scoreboard_insert
    AFTER INSERT ON scoreboard_entries
    FOR EACH ROW
    EXECUTE FUNCTION scoreboard_entry_trigger();

-- 9. Grant permissions (adjust username as needed)
GRANT SELECT, INSERT, DELETE ON scoreboard_entries TO statustracker_user;
GRANT SELECT ON top_10_scoreboard TO statustracker_user;
GRANT USAGE, SELECT ON SEQUENCE scoreboard_entries_id_seq TO statustracker_user;

-- ============================================
-- VERIFICATION QUERIES (optional - for testing)
-- ============================================

-- Insert some test data
-- INSERT INTO scoreboard_entries (name, score) VALUES 
-- ('Alice', 1000),
-- ('Bob', 850),
-- ('Charlie', 900),
-- ('Diana', 950),
-- ('Eve', 800),
-- ('Frank', 1100),
-- ('Grace', 750),
-- ('Henry', 1050),
-- ('Ivy', 880),
-- ('Jack', 920),
-- ('Kate', 700),
-- ('Leo', 1200);

-- View the top 10
-- SELECT * FROM top_10_scoreboard;

-- Use the function to get top 10
-- SELECT * FROM get_top_10_scores();

-- Test inserting a new score
-- SELECT * FROM insert_scoreboard_entry('TestUser', 975);