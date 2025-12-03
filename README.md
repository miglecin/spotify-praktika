# Spotify DB – Praktikos darbas

Šitas projektas yra Spotify tipo duomenų bazė MySQL'e.

Struktūra:

```
spotify-praktika/
├─ sql/
│  ├─ schema.sql      # DB schema (CREATE TABLE)
│  ├─ seed_data.sql   # Sėkliniai duomenys (INSERT) – prireikus
│  └─ queries.sql     # Analitinės užklausos ir scenarijai
└─ README.md
```

Greitas startas:
- Sukurkite schemą: paleiskite `sql/schema.sql` MySQL'e.
- (nebūtina) Įkelkite sėklinius duomenis: `sql/seed_data.sql`.
- Analizei: vykdykite užklausas iš `sql/queries.sql`.
