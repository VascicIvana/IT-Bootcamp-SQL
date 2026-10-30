--DEO A
--zadatak 1: koliko utakmica je odigrano u februaru 2025
--odigrano je 40 utakmica u februaru 2025

select count(*) as broj_utakmica
from matches
where kickoff_ts >= '2025-02-01' AND kickoff_ts < '2025-03-01';

--zadatak 2: koji stadion ima najveci kapacictet, a koji je najveci stadion nekog kluba
--najveci kapacitet ima National Stadium
--najveci stadion nekog kluba je Harbourside Park, a tim je Northport United

select capacity, stadium_name
from stadiums
order by capacity desc
limit 1;


select s.stadium_name, s.capacity, s.stadium_id, t.team_name, t.team_id
from stadiums s
join teams t on t.stadium_id = s.stadium_id
order by s.capacity desc;


--zadatak 3: Koliko igraca u ligi ima srpsko drzavljanstvo (nationality = 'Serbia')
-- 42
select count(*) as broj_igraca
from players
where nationality = 'Serbia';

--zadatak 4: koliko utakmica je zavrseno rezultatom 1:1
--94
select count(*)
from matches
where home_goals = 1 and away_goals = 1;

--provera
select home_goals, away_goals
from matches
where home_goals = 1 and away_goals = 1;

--zadatak 5: Kolika je prosecna poseta po sezoni

--prosecna poseta za sezonu 2023/24 je 24253, a za sezonu 2024/25 je 24199

select round(AVG(attendance)), season 
from matches
group by season;

--zadatak 6: koliko golova je dato iz penala po sezoni
--u sezoni 2023/24 dato je 104 gola iz penala
--u sezoni 2024/25 dato je 109 iz penala

select season, event_type
from match_events me
join matches m on m.match_id = me.match_id
where season = '2023/24' and event_type = 'penalty_goal';

select season, event_type
from match_events me
join matches m on m.match_id = me.match_id
where season = '2024/25' and event_type = 'penalty_goal';


--zadatak 7: koliko razlicitih igraca je dalo bar jedan gol u sezoni 2024/25
--377 igraca ako racunamo i strelce penala, bez penala 299

--bez penala :
select distinct player_id,season,event_type
from match_events me
join matches m on m.match_id = me.match_id
where m.season = '2024/25' and me.event_type = 'goal';

--sa penalima:
select distinct player_id,season,event_type
from match_events me
join matches m on m.match_id = me.match_id
where m.season = '2024/25' and (me.event_type = 'goal' or me.event_type ='penalty_goal');


--zadatak 8: koji sudija je najvise puta sudio utakmice kluba Northport United

--najvise puta je sudio Mark Halsey-Brown, pet puta

select r.referee_name, count(*) as br_utakmica
from referees r
join matches m on m.referee_id = r.referee_id
join teams t on t.team_id = m.home_team_id
where team_name = 'Northport United'
group by r.referee_name
order by br_utakmica desc;


--zadatak 9: koji sudija je u sezoni 2024/25 imao najveci udeo utakmica u kojima je dosudjen bar jedan penal dat ili promasen
--u sezoni 2024/25 najveci udeo utakmica u kojima je dosudjen bar jedan penal imao je Peter Lindgren
with penali as
(
    select r.referee_name, count(*) as dosudjeni_penali
from referees r
join matches m on m.referee_id = r.referee_id
join match_events me on me.match_id = m.match_id
where m.season = '2024/25'
     and (event_type = 'penalty_goal' 
     or event_type = 'penalty_miss')
group by r.referee_name  
),
 mecevi as (select r.referee_name, count(*) as utakmice
from referees r
join matches m on m.referee_id = r.referee_id
join match_events me on me.match_id = m.match_id
where m.season = '2024/25'
     group by r.referee_name)   

select p.referee_name, (p.dosudjeni_penali/m.utakmice) as udeo_utakmica
from penali p ,mecevi m  
order by udeo_utakmica desc;

--zadatak 10: koji trener je osvojio najvise bodova u utakmicama u kojima je njegov tim gubio na poluvremenu. racunaj i domace i gostujuce utakmice
 

 with poluvreme_domacini as
 (
    select ms.manageer_name, t.team_name
    from manager_spells ms
join matches m on m.home_team_id = ms.team_id
join teams t on t.team_id = m.home_team_id
 )



