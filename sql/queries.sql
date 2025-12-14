-- queries.sql
-- 10 SPOTIFY ANALITINIŲ UŽKLAUSŲ SCENARIJAI
USE spotify_db;

---------------------------------------------------------
-- SCENARIJUS 1: Populiariausios dainos
---------------------------------------------------------

-- 1.1. Top 10 dažniausiai klausomos dainos
SELECT t.track_id, t.title, COUNT(e.event_id) AS play_count
FROM track t
JOIN listening_event e ON t.track_id = e.track_id
GROUP BY t.track_id, t.title
ORDER BY play_count DESC
LIMIT 10;

-- 1.2. Dainos, kurios PILNAI išklausytos (be skip) (TOP 10)
SELECT t.track_id, t.title, COUNT(*) AS full_plays
FROM track t
JOIN listening_event e ON t.track_id = e.track_id
WHERE e.is_skipped = 0
GROUP BY t.track_id, t.title
ORDER BY full_plays DESC
LIMIT 10;

-- 1.3. Vidutinis klausymo procentas per dainą (TOP 10)
SELECT 
    t.track_id,
    t.title,
    ROUND(AVG(LEAST(e.listened_ms / (t.duration_seconds * 1000.0), 1)) * 100, 2) AS avg_listen_percent
FROM track t
JOIN listening_event e ON t.track_id = e.track_id
GROUP BY t.track_id, t.title
ORDER BY avg_listen_percent DESC
LIMIT 10;

---------------------------------------------------------
-- SCENARIJUS 2: Atlikėjų populiarumas
---------------------------------------------------------

-- 2.1. TOP atlikėjai pagal klausymus
SELECT a.artist_id, a.name, COUNT(e.event_id) AS total_plays
FROM artist a
JOIN track_artist ta ON a.artist_id = ta.artist_id
JOIN listening_event e ON ta.track_id = e.track_id
GROUP BY a.artist_id, a.name
ORDER BY total_plays DESC
LIMIT 10;

-- 2.2. Atlikėjai pagal mėgstamų track'ų skaičių
SELECT a.artist_id, a.name, COUNT(DISTINCT lt.user_id) AS unique_likers
FROM artist a
JOIN track_artist ta ON a.artist_id = ta.artist_id
JOIN user_liked_track lt ON ta.track_id = lt.track_id
GROUP BY a.artist_id, a.name
ORDER BY unique_likers DESC
LIMIT 10;

-- 2.3. Atlikėjai pagal mėgstamų albumų skaičių
SELECT a.artist_id, a.name, COUNT(DISTINCT ula.user_id) AS album_likers
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN user_liked_album ula ON al.album_id = ula.album_id
GROUP BY a.artist_id, a.name
ORDER BY album_likers DESC
LIMIT 10;

---------------------------------------------------------
-- SCENARIJUS 3: Grotaraščiai pagal vartotoją
---------------------------------------------------------

-- 3.1. Vartotojo grojaraščiai ir dainų skaičius juose
SELECT 
    p.playlist_id,
    p.name,
    u.display_name AS owner_name,
    COUNT(pt.track_id) AS track_count
FROM playlist p
LEFT JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
LEFT JOIN user_account u ON p.owner_user_id = u.user_id
GROUP BY p.playlist_id, p.name, u.display_name
ORDER BY track_count DESC
LIMIT 10;

-- 3.2. Grojaraščiai su daugiausia sekėjų
SELECT 
    p.playlist_id,
    p.name,
    COUNT(DISTINCT ufp.user_id) AS followers_count
FROM playlist p
LEFT JOIN user_follow_playlist ufp ON p.playlist_id = ufp.playlist_id
WHERE p.is_public = 1
GROUP BY p.playlist_id, p.name
ORDER BY followers_count DESC
LIMIT 10;

-- 3.3. Grojaraščiai pagal įtrauktų dainų trukmę
SELECT 
    p.playlist_id,
    p.name,
    COUNT(pt.track_id) AS total_tracks,
    COALESCE(ROUND(SUM(t.duration_seconds) / 60.0, 2), 0) AS total_duration_minutes
