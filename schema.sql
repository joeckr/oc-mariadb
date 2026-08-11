-- Create an application schema (Treats 'app' as the target database/schema)
CREATE DATABASE IF NOT EXISTS app;
USE app;

-- Create primary users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT UUID(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role ENUM('admin', 'member', 'guest') DEFAULT 'member',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create secondary relational table
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    content LONGTEXT,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_posts_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index for querying posts by author efficiently
-- Note: 'IF NOT EXISTS' for indexes is not supported natively in all MariaDB syntax,
-- but putting it directly inside or alongside table creation handles this cleanly.
CREATE INDEX idx_posts_author_id ON posts(author_id);

-- Insert mock seed data to verify mounting succeeded
-- Uses ON DUPLICATE KEY UPDATE to mimic Postgres 'ON CONFLICT DO NOTHING'
INSERT INTO users (username, email, role) VALUES
    ('admin_user', 'admin@example.com', 'admin'),
    ('test_user', 'user@example.com', 'member')
ON DUPLICATE KEY UPDATE username=username;

-- Seed downstream post data linking back to the generated admin UUID
INSERT INTO posts (author_id, title, content)
SELECT id, 'Welcome Post', 'This post verifies that schema mounting and seeding worked!'
FROM users WHERE username = 'admin_user'
LIMIT 1;
