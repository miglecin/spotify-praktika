# Spotify Duomenų Bazės Dokumentacija

## 1. Duomenų Bazės Apžvalga

Šis projektas sukūrė **Spotify** tipo muzikos grotuvo duomenų bazę su 17 lentelėmis. Duomenų bazė saugoma **MySQL** DBVS ir skirta analizuoti:
- Vartotojų klausymo elgseną
- Populiariausias dainas ir atlikėjus
- Skip rate analizę
- Vartotojų prenumeratos informaciją
- Grojaraščių ir sekų valdymą

---

## 2. ER Diagrama (Grafinė Reprezentacija)

```
================================================================================
                   SPOTIFY DUOMENŲ BAZĖ - ER DIAGRAMA
================================================================================

                          ┌──────────────────┐
                          │ subscription_plan│
                          │ ─────────────────│
                          │ plan_id (PK)     │
                          │ plan_name        │
                          │ price            │
                          │ features         │
                          └────────┬─────────┘
                                   │ 1:N
                                   │
                    ┌──────────────▼──────────────┐
                    │  user_subscription         │
                    │  ──────────────────────────│
                    │  user_id (FK, PK)          │
                    │  plan_id (FK, PK)          │
                    │  subscription_date         │
                    └──────────────┬──────────────┘
                                   │
                ┌──────────────────┴──────────────────┐
                │                                     │
                │ 1:N                                 │ N:1
                │                                     │
    ┌───────────▼──────────────┐      ┌──────────────▼──────────┐
    │   user_account           │      │ playlist               │
    │   ──────────────────────│      │ ─────────────────────│
    │   user_id (PK)          │      │ playlist_id (PK)    │
    │   email                 │      │ owner_user_id (FK)  │
    │   display_name          │      │ name                │
    │   created_at            │      │ is_public           │
    └────┬──────┬────┬────┬───┘      │ created_at          │
         │      │    │    │           └──────────┬─────────┘
         │      │    │    │                      │ 1:N
         │      │    │    │                      │
         │      │    │    │           ┌──────────▼────────────┐
         │      │    │    │           │  playlist_track      │
         │      │    │    │           │  ────────────────────│
         │      │    │    │           │  playlist_id (FK,PK) │
         │      │    │    │           │  track_id (FK, PK)   │
         │      │    │    │           └──────────┬───────────┘
         │      │    │    │                      │ N:1
         │      │    │    │                      │
    ┌────▼──────┴──┬─┴────┴─────────────────────┘
    │             │
1:N │             │ 1:N
    │             │
┌───▼──────────┐  │  ┌─────────────────────────┐
│listening_    │  │  │  user_liked_track       │
│session       │  │  │  ──────────────────────│
│─────────────│  │  │  user_id (FK, PK)      │
│session_id   │  │  │  track_id (FK, PK)     │
│user_id (FK)─┼──┘  │  liked_at               │
│device_type  │     └─────────────────────────┘
│start_time   │
│end_time     │     ┌─────────────────────────┐
└───┬─────────┘     │  user_liked_album       │
    │               │  ──────────────────────│
    │ 1:N           │  user_id (FK, PK)      │
    │               │  album_id (FK, PK)     │
    │               │  liked_at               │
    │               └─────────────────────────┘
    │
    │               ┌────────────────────────┐
    │               │ user_follow_artist     │
    │               │ ──────────────────────│
    │               │ user_id (FK, PK)      │
    │               │ artist_id (FK, PK)    │
    │               │ followed_at            │
    │               └────────────────────────┘
    │
    │               ┌────────────────────────┐
    │               │ user_follow_playlist   │
    │               │ ──────────────────────│
    │               │ user_id (FK, PK)      │
    │               │ playlist_id (FK, PK)  │
    │               │ followed_at            │
    │               └────────────────────────┘
    │
    ├─────────────────────────────────┐
    │                                 │
    │ 1:N                         1:N │
    │                                 │
┌───▼─────────────────┐      ┌───────▼──────────┐
│ listening_event     │      │ track            │
│ ────────────────────│      │ ────────────────│
│ event_id (PK)       │      │ track_id (PK)   │
│ session_id (FK) ───┤      │ album_id (FK)   │
│ track_id (FK) ──────┼─────→ title            │
│ started_at          │      │ duration_seconds│
│ listened_ms         │      └───┬───────┬──────┘
│ is_skipped          │          │ 1:N   │ 1:N
│ source_type         │          │       │
└─────────────────────┘          │       │
                            ┌────▼───┐  │
                            │ artist  │  │
                            │ ───────│  │
                            │artist_ │  │
                            │id (PK) │  │
                            │ name   │  │
                            │ bio    │  │
                            │created_│  │
                            │at      │  │
                            └────┬───┘  │
                                 │      │
                           ┌─────▼─┐   │
                           │track_ │   │
                           │artist │   │
                           │───────│   │
                           │track_ │   │
                           │id(FK) │   │
                           │artist_│   │
                           │id(FK) │   │
                           └───────┘   │
                                       │
                                  ┌────▼──────┐
                                  │ album     │
                                  │ ─────────│
                                  │ album_id │
                                  │ artist_id│
                                  │ title    │
                                  │ release_ │
                                  │ date     │
                                  └────┬─────┘
                                       │
                                  ┌────▼────────┐
                                  │ track_genre │
                                  │ ────────────│
                                  │ track_id(FK)│
                                  │ genre_id(FK)│
                                  └────┬────────┘
                                       │
                                  ┌────▼──────┐
                                  │ genre     │
                                  │ ─────────│
                                  │ genre_id │
                                  │ name     │
                                  └──────────┘
```
---

