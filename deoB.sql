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
--januar: 51
select month(kickoff_ts) as mesec,
count(*) as br_utakmica,
sum(home_goals + away_goals) as br_golova,
round(avg(home_goals + away_goals), 2) as prosecno_golova
from matches
where season = '2024/25'
group by month(kickoff_ts)
order by mesec;

--3  Публика: просечна посета и попуњеност по стадиону; утакмице без податка о посети и утакмица без публике



SELECT ROUND(AVG(m.attendance)) AS prosek,
       ROUND(AVG(100 * m.attendance / s.capacity), 1) AS popunjenost_pct,
       COUNT(*) - COUNT(m.attendance) AS bez_podatka,
       sum(case when m.attendance = 0 then 1 else 0 end) as bez_publike,
       s.stadium_name
FROM matches m
JOIN teams    t ON m.home_team_id = t.team_id
JOIN stadiums s ON m.stadium_id   = s.stadium_id
WHERE m.season = '2024/25' AND m.status = 'played'
group by s.stadium_id, s.stadium_name, s.capacity; 


--4. Судије: за сваког судију број утакмица и картони по утакмици
--sudije i br utakmica
select r.referee_id, r.referee_name, count(distinct m.match_id) as br_utakmica,
count(case when me.event_type in ('yellow_card', 'second_yellow', 'red_card')
           then 1 end) as br_kartona,
round(1.0 * count(case when me.event_type in ('yellow_card', 'second_yellow', 'red_card')
                     then 1 end) / count(distinct m.match_id), 2
) as kartoni_po_utakmici
from matches m
join match_events me on me.match_id = m.match_id
join referees r on r.referee_id = m.referee_id

group by r.referee_id, r.referee_name;



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


--6.Kvalitet podataka: 
--utakmice bez trenera: Za utakmicu Westmere Towna (1. mart 2025.) nije evidentiran trener. Prethodni trener završio je angažman 27. februara, a novi je počeo 3. marta 2025

select m.match_id, t.team_name, m.kickoff_ts
from matches m
join teams t on t.team_id = m.home_team_id
left join manager_spells ms on ms.team_id = m.home_team_id
   and cast(m.kickoff_ts as date) between ms.start_date
   and coalesce(ms.end_date, date'9999-12-31')
where m.season = '2024/25'and ms.manager_name is null;


select *
from manager_spells ms
join teams t on t.team_id = ms.team_id
where t.team_name = 'Westmere Town'
order by ms.start_date;

---- problem 2: dogadjaji sa nepostojecim igracem

--Pronađena su dva događaja: 1024 i 1634 povezana sa igračem čiji je player_id = 99999 koji ne postoji u tabeli players

select me.event_id, me.match_id,  me.player_id
from match_events me
left join players p on me.player_id = p.player_id
where me.player_id is not null and p.player_id is null;