--DEO G

--1.
create or replace table bootcamp.northern_star.dim_team as
select *
from bootcamp.northern_star.teams;
create or replace table bootcamp.northern_star.dim_player as
select *
from bootcamp.northern_star.players;
insert into bootcamp.northern_star.dim_player
values (-1, 'unknown', 'unknown', 'unknown', null, 'unknown', 'unknown', 'unknown', null);
create or replace table bootcamp.northern_star.dim_referee as
select *
from bootcamp.northern_star.referees;
create or replace table bootcamp.northern_star.dim_date as
select cast(date_format(d, 'yyyyMMdd') as int) as date_key,
       d as full_date,
       date_format(d, 'EEEE') as weekday_name,
       dayofweek(d) in (1, 7) as is_weekend,
       case
           when month(d) >= 7 then concat(year(d), '/', substring(cast(year(d) + 1 as string), 3, 2))
           else concat(year(d) - 1, '/', substring(cast(year(d) as string), 3, 2))
       end as season
from (
    select explode(sequence(
        date'2023-07-01',
        date'2025-06-30',
        interval 1 day
    )) as d
);

create or replace table bootcamp.northern_star.fact_card as
select  me.event_id, me.match_id,
cast(date_format(m.kickoff_ts, 'yyyyMMdd') as int) as date_key,
me.team_id,
case when p.player_id is null then -1
     else me.player_id end as player_id,
coalesce(m.referee_id, -1) as referee_id,
me.event_type as card_type
from bootcamp.northern_star.match_events me
join bootcamp.northern_star.matches m on me.match_id = m.match_id
left join bootcamp.northern_star.players p on me.player_id = p.player_id
where me.event_type in ('yellow_card', 'second_yellow', 'red_card');


--2.

select (
select count(*)
from bootcamp.northern_star.match_events
where event_type in ('yellow_card', 'second_yellow', 'red_card')
) as broj_kartonskih_dogadjaja,

(select count(*)
from bootcamp.northern_star.fact_card
    ) as broj_redova_fact_card;


--3.
select count(*) as broj_kartona_nepoznatih_igraca
from bootcamp.northern_star.fact_card
where player_id = -1;