## 3. Lentelių Aprašymas

### **Pagrindinės lentelės**

#### 1. `subscription_plan`
Prenumeratos planai. Nusako skirtingus pasiūlymus.
- `plan_id` (PK)
- `plan_name` (Free, Premium, Pro)
- `price`
- `features`

#### 2. `user_account`
Vartotojų sąskaitos. Kiekvienas vartotojas turi unikalią sąskaitą.
- `user_id` (PK)
- `email` (UNIQUE)
- `display_name`
- `created_at` (TIMESTAMP)

#### 3. `user_subscription`
Ryšys tarp vartotojo ir prenumeratos plano (1:N).
- `user_id` (FK, PK)
- `plan_id` (FK)
- `subscription_date`

---

### **Muzikos metaduomenys**

#### 4. `artist`
Atlikėjai (dainininkai, grupės).
- `artist_id` (PK)
- `name`
- `bio` (biologija/aprašymas)
- `created_at`

#### 5. `album`
Albumai. Kiekvienas albumas turi vieną pagrindinį atlikėją.
- `album_id` (PK)
- `artist_id` (FK) – pagrindinė atlikėjas
- `title`
- `release_date`

#### 6. `track`
Dainos. Kiekviena daina priklauso albumui.
- `track_id` (PK)
- `album_id` (FK)
- `title`
- `duration_seconds` – trukmė sekundėmis

#### 7. `genre`
Muzikos žanrai (Rock, Pop, Jazz, etc.).
- `genre_id` (PK)
- `name`

---

### **Tarpinės lentelės (N:M ryšiai)**

#### 8. `track_artist`
Jungia dainą su atlikėjais (viena daina gali turėti kelis atlikėjus).
- `track_id` (FK, PK)
- `artist_id` (FK, PK)

#### 9. `track_genre`
Jungia dainą su žanrais (viena daina gali priklausyti keliems žanrams).
- `track_id` (FK, PK)
- `genre_id` (FK, PK)

---

### **Grojaraščiai**

#### 10. `playlist`
Grojaraščiai. Sukuriami vartotojų.
- `playlist_id` (PK)
- `owner_user_id` (FK) – grojaraščio savininkas
- `name`
- `is_public` (BOOLEAN)
- `created_at`

#### 11. `playlist_track`
Jungia grojaraštį su dainomis (N:M).
- `playlist_id` (FK, PK)
- `track_id` (FK, PK)

---

### **Klausymo duomenys**

#### 12. `listening_session`
Klausymo sesija. Prasideda naudotojui atidarius programą.
- `session_id` (PK)
- `user_id` (FK)
- `device_type` (mobile, desktop, web, tv, other)
- `start_time`
- `end_time`

#### 13. `listening_event`
Klausymo įvykis. Kiekvienas klausymas vienos dainos = 1 event.
- `event_id` (PK)
- `session_id` (FK) – kurio sesija
- `track_id` (FK) – kuri daina
- `started_at` (TIMESTAMP)
- `listened_ms` – kiek milisekundžių buvo klausyta
- `is_skipped` (BOOLEAN) – ar buvo praleista
- `source_type` (playlist, album, search, radio, other)