FROM playlist p
LEFT JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
LEFT JOIN track t ON pt.track_id = t.track_id
GROUP BY p.playlist_id, p.name
ORDER BY total_duration_minutes DESC
LIMIT 10;

---------------------------------------------------------
-- SCENARIJUS 4: Skip rate (% praleistų dainų)
---------------------------------------------------------

-- 4.1. Bendras skip rate visoms dainoms
SELECT 
    ROUND(SUM(CASE WHEN is_skipped = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS global_skip_rate_percent
FROM listening_event;

-- 4.2. Dainų skip rate – kurios praleidžiamos dažniausiai
SELECT 
    t.track_id,
    t.title,
    COUNT(*) AS total_plays,
    SUM(CASE WHEN e.is_skipped = 1 THEN 1 ELSE 0 END) AS skipped_count,
    ROUND(SUM(CASE WHEN e.is_skipped = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS skip_rate_percent
FROM track t
JOIN listening_event e ON t.track_id = e.track_id
GROUP BY t.track_id, t.title
ORDER BY skip_rate_percent DESC
LIMIT 10;

-- 4.3. Atlikėjų skip rate
SELECT 
    a.artist_id,
    a.name,
    COUNT(e.event_id) AS total_plays,
    SUM(CASE WHEN e.is_skipped = 1 THEN 1 ELSE 0 END) AS skipped_plays,
    ROUND(SUM(CASE WHEN e.is_skipped = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS artist_skip_rate_percent
FROM artist a
JOIN track_artist ta ON a.artist_id = ta.artist_id
JOIN listening_event e ON ta.track_id = e.track_id
GROUP BY a.artist_id, a.name
ORDER BY artist_skip_rate_percent DESC
LIMIT 10;

---------------------------------------------------------
-- SCENARIJUS 5: Klausymo įpročiai pagal įrenginį
---------------------------------------------------------

-- 5.1. Sesijų ir klausymų skaičius pagal įrenginį
SELECT 
    ls.device_type,
    COUNT(DISTINCT ls.session_id) AS total_sessions,
    COUNT(le.event_id) AS total_plays
FROM listening_session ls
LEFT JOIN listening_event le ON ls.session_id = le.session_id
GROUP BY ls.device_type
ORDER BY total_plays DESC
LIMIT 10;

-- 5.2. Vidutinis klausymo laikas pagal įrenginį
SELECT 
    ls.device_type,
    ROUND(AVG(le.listened_ms) / 1000.0, 2) AS avg_listen_seconds,
    MAX(le.listened_ms) / 1000.0 AS max_listen_seconds,
    MIN(le.listened_ms) / 1000.0 AS min_listen_seconds
FROM listening_session ls
JOIN listening_event le ON ls.session_id = le.session_id
GROUP BY ls.device_type
ORDER BY avg_listen_seconds DESC
LIMIT 10;

-- 5.3. Populiariausi žanrai pagal įrenginį
SELECT 
    ls.device_type,
    g.name AS genre,
    COUNT(le.event_id) AS play_count
FROM listening_session ls
JOIN listening_event le ON ls.session_id = le.session_id
JOIN track_genre tg ON le.track_id = tg.track_id
JOIN genre g ON tg.genre_id = g.genre_id
GROUP BY ls.device_type, g.name
ORDER BY ls.device_type, play_count DESC
LIMIT 10;

---------------------------------------------------------
-- SCENARIJUS 6: Dažniausiai klausomi žanrai
---------------------------------------------------------

-- 6.1. Žanrų populiarumas pagal klausymus
SELECT 
    g.genre_id,
    g.name AS genre,
    COUNT(le.event_id) AS play_count
FROM genre g
JOIN track_genre tg ON g.genre_id = tg.genre_id
JOIN listening_event le ON tg.track_id = le.track_id
GROUP BY g.genre_id, g.name
ORDER BY play_count DESC
LIMIT 10;

-- 6.2. Kiek skirtingų vartotojų klausė kiekvieno žanro
SELECT 
    g.genre_id,
    g.name AS genre,
    COUNT(DISTINCT ls.user_id) AS unique_users
FROM genre g
JOIN track_genre tg ON g.genre_id = tg.genre_id
JOIN listening_event le ON tg.track_id = le.track_id
JOIN listening_session ls ON le.session_id = ls.session_id
GROUP BY g.genre_id, g.name
ORDER BY unique_users DESC
LIMIT 10;

-- 6.3. Žanrų skip rate analizė
SELECT 
    g.genre_id,
    g.name AS genre,
    COUNT(le.event_id) AS total_plays,
    SUM(CASE WHEN le.is_skipped = 1 THEN 1 ELSE 0 END) AS skipped_plays,
    ROUND(SUM(CASE WHEN le.is_skipped = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS genre_skip_rate_percent
FROM genre g
JOIN track_genre tg ON g.genre_id = tg.genre_id
JOIN listening_event le ON tg.track_id = le.track_id
GROUP BY g.genre_id, g.name
ORDER BY genre_skip_rate_percent DESC
LIMIT 10;

---------------------------------------------------------
-- SCENARIJUS 7: Mėgstami kūriniai ir albumai
---------------------------------------------------------

-- 7.1. TOP mėgstamų dainų
SELECT 
    t.track_id,
    t.title,
    a.name AS artist,
    COUNT(DISTINCT ult.user_id) AS likes_count
FROM track t
JOIN track_artist ta ON t.track_id = ta.track_id
JOIN artist a ON ta.artist_id = a.artist_id
JOIN user_liked_track ult ON t.track_id = ult.track_id
GROUP BY t.track_id, t.title, a.name
ORDER BY likes_count DESC;

-- 7.2. TOP mėgstamų albumų
SELECT 
    al.album_id,
    al.title,
    a.name AS artist,
    COUNT(DISTINCT ula.user_id) AS likes_count
FROM album al
JOIN artist a ON al.artist_id = a.artist_id
JOIN user_liked_album ula ON al.album_id = ula.album_id
GROUP BY al.album_id, al.title, a.name
ORDER BY likes_count DESC;

-- 7.3. Lyginimas: klausymai vs mėgstami
SELECT 
    t.track_id,
    t.title,
    COUNT(le.event_id) AS play_count,
    COUNT(DISTINCT ult.user_id) AS like_count,
    ROUND(COUNT(DISTINCT ult.user_id) * 100.0 / COUNT(le.event_id), 2) AS like_rate_percent
FROM track t
JOIN listening_event le ON t.track_id = le.track_id
LEFT JOIN user_liked_track ult ON t.track_id = ult.track_id
GROUP BY t.track_id, t.title
ORDER BY like_rate_percent DESC;

---------------------------------------------------------
-- SCENARIJUS 8: Sekami atlikėjai ir grojaraščiai
---------------------------------------------------------

-- 8.1. Populiariausi sekami atlikėjai
SELECT 
    a.artist_id,
    a.name,
    COUNT(DISTINCT ufa.user_id) AS followers_count
FROM artist a
JOIN user_follow_artist ufa ON a.artist_id = ufa.artist_id
GROUP BY a.artist_id, a.name
ORDER BY followers_count DESC;

-- 8.2. Populiariausi sekami grojaraščiai
SELECT 
    p.playlist_id,
    p.name,
    u.display_name AS owner,
    COUNT(DISTINCT ufp.user_id) AS followers_count
FROM playlist p
JOIN user_account u ON p.owner_user_id = u.user_id
JOIN user_follow_playlist ufp ON p.playlist_id = ufp.playlist_id
WHERE p.is_public = 1
GROUP BY p.playlist_id, p.name, u.display_name
ORDER BY followers_count DESC;

-- 8.3. Vartotojų sekimo elgsena
SELECT 
    u.user_id,
    u.display_name,
    COUNT(DISTINCT ufa.artist_id) AS artists_followed,
    COUNT(DISTINCT ufp.playlist_id) AS playlists_followed
FROM user_account u
LEFT JOIN user_follow_artist ufa ON u.user_id = ufa.user_id
LEFT JOIN user_follow_playlist ufp ON u.user_id = ufp.user_id
GROUP BY u.user_id, u.display_name
ORDER BY artists_followed DESC;

---------------------------------------------------------
-- SCENARIJUS 9: TOP 10 dainų per laikotarpį
---------------------------------------------------------

-- 9.1. TOP 10 dainų per mėnesį
SELECT 
    t.track_id,
    t.title,
    a.name AS artist,
    COUNT(le.event_id) AS play_count
FROM track t
JOIN track_artist ta ON t.track_id = ta.track_id
JOIN artist a ON ta.artist_id = a.artist_id
JOIN listening_event le ON t.track_id = le.track_id
WHERE YEAR(le.started_at) = 2024 AND MONTH(le.started_at) = 4
GROUP BY t.track_id, t.title, a.name
ORDER BY play_count DESC
LIMIT 10;

-- 9.2. TOP atlikėjai per savaitę
SELECT 
    a.artist_id,
    a.name,
    COUNT(le.event_id) AS play_count,
    WEEK(le.started_at, 1) AS week_number
FROM artist a
JOIN track_artist ta ON a.artist_id = ta.artist_id
JOIN listening_event le ON ta.track_id = le.track_id
WHERE YEAR(le.started_at) = 2024
GROUP BY a.artist_id, a.name, WEEK(le.started_at, 1)
ORDER BY WEEK(le.started_at, 1) DESC, play_count DESC
LIMIT 10;

-- 9.3. Žanrų populiarumas per dieną
SELECT 
    DATE(le.started_at) AS date,
    g.name AS genre,
    COUNT(le.event_id) AS play_count
FROM listening_event le
JOIN track_genre tg ON le.track_id = tg.track_id
JOIN genre g ON tg.genre_id = g.genre_id
GROUP BY DATE(le.started_at), g.name
ORDER BY DATE(le.started_at) DESC, play_count DESC
LIMIT 10;

---------------------------------------------------------
-- SCENARIJUS 10: Aktyviausi vartotojai pagal laiką
---------------------------------------------------------

-- 10.1. Vartotojai pagal bendro klausymo trukmę
SELECT 
    u.user_id,
    u.display_name,
    COUNT(DISTINCT le.event_id) AS total_plays,
    ROUND(SUM(le.listened_ms) / 1000.0 / 60.0, 2) AS total_listen_minutes
FROM user_account u
JOIN listening_session ls ON u.user_id = ls.user_id
JOIN listening_event le ON ls.session_id = le.session_id
GROUP BY u.user_id, u.display_name
ORDER BY total_listen_minutes DESC
LIMIT 10;

-- 10.2. Aktyviausios sesijos pagal vartotoją
SELECT 
    u.user_id,
    u.display_name,
    COUNT(DISTINCT ls.session_id) AS total_sessions,
    ROUND(SUM(le.listened_ms) / 1000.0 / 60.0 / COUNT(DISTINCT ls.session_id), 2) AS avg_session_minutes
FROM user_account u
JOIN listening_session ls ON u.user_id = ls.user_id
LEFT JOIN listening_event le ON ls.session_id = le.session_id
GROUP BY u.user_id, u.display_name
ORDER BY total_sessions DESC
LIMIT 10;

-- 10.3. Vartotojų pradžios laiko pasiskirstymas
SELECT 
    u.user_id,
    u.display_name,
    HOUR(ls.start_time) AS start_hour,
    COUNT(ls.session_id) AS session_count
FROM user_account u
JOIN listening_session ls ON u.user_id = ls.user_id
GROUP BY u.user_id, u.display_name, HOUR(ls.start_time)
ORDER BY u.user_id, start_hour;
