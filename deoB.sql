--DEO B --izvestaj o sezoni 2024/25

--1.pregled sezone
--br utakmica -380

select count(match_id) as br_utakmica
from matches
where season = '2024/25';

--br golova - 1092

select sum(home_goals + away_goals) as br_goolova
from matches
where season = '2024/25';

--prosecan br golova - 2.87

select avg(home_goals + away_goals) as prosecan_br_golova
from matches
where season = '2024/25';

--udeo pobeda domacina 0.41

 
select 
count(match_id) as br_utakmica,
sum(case 
when (home_goals > away_goals) then 1 end) as pobeda_domacina, 
(pobeda_domacina/br_utakmica) as udeo_pobeda
from matches
where season = '2024/25';

--udeo neresenih utakmica -0.25


select count(match_id) as br_utakmica,
sum(case 
when (home_goals = away_goals) then 1 end) as nereseno, 
(nereseno/br_utakmica) as udeo_neresenih
from matches
where season = '2024/25';


--udeo pobeda gostiju -0.34

select count(match_id) as br_utakmica,
sum(case 
when (home_goals < away_goals) then 1 end) as pobeda_gostiju, 
(pobeda_gostiju/br_utakmica) as udeo_pobeda_gostiju
from matches
where season = '2024/25';


--2. br utakmica po mesecima, br golova po mesecima,prosecan br golova po utakmici usvakom mesecu
-- koji mesec se izdvaja : izdvaja se jul jer nema utakmica
--januar: 52
select count (*)
from matches
where kickoff_ts between '2024-01-01' and '2024-01-31';
--februar:41
select count (*)
from matches
where kickoff_ts between '2024-02-01' and '2024-02-29';

--mart 38
select count (*)
from matches
where kickoff_ts between '2024-03-01' and '2024-03-31';

--april 41

select count (*)
from matches
where kickoff_ts between '2024-04-01' and '2024-04-30';

--maj 20

select count (*)
from matches
where kickoff_ts between '2024-05-01' and '2024-05-31';

--jun  20
select count (*)
from matches
where kickoff_ts between '2024-06-01' and '2024-06-30';

--jul 0

select count (*)
from matches
where kickoff_ts between '2024-07-01' and '2024-07-31';

--avg 20
select count (*)
from matches
where kickoff_ts between '2024-08-01' and '2024-08-31';

--sept 31

select count (*)
from matches
where kickoff_ts between '2024-09-01' and '2024-09-30';

--okt 30
select count (*)
from matches
where kickoff_ts between '2024-10-01' and '2024-10-31';

--nov 29
select count (*)
from matches
where kickoff_ts between '2024-11-01' and '2024-11-30';

--dec 52
select count (*)
from matches
where kickoff_ts between '2024-12-01' and '2024-12-31';


--3  Публика: просечна посета и попуњеност по стадиону; утакмице без податка о посети и утакмица без публике



SELECT ROUND(AVG(m.attendance)) AS prosek,
       ROUND(AVG(100 * m.attendance / s.capacity), 1) AS popunjenost_pct,
       COUNT(*) - COUNT(m.attendance) AS bez_podatka,
       COUNT(attendance = 0)  as bez_publike
FROM matches m
JOIN teams    t ON m.home_team_id = t.team_id
JOIN stadiums s ON m.stadium_id   = s.stadium_id
WHERE m.season = '2024/25' AND m.status = 'played' ;


--4. Судије: за сваког судију број утакмица и картони по утакмици
--sudije i br utakmica
select r.referee_id, r.referee_name, count(m.match_id) as br_utakmica 
from matches m
join match_events me on me.match_id = m.match_id
join referees r on r.referee_id = m.referee_id

group by r.referee_id, r.referee_name;

--br kartona po utakmici 
SELECT match_id, sum(me.yellow_card + second_yellow + red_card) as br_kartona
from matches m
join match_events me on me.match_id = m.match_id


--5. Играчи: пет најбољих стрелаца и пет најбољих асистената.
--igraci
SELECT p.first_name, p.last_name, COUNT(*) AS golovi
FROM match_events e
JOIN matches m ON e.match_id  = m.match_id
JOIN players p ON e.player_id = p.player_id
JOIN teams   t ON e.team_id   = t.team_id
WHERE m.season = '2024/25' AND e.event_type IN ('goal', 'penalty_goal') 
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY golovi DESC
LIMIT 5;

--asistenti

SELECT p.first_name, p.last_name, COUNT(*) AS asistencije
FROM match_events e
JOIN matches m ON e.match_id  = m.match_id
JOIN players p ON e.related_player_id = p.player_id
JOIN teams   t ON e.team_id   = t.team_id
WHERE m.season = '2024/25' AND e.event_type IN ('goal', 'penalty_goal') 
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY asistencije DESC
LIMIT 5;

