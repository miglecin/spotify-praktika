# Spotify DB – Praktikos darbas

Šis projektas sukurtas kaip **Praktikos darbas (DBS / DB projektavimas)**, modeliuojantis realios platformos — **Spotify** — duomenų bazę.  
Projekte yra sukurta **relaicinė duomenų bazė**, **SQL schema**, **testiniai duomenys**, **užklausų scenarijai**, bei **projekto dokumentacija**.

Struktūra:

```
spotify-praktika/
├─ sql/
│  ├─ schema.sql      # DB schema (CREATE TABLE)
│  ├─ seed_data.sql   # Testiniai duomenys (INSERT) 
│  └─ queries.sql     # Analitinės užklausos ir scenarijai
└─ README.md
```
---
## Praktikos darbo tikslas

Praktikos darbo tikslas – **sukurti muzikinės platformos „Spotify“ duomenų bazės modelį**, leidžiantį atlikti verslo logikos analizes bei įvertinti vartotojų elgseną platformoje.

#### Darbo uždaviniai:

    1. Sukurti Spotify platformos duomenų bazę, apimančią vartotojus, muzikos kūrinius, atlikėjus, grojaraščius ir klausymo istoriją.
    2. Sugeneruoti testinius duomenis, kurie atspindėtų realius muzikos klausymo scenarijus.
    3. Sukurti SQL užklausas, leidžiančias atlikti šias analizes:
        - populiariausių dainų identifikavimą,
        - atlikėjų populiarumo nustatymą,
        - vartotojo grojaraščių analizę,
        - dainų praleidimo (skip) procento skaičiavimą,
        - klausymo įpročių analizę pagal įrenginį,
        - žanrų populiarumo analizę,
        - vartotojų mėgstamų kūrinių ir albumų analizę,
        - sekamų atlikėjų ir grojaraščių analizę,
        - TOP 10 dainų tam tikru laikotarpiu sudarymą,
        - aktyviausių vartotojų nustatymą pagal klausymo laiką.
    4. Aprašyti gautus rezultatus, pateikti scenarijų lenteles, analizės išvadas ir pademonstruoti duomenų bazės veikimo logiką.

Galutinis tikslas – sukurti **funkcionalų, aiškų ir lengvai analizuojamą duomenų bazės sprendimą**, simuliuojantį realią muzikinės platformos veiklą ir leidžiantį atlikti įvairaus sudėtingumo analitines užklausas.

---

## Naudojamų duomenų aprašymas

Šiame praktikos darbe naudojami duomenys yra sukurti remiantis muzikos platformos **Spotify** veikimo principais. Duomenų bazėje modeliuojami pagrindiniai realios sistemos komponentai: vartotojai, prenumeratos, atlikėjai, albumai, dainos, grojaraščiai, žanrai bei klausymo istorija.

Duomenų šaltinis – mūsų sukurta **testinė duomenų bazė**, paremta realios sistemos logika. Visi duomenys yra generuoti dirbtinai, atsižvelgiant į Spotify veikimo scenarijus:

- **Vartotojų duomenys** – vardas, el. paštas, šalis, gimimo data, lytis, paskyros sukūrimo laikas.
- **Prenumeratos** – planų tipai, vartotojų prenumeravimo istorija, prenumeratos periodai.
- **Atlikėjai ir albumai** – atlikėjų sąrašas ir jų leidžiami albumai (1 atlikėjas → N albumų).
- **Dainos (kūriniai)** – trukmė, numeracija albume, „explicit“ žyma.
- **Muzikos žanrai** – žanrų sąrašas ir jų priskyrimas kūriniams (N:N ryšys).
- **Grojaraščiai** – vartotojų sukurti arba vieši playlistai, dainų pozicijos juose.
- **Klausymo sesijos** – naudojamas įrenginys, programos versija, pradžios/pabaigos laikas.
- **Klausymo įvykiai** – konkretaus kūrinio klausymas sesijos metu, trukmė, ar daina praleista.
- **Vartotojų sąveikos** – mėgstami kūriniai, mėgstami albumai, sekami atlikėjai ir grojaraščiai.

