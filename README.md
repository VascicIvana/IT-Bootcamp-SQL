# IT Bootcamp – SQL Capstone Project

**Autor:** Ivana Vaščić

## Opis projekta

Projekat predstavlja analizu fudbalske lige i učinka izabranog kluba tokom sezone 2024/25, korišćenjem SQL upita.

Analiza obuhvata rezultate utakmica, učinak kod kuće i u gostima, publiku, strelce i asistente, disciplinu, trenere i kvalitet podataka.

## Pretpostavke o podacima

- Analiza se odnosi na sezonu 2024/25.
- U statistiku utakmica uključene su samo utakmice sa statusom `played`.
- Za analizu publike koriste se domaće utakmice izabrаnog kluba.
- Vrednosti koje nedostaju u podacima o poseti tretiraju se kao NULL.
# deo G
Tabela fact_card sadrži jedan red za svaki kartonski događaj (žuti, drugi žuti ili crveni karton). Povezana je sa dimenzionim tabelama preko ključeva: team_id, player_id, referee_id i date_key, dok match_id identifikuje utakmicu. Za igrače koji ne postoje u izvornoj tabeli koristi se player_id = -1.

Kartoni imaju svoju tabelu činjenica zato što omogućavaju analizu i poređenje broja kartona po igraču, klubu, sudiji i datumu. Na ovaj način svaki kartonski događaj predstavlja zasebnu činjenicu koja može jednostavno da se analizira.