---

### **Vartotojų mėgimo sistema**

#### 14. `user_liked_track`
Vartotojo mėgstamos dainos (N:M).
- `user_id` (FK, PK)
- `track_id` (FK, PK)
- `liked_at` (TIMESTAMP)

#### 15. `user_liked_album`
Vartotojo mėgstami albumai (N:M).
- `user_id` (FK, PK)
- `album_id` (FK, PK)
- `liked_at` (TIMESTAMP)

---

### **Sekimo sistema**

#### 16. `user_follow_artist`
Vartotojas seka atlikėjus (N:M).
- `user_id` (FK, PK)
- `artist_id` (FK, PK)
- `followed_at` (TIMESTAMP)

#### 17. `user_follow_playlist`
Vartotojas seka grojaraščius (N:M).
- `user_id` (FK, PK)
- `playlist_id` (FK, PK)
- `followed_at` (TIMESTAMP)

---

## 4. Pagrindinės Sąsajos

```
user_account
    ├─→ user_subscription (1:N) → subscription_plan
    ├─→ listening_session (1:N) → listening_event (1:N) → track
    ├─→ user_liked_track (N:M)
    ├─→ user_liked_album (N:M)
    ├─→ user_follow_artist (N:M)
    ├─→ user_follow_playlist (N:M)
    └─→ playlist (1:N) – kaip savininkas

track
    ├─→ track_artist (1:N) → artist
    ├─→ track_genre (1:N) → genre
    ├─→ album (N:1) → artist
    └─→ playlist_track (1:N) → playlist
```

---

## 5. Duomenų Modelis

### **Lentelės dydžiai (seed data)**
- 15 vartotojų
- 10 atlikėjų
- 10 albumų
- 20 dainų
- 5 žanrai
- 50 klausymo sesijų
- 400 klausymo įvykių
- 2 grojaraščiai

### **ENUM Ribojimas**
- `listening_session.device_type`: mobile, desktop, web, tv, other
- `listening_event.source_type`: playlist, album, search, radio, other

---

## 5. Užklausos (30 analitinių)

### **10 scenarijai, po 3 užklausas kiekvienam:**

1. **Populiariausios dainos**
2. **Atlikėjų populiarumas**
3. **Grojaraščiai pagal vartotoją**
4. **Skip rate analizė**
5. **Klausymo įpročiai pagal įrenginį**
6. **Dažniausiai klausomi žanrai**
7. **Mėgstamų kūrinių analiza**
8. **Sekami atlikėjai ir grojaraščiai**
9. **TOP 10 per laikotarpį**
10. **Aktyviausi vartotojai pagal laiką**

Visos užklausos sugrąžina rezultatus su **eilutės numeriu** (`row_no`) pirmagrame stulpelyje.

---

## 6. Failų Struktūra

```
spotify-praktika/
├── README.md                    # Projekto aprašymas
├── DATABASE_SCHEMA.md           # Šis failas
├── ER_DIAGRAM.txt              # ER diagrama (ASCII art)
├── sql/
│   ├── schema.sql              # Lentelių kūrimas (DDL)
│   ├── seed_data.sql           # Duomenys (DML)
│   └── queries.sql             # 30 analitinių užklausų
└── ...
```

---

## 7. Naudojimas

### **1. Sukurti duomenų bazę:**
```sql
source sql/schema.sql;
```

### **2. Įkelti seed duomenis:**
```sql
source sql/seed_data.sql;
```

### **3. Vykdyti analitines užklausas:**
```sql
source sql/queries.sql;
```

### **4. MySQL Workbench:**
- File → Open SQL Script
- Pasirinkti failą (schema.sql, seed_data.sql, queries.sql)
- Execute (⚡)

---

- **DBVS**: MySQL 8.0+
- **SQL Dialektas**: MySQL
- **GUI**: MySQL Workbench 8.0
- **Valdymas**: Git/GitHub

---

- ER diagrama: `ER_DIAGRAM.txt`
- Schema: `sql/schema.sql`
- Duomenys: `sql/seed_data.sql`
- Užklausos: `sql/queries.sql`
