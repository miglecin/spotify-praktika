-- schema.sql
-- Mini Spotify duomenų bazės schema (MySQL)

DROP DATABASE IF EXISTS spotify_db;
CREATE DATABASE spotify_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE spotify_db;

-- 1. Vartotojai

CREATE TABLE user_account (
    user_id         INT AUTO_INCREMENT PRIMARY KEY,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    display_name    VARCHAR(100) NOT NULL,
    country         VARCHAR(2),
    birth_date      DATE,
    gender          ENUM('M','F','O') NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Prenumeratos planai

CREATE TABLE subscription_plan (
    plan_id             INT AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    monthly_price_eur   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    max_devices         INT NOT NULL DEFAULT 1,
    offline_available   BOOLEAN NOT NULL DEFAULT FALSE
);

-- 3. Atlikėjai

CREATE TABLE artist (
    artist_id       INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    country         VARCHAR(2),
    is_band         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Albumai

CREATE TABLE album (
    album_id        INT AUTO_INCREMENT PRIMARY KEY,
    artist_id       INT NOT NULL,
    title           VARCHAR(255) NOT NULL,
    release_date    DATE,
    total_tracks    INT,
    album_type      ENUM('album','single','ep') NOT NULL DEFAULT 'album',
    CONSTRAINT fk_album_artist
        FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 5. Dainos (track)

CREATE TABLE track (
    track_id        INT AUTO_INCREMENT PRIMARY KEY,
    album_id        INT NOT NULL,
    title           VARCHAR(255) NOT NULL,
    duration_seconds INT NOT NULL,
    track_number    INT,
    explicit        BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_track_album
        FOREIGN KEY (album_id) REFERENCES album(album_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 6. Žanrai

CREATE TABLE genre (
    genre_id        INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE
);

-- 7. Grotaraščiai

CREATE TABLE playlist (
    playlist_id     INT AUTO_INCREMENT PRIMARY KEY,
    owner_user_id   INT NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    is_public       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_playlist_owner
        FOREIGN KEY (owner_user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 8. Klausymo sesijos

CREATE TABLE listening_session (
    session_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    device_type     ENUM('mobile','desktop','web','tv','other') NOT NULL DEFAULT 'mobile',
    app_version     VARCHAR(50),
    start_time      DATETIME NOT NULL,
    end_time        DATETIME,
    CONSTRAINT fk_session_user
        FOREIGN KEY (user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 9. Daina–atlikėjai (feat ir pan.) N:N

CREATE TABLE track_artist (
    track_id        INT NOT NULL,
    artist_id       INT NOT NULL,
    role            ENUM('primary','featured','remixer') NOT NULL DEFAULT 'primary',
    PRIMARY KEY (track_id, artist_id),
    CONSTRAINT fk_track_artist_track
        FOREIGN KEY (track_id) REFERENCES track(track_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_track_artist_artist
        FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 10. Daina–žanras N:N

CREATE TABLE track_genre (
    track_id        INT NOT NULL,
    genre_id        INT NOT NULL,
    PRIMARY KEY (track_id, genre_id),
    CONSTRAINT fk_track_genre_track
        FOREIGN KEY (track_id) REFERENCES track(track_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_track_genre_genre
        FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 11. Grotaraštis–dainos

CREATE TABLE playlist_track (
    playlist_id     INT NOT NULL,
    track_id        INT NOT NULL,
    position        INT NOT NULL,
    added_by_user_id INT NOT NULL,
    added_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, track_id),
    CONSTRAINT fk_playlist_track_playlist
        FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_playlist_track_track
        FOREIGN KEY (track_id) REFERENCES track(track_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_playlist_track_added_by
        FOREIGN KEY (added_by_user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 12. Vartotojo prenumeratos istorija

CREATE TABLE user_subscription (
    user_subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    plan_id         INT NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE,
    status          ENUM('active','cancelled','expired') NOT NULL DEFAULT 'active',
    CONSTRAINT fk_user_subscription_user
        FOREIGN KEY (user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_user_subscription_plan
        FOREIGN KEY (plan_id) REFERENCES subscription_plan(plan_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 13. Klausymo įvykiai (play istorija)

CREATE TABLE listening_event (
    event_id        INT AUTO_INCREMENT PRIMARY KEY,
    session_id      INT NOT NULL,
    track_id        INT NOT NULL,
    started_at      DATETIME NOT NULL,
    listened_ms     INT NOT NULL,
    is_skipped      BOOLEAN NOT NULL DEFAULT FALSE,
    source_type     ENUM('playlist','album','search','radio','other') NOT NULL DEFAULT 'playlist',
    CONSTRAINT fk_event_session
        FOREIGN KEY (session_id) REFERENCES listening_session(session_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_event_track
        FOREIGN KEY (track_id) REFERENCES track(track_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 14. Mėgstamos dainos

CREATE TABLE user_liked_track (
    user_id         INT NOT NULL,
    track_id        INT NOT NULL,
    liked_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, track_id),
    CONSTRAINT fk_like_track_user
        FOREIGN KEY (user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_like_track_track
        FOREIGN KEY (track_id) REFERENCES track(track_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 15. Mėgstami albumai

CREATE TABLE user_liked_album (
    user_id         INT NOT NULL,
    album_id        INT NOT NULL,
    liked_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, album_id),
    CONSTRAINT fk_like_album_user
        FOREIGN KEY (user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_like_album_album
        FOREIGN KEY (album_id) REFERENCES album(album_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 16. Sekami atlikėjai

CREATE TABLE user_follow_artist (
    user_id         INT NOT NULL,
    artist_id       INT NOT NULL,
    followed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, artist_id),
    CONSTRAINT fk_follow_artist_user
        FOREIGN KEY (user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_follow_artist_artist
        FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 17. Sekami grotaraščiai

CREATE TABLE user_follow_playlist (
    user_id         INT NOT NULL,
    playlist_id     INT NOT NULL,
    followed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, playlist_id),
    CONSTRAINT fk_follow_playlist_user
        FOREIGN KEY (user_id) REFERENCES user_account(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_follow_playlist_playlist
        FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Naudingi indeksai (analizei)

CREATE INDEX idx_listening_event_track ON listening_event(track_id);
CREATE INDEX idx_listening_event_started_at ON listening_event(started_at);
CREATE INDEX idx_listening_session_user ON listening_session(user_id);
CREATE INDEX idx_playlist_owner ON playlist(owner_user_id);