Duomenų bazė sukurta taip, kad būtų galima atlikti tiek **analitines**, tiek **funkcines** užklausas. Lentelėse duomenys sujungti naudojant **1:N** ir **N:N** ryšius, leidžiančius modeliuoti realų Spotify sistemos veikimą ir vykdyti detalesnę elgsenos analizę.

---
Greitas startas:
- Sukurkite schemą: paleiskite `sql/schema.sql` MySQL'e.
- Įkelkite testinius duomenis: `sql/seed_data.sql`.
- Analizei: vykdykite užklausas iš `sql/queries.sql`.

---
##  Scenarijai (Queries)

Toliau pateikiami pavyzdiniai verslo scenarijai ir SQL užklausų kryptys, kurios realizuojamos faile **`sql/queries.sql`**.

| #  | Scenarijus                             | Verslo klausimas / tikslas                                                                 | Pagrindinės lentelės                                      | Pavyzdinė užklausos idėja (trumpai)                                                                 |
|----|----------------------------------------|--------------------------------------------------------------------------------------------|-----------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| 1  | Populiariausios dainos                 | Kurios dainos yra dažniausiai klausomos platformoje?                                       | `track`, `listening_event`                               | Grupavimas pagal `track_id`, `COUNT(event_id)`, rikiavimas DESC, `LIMIT 10`.                         |
| 2  | Atlikėjų populiarumas                  | Kurie atlikėjai yra populiariausi pagal klausymus ir „patinka“?                            | `artist`, `track_artist`, `listening_event`, `user_liked_track` | JOIN tarp `artist` → `track_artist` → `listening_event`, agregavimas pagal atlikėją.                |
| 3  | Grotaraščiai pagal vartotoją           | Kokius grojaraščius susikūrė konkretus vartotojas ir kiek dainų juose yra?                | `playlist`, `playlist_track`, `user_account`              | Filtruoti pagal `owner_user_id`, `COUNT(track_id)` per grojaraštį.                                   |
| 4  | Skip rate (% praleistų dainų)          | Kokia dainų praleidimo (skip) dalis ir kurios dainos dažniausiai praleidžiamos?           | `listening_event`, `track`                               | Skaičiuoti `SUM(is_skipped)` ir `COUNT(*)`, išvesti `skip_percentage = skipped / total * 100`.      |
| 5  | Klausymo įpročiai pagal įrenginį       | Kokie įrenginiai (mobile, desktop, web) dažniausiai naudojami klausymui?                   | `listening_session`, `listening_event`                    | Grupavimas pagal `device_type`, `COUNT(event_id)` ir/arba `SUM(listened_ms)`.                        |
| 6  | Dažniausiai klausomi žanrai            | Kurių muzikos žanrų daugiausiai klausoma?                                                   | `genre`, `track_genre`, `listening_event`                 | JOIN `genre` → `track_genre` → `listening_event`, `COUNT(event_id)` per žanrą.                       |
| 7  | Mėgstami kūriniai ir albumai           | Kuriuos kūrinius ir albumus vartotojai dažniausiai pažymi kaip „patinka“?                  | `user_liked_track`, `user_liked_album`, `track`, `album`  | Grupavimas pagal `track_id` / `album_id`, `COUNT(user_id)` ir rikiavimas nuo populiariausių.         |
| 8  | Sekami atlikėjai ir grojaraščiai       | Kokius atlikėjus ir grojaraščius vartotojai seka dažniausiai?                              | `user_follow_artist`, `user_follow_playlist`, `artist`, `playlist` | `COUNT(user_id)` per atlikėją / grojaraštį, rikiavimas DESC.                                        |
| 9  | Top 10 dainų per laikotarpį            | Kokios TOP 10 dainų per pasirinktą laikotarpį (pvz., mėnesį)?                              | `listening_event`, `track`                               | `WHERE started_at BETWEEN ... AND ...`, grupavimas pagal `track_id`, `COUNT(*)`, `LIMIT 10`.        |
| 10 | Aktyviausi vartotojai pagal laiką      | Kurie vartotojai daugiausiai klausosi muzikos (pagal klausymo laiką ar įvykių skaičių)?    | `user_account`, `listening_session`, `listening_event`    | Grupavimas pagal `user_id`, `SUM(listened_ms)` ir/arba `COUNT(event_id)`, rikiavimas nuo didžiausio. |

---
