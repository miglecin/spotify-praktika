-- SEED DATA FOR spotify_db
USE spotify_db;

-- -------------------------------
-- SUBSCRIPTION PLANS
-- -------------------------------

INSERT INTO subscription_plan (plan_id, name, monthly_price_eur, max_devices, offline_available) VALUES
(1, 'Free', 0.00, 1, 0),
(2, 'Premium', 6.99, 3, 1),
(3, 'Family', 10.99, 6, 1);

-- -------------------------------
-- USERS
-- -------------------------------

INSERT INTO user_account (user_id, email, password_hash, display_name, country, birth_date, gender, created_at) VALUES
(1, 'jonas@example.com', 'hash1', 'Jonas', 'LT', '2002-05-10', 'M', NOW()),
(2, 'ugne@example.com', 'hash2', 'Ugnė', 'LT', '2001-11-23', 'F', NOW()),
(3, 'martynas@example.com', 'hash3', 'Martynas', 'LV', '2000-01-15', 'M', NOW());

-- -------------------------------
-- USER SUBSCRIPTIONS
-- -------------------------------

INSERT INTO user_subscription (user_subscription_id, user_id, plan_id, start_date, end_date, status) VALUES
(1, 1, 2, '2024-01-01', NULL, 'active'),
(2, 2, 1, '2024-02-01', NULL, 'active'),
(3, 3, 3, '2024-03-01', NULL, 'active');

-- -------------------------------
-- ARTISTS
-- -------------------------------

INSERT INTO artist (artist_id, name, country, is_band, created_at) VALUES
(1, 'Imagine Dragons', 'US', 1, NOW()),
(2, 'Billie Eilish', 'US', 0, NOW()),
(3, 'The Weeknd', 'CA', 0, NOW()),
(4, 'Ten Walls', 'LT', 0, NOW());

-- -------------------------------
-- ALBUMS
-- -------------------------------

INSERT INTO album (album_id, artist_id, title, release_date, total_tracks, album_type) VALUES
(1, 1, 'Night Visions', '2012-09-04', 12, 'album'),
(2, 2, 'WHEN WE ALL FALL ASLEEP, WHERE DO WE GO?', '2019-03-29', 14, 'album'),
(3, 3, 'After Hours', '2020-03-20', 14, 'album'),
(4, 4, 'Queen', '2015-03-15', 8, 'ep');

-- -------------------------------
-- TRACKS
-- -------------------------------

INSERT INTO track (track_id, album_id, title, duration_seconds, track_number, explicit) VALUES
(1, 1, 'Radioactive', 186, 1, 0),
(2, 1, 'Demons', 177, 2, 0),
(3, 2, 'bad guy', 194, 2, 1),
(4, 3, 'Blinding Lights', 200, 9, 0),
(5, 4, 'Walking with Elephants', 189, 1, 0);

-- -------------------------------
-- TRACK – ARTIST (N:N)
-- -------------------------------

INSERT INTO track_artist (track_id, artist_id, role) VALUES
(1, 1, 'primary'),
(2, 1, 'primary'),
(3, 2, 'primary'),
(4, 3, 'primary'),
(5, 4, 'primary');

-- -------------------------------
-- GENRES
-- -------------------------------

INSERT INTO genre (genre_id, name) VALUES
(1, 'Rock'),
(2, 'Pop'),
(3, 'Electronic'),
(4, 'Indie'),
(5, 'Alternative');

-- -------------------------------
-- TRACK – GENRE (N:N)
-- -------------------------------

INSERT INTO track_genre (track_id, genre_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3);

-- -------------------------------
-- PLAYLISTS
-- -------------------------------

INSERT INTO playlist (playlist_id, owner_user_id, name, description, is_public, created_at) VALUES
(1, 1, 'Morning Vibes', 'Raminančios dainos rytui', 1, NOW()),
(2, 2, 'Workout', 'Intensyvios treniruočių dainos', 1, NOW());

-- -------------------------------
-- PLAYLIST TRACKS
-- -------------------------------

INSERT INTO playlist_track (playlist_id, track_id, position, added_by_user_id, added_at) VALUES
(1, 2, 1, 1, NOW()),
(1, 3, 2, 1, NOW()),
(1, 4, 3, 1, NOW()),
(2, 1, 1, 2, NOW()),
(2, 4, 2, 2, NOW()),
(2, 5, 3, 2, NOW());

-- -------------------------------
-- LISTENING SESSIONS
-- -------------------------------

INSERT INTO listening_session (session_id, user_id, device_type, app_version, start_time, end_time) VALUES
(1, 1, 'mobile', '1.0.0', '2024-04-01 08:00:00', '2024-04-01 08:45:00'),
(2, 2, 'desktop', '1.0.1', '2024-04-01 18:00:00', '2024-04-01 19:10:00'),
(3, 1, 'web', '1.0.2', '2024-04-02 21:00:00', '2024-04-02 21:30:00');

-- -------------------------------
-- LISTENING EVENTS
-- -------------------------------

INSERT INTO listening_event (event_id, session_id, track_id, started_at, listened_ms, is_skipped, source_type) VALUES
(1, 1, 2, '2024-04-01 08:05:00', 177000, 0, 'playlist'),
(2, 1, 3, '2024-04-01 08:09:00', 150000, 1, 'playlist'),
(3, 1, 4, '2024-04-01 08:13:00', 200000, 0, 'playlist'),
(4, 2, 1, '2024-04-01 18:05:00', 120000, 1, 'playlist'),
(5, 2, 4, '2024-04-01 18:10:00', 200000, 0, 'playlist'),
(6, 2, 5, '2024-04-01 18:15:00', 189000, 0, 'playlist'),
(7, 3, 4, '2024-04-02 21:05:00', 200000, 0, 'search');

-- -------------------------------
-- USER LIKED TRACKS
-- -------------------------------

INSERT INTO user_liked_track (user_id, track_id, liked_at) VALUES
(1, 4, NOW()),
(1, 2, NOW()),
(2, 1, NOW()),
(2, 3, NOW());

-- -------------------------------
-- USER LIKED ALBUMS
-- -------------------------------

INSERT INTO user_liked_album (user_id, album_id, liked_at) VALUES
(1, 1, NOW()),
(1, 3, NOW()),
(2, 2, NOW());

-- -------------------------------
-- USER FOLLOW ARTISTS
-- -------------------------------

INSERT INTO user_follow_artist (user_id, artist_id, followed_at) VALUES
(1, 1, NOW()),
(1, 3, NOW()),
(2, 2, NOW()),
(3, 4, NOW());

-- -------------------------------
-- USER FOLLOW PLAYLISTS
-- -------------------------------

INSERT INTO user_follow_playlist (user_id, playlist_id, followed_at) VALUES
(2, 1, NOW()),
(3, 1, NOW()),
(3, 2, NOW());
