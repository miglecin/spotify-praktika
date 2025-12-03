# Spotify DB – Praktikos darbas

Šitas projektas yra **Spotify tipo duomenų bazė** MySQL'e.
Jame yra:
- vartotojai, prenumeratos planai;
- atlikėjai, albumai, dainos;
- žanrai;
- grotaraščiai;
- klausymo sesijos ir klausymo istorija;
- „like“ ir „follow“ funkcionalumas.

## Struktūra

```text
spotify-db-praktika/
├─ sql/
│  ├─ schema.sql      # DB schema (CREATE TABLE)
│  ├─ seed_data.sql   # Testiniai duomenys (INSERT)
│  └─ queries.sql     # Analitinės užklausos ir scenarijai
└─ README.md
