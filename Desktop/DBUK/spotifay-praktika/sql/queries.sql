-- queries.sql
USE spotify_db;

---------------------------------------------------------
-- SCENARIJUS 1: Populiariausios dainos pagal klausymų skaičių
---------------------------------------------------------

-- 1.1. Top 5 dažniausiai klausomos dainos
SELECT t.track_id, t.title, COUNT(e.event_id) AS play_count
FROM track t
JOIN listening_event e ON t.track_id = e.track_id
GROUP BY t.track_id, t.title
ORDER BY play_count DESC
LIMIT 5;

-- 1.2. Top dainos pagal pilnai išklausytų (nėra skip) skaičių
SELECT t.track_id, t.title, COUNT(*) AS full_plays
FROM track t
JOIN listening_event e ON t.track_id = e.track_id
WHERE e.is_skipped = 0
GROUP BY t.track_id, t.title
ORDER BY full_plays DESC;

-- 1.3. Dainų vidutinis „klausymo procentas“ (kiek % dainos išklausoma)
SELECT 
    t.track_id,
    t.title,
    AVG(LEAST(e.listened_ms / (t.duration_seconds * 1000.0), 1)) AS avg_listen_ratio
FROM track t
JOIN listening_event e ON t.track_id = e.track_id
GROUP BY t.track_id, t.title
ORDER BY avg_listen_ratio DESC;

---------------------------------------------------------
-- SCENARIJUS 2: Atlikėjų populiarumas
---------------------------------------------------------

-- 2.1. Atlikėjų TOP pagal visų jų dainų klausymų skaičių
SELECT a.artist_id, a.name, COUNT(e.event_id) AS total_plays
FROM artist a
JOIN track_artist ta ON a.artist_id = ta.artist_id
JOIN listening_event e ON ta.track_id = e.track_id
GROUP BY a.artist_id, a.name
ORDER BY total_plays DESC;

-- 2.2. Kiek kiekvienas atlikėjas turi mėgstamų track’ų (user_liked_track)
SELECT a.artist_id, a.name, COUNT(DISTINCT lt.user_id) AS unique_likers
FROM artist a
JOIN track_artist ta ON a.artist_id = ta.artist_id
JOIN user_liked_track lt ON ta.track_id = lt.track_id
GROUP BY a.artist_id, a.name
ORDER BY unique_likers DESC;

-- 2.3. Kurių atlikėjų albumai turi daugiausiai „like“ (user_liked_album)
SELECT a.artist_id, a.name, COUNT(ula.user_id) AS album_likes
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN user_liked_album ula ON al.album_id = ula.album_id
GROUP BY a.artist_id, a.name
ORDER BY album_likes DESC;

---------------------------------------------------------
-- SCENARIJUS 3: Žanrų analizė
---------------------------------------------------------

-- 3.1. Klausymų skaičius pagal žanrą
SELECT g.name AS genre, COUNT(e.event_id) AS play_count
FROM genre g
JOIN track_genre tg ON g.genre_id = tg.genre_id
JOIN listening_event e ON tg.track_id = e.track_id
GROUP BY g.name
ORDER BY play_count DESC;

-- 3.2. Kiek skirtingų vartotojų klausė kiekvieno žanro
SELECT g.name AS genre, COUNT(DISTINCT s.user_id) AS unique_users
FROM genre g
JOIN track_genre tg ON g.genre_id = tg.genre_id
JOIN listening_event e ON tg.track_id = e.track_id
JOIN listening_session s ON e.session_id = s.session_id
GROUP BY g.name
ORDER BY unique_users DESC;

-- 3.3. Kiekvieno žanro mėgstamų track’ų kiekis
SELECT g.name AS genre, COUNT(*) AS liked_tracks_count
FROM genre g
JOIN track_genre tg ON g.genre_id = tg.genre_id
JOIN user_liked_track lt ON tg.track_id = lt.track_id
GROUP BY g.name
ORDER BY liked_tracks_count DESC;

---------------------------------------------------------
-- SCENARIJUS 4: Prenumeratos ir vartotojų elgsena
---------------------------------------------------------

-- 4.1. Kiek vartotojų turi kiekvieną planą
SELECT p.name AS plan_name, COUNT(us.user_id) AS user_count
FROM subscription_plan p
LEFT JOIN user_subscription us ON p.plan_id = us.plan_id AND us.status = 'active'
GROUP BY p.name;

-- 4.2. Vidutinis klausymų skaičius per vartotoją pagal planą
SELECT 
    p.name AS plan_name,
    AVG(user_play_count.play_count) AS avg_plays_per_user
FROM subscription_plan p
JOIN user_subscription us ON p.plan_id = us.plan_id AND us.status = 'active'
JOIN (
    SELECT s.user_id, COUNT(e.event_id) AS play_count
    FROM listening_session s
    JOIN listening_event e ON s.session_id = e.session_id
    GROUP BY s.user_id
) AS user_play_count ON user_play_count.user_id = us.user_id
GROUP BY p.name;

-- 4.3. Kuri šalis (country) sugeneruoja daugiausiai klausymų
SELECT u.country, COUNT(e.event_id) AS play_count
FROM user_account u
JOIN listening_session s ON u.user_id = s.user_id
JOIN listening_event e ON s.session_id = e.session_id
GROUP BY u.country
ORDER BY play_count DESC;

---------------------------------------------------------
-- SCENARIJUS 5: Grotaraščių analizė
---------------------------------------------------------

-- 5.1. Kuris grotaraštis turi daugiausiai dainų
SELECT p.playlist_id, p.name, COUNT(pt.track_id) AS track_count
FROM playlist p
LEFT JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_id, p.name
ORDER BY track_count DESC;

-- 5.2. Kuris grotaraštis sugeneravo daugiausiai klausymų
SELECT p.playlist_id, p.name, COUNT(e.event_id) AS play_count
FROM playlist p
JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
JOIN listening_event e ON pt.track_id = e.track_id
GROUP BY p.playlist_id, p.name
ORDER BY play_count DESC;

-- 5.3. Kiek sekėjų (followers) turi kiekvienas public grotaraštis
SELECT p.playlist_id, p.name, COUNT(f.user_id) AS followers
FROM playlist p
LEFT JOIN user_follow_playlist f ON p.playlist_id = f.playlist_id
WHERE p.is_public = 1
GROUP BY p.playlist_id, p.name
ORDER BY followers DESC;
