--DEO V
--1. 1.Колики удео у укупном броју голова лиге у сезони 2024/25 има сваки клуб? Ко има највећ удео?
--Westmere Town

with golovi_klubova as(
select t.team_name,
sum(case when m.home_team_id = t.team_id then m.home_goals
     else m.away_goals end) as br_golova
from teams t
join matches m on t.team_id = m.home_team_id or t.team_id = m.away_team_id
where m.season = '2024/25'
group by t.team_id, t.team_name
)

select team_name,br_golova,
round(100.0 * br_golova / sum(br_golova) over (), 2) as udeo_pct
from golovi_klubova
order by udeo_pct desc;


--2. Која су три стадиона са највећом просечном посетом у сезони 2024/25
-- Harbourside Park, Kingsbridge Stadium, Northport Arena

with poseta_stadiona as(
select s.stadium_name,
round(avg(m.attendance)) as prosecna_poseta
from matches m
join stadiums s on m.stadium_id = s.stadium_id
where m.season = '2024/25' and m.attendance is not null
group by s.stadium_id, s.stadium_name
),

rang_stadiona as
(
select stadium_name, prosecna_poseta,
rank() over (order by prosecna_poseta desc) as rang
from poseta_stadiona
)

select stadium_name, prosecna_poseta
from rang_stadiona
where rang <= 3
order by rang;

--3. За сваки клуб, ко је дао последњи гол клуба у сезони 2024/25 и када? Који клуб је последњи гол дао најраније?
--Elmsworth Wanderers 3.5.2025.
with golovi as(
select t.team_name, p.first_name, p.last_name, m.kickoff_ts, me.minute, me.added_time,
row_number() over (partition by t.team_id order by m.kickoff_ts desc, me.minute desc, me.added_time desc) as rb
from match_events me
join matches m on me.match_id = m.match_id
join teams t on me.team_id = t.team_id
join players p on me.player_id = p.player_id
where m.season = '2024/25'and me.event_type in ('goal', 'penalty_goal')
)

select team_name, first_name, last_name,kickoff_ts,  minute, added_time
from golovi
where rb = 1
order by kickoff_ts;

--4. За домаће утакмице клуба Northport United у сезони 2024/25 прикажите посету и промену у односу на претходну домаћу утакмицу. Где је највећи пад?

with poseta as (
select m.match_id, m.kickoff_ts,m.attendance,
lag(m.attendance) over (order by m.kickoff_ts) as prethodna_poseta
from matches m
join teams t on m.home_team_id = t.team_id
where t.team_name = 'Northport United' and m.season = '2024/25'
)

select match_id,kickoff_ts, attendance, prethodna_poseta,
attendance - prethodna_poseta as promena_posete
from poseta
order by promena_posete asc;

--5. Пратите бодове клуба Northport City утакмицу по утакмицу у сезони 2024/25. У којој утакмици по реду и ког датума је прешао 50 бодова?
--21. utakmica, 12.1.2025.
with utakmice as(
select m.match_id, m.kickoff_ts,
case when m.home_team_id = t.team_id and m.home_goals > m.away_goals then 3
    when m.away_team_id = t.team_id and m.away_goals > m.home_goals then 3
    when m.home_goals = m.away_goals then 1
    else 0 end as bodovi
from matches m
join teams t on t.team_id = m.home_team_id or t.team_id = m.away_team_id
where t.team_name = 'Northport City'and m.season = '2024/25'
      and m.status = 'played'
),
ukupno_bodova as
(
select match_id,kickoff_ts, bodovi,
sum(bodovi) over (order by kickoff_ts, match_id) as ukupno_bodova,
row_number() over (order by kickoff_ts, match_id) as utakmica_po_redu
from utakmice
)
select utakmica_po_redu,kickoff_ts, bodovi, ukupno_bodova
from ukupno_bodova
where ukupno_bodova > 50
order by utakmica_po_redu
limit 1;
