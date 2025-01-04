--select  * from player_seasons ps ;
--create type season_stats as (
--	season INTEGER,
--	gp INTEGER,
--	pts real,
--	reb real, 
--	ast real
--)
--
--create table players(
--	player_name text,
--	height text,
--	college text,
--	draft_year text,
--	draft_round text,
--	draft_number text,
--	scoring_class scoring_class,
--	years_since_last_active Integer,
--	is_active boolean,
--	season_stats season_stats[],
--	current_season integer,
--	primary key(player_name,current_season)
--)

--create type scoring_class as enum ('bad','average','good','star');


--insert into players (
--    player_name, height, college, draft_year, draft_round, draft_number, season_stats, scoring_class, years_since_last_active, is_active, current_season
--)
--with yesterday as (
--    select * from players 
--    where current_season = 2005
--),
--today as (
--    select * from player_seasons 
--    where season = 2006
--)
--select 
--    coalesce(t.player_name, y.player_name) as player_name,
--    coalesce(t.height, y.height) as height,
--    coalesce(t.college, y.college) as college,
--    coalesce(t.draft_year, y.draft_year) as draft_year,
--    coalesce(t.draft_round, y.draft_round) as draft_round,
--    coalesce(t.draft_number, y.draft_number) as draft_number,
--    case 
--        when y.season_stats is null 
--        then array[
--            (t.season, t.gp, t.pts, t.reb, t.ast)::season_stats
--        ]::season_stats[]
--        when t.season is not null 
--        then array_append(y.season_stats, (t.season, t.gp, t.pts, t.reb, t.ast)::season_stats)
--        else y.season_stats
--    end as season_stats,
--    CASE
--        WHEN t.season IS NOT NULL THEN
--            (CASE WHEN t.pts > 20 THEN 'star'
--                  WHEN t.pts > 15 THEN 'good'
--                  WHEN t.pts > 10 THEN 'average'
--                  ELSE 'bad' END)::scoring_class
--        ELSE y.scoring_class
--    END as scoring_class,
--    
--    NULL as years_since_last_active,  
--    NULL as is_active,  
--    coalesce(t.season, y.current_season + 1) as current_season
--from today t 
--full outer join yesterday y
--    on t.player_name = y.player_name;
--
--

with unnested as (
	select player_name,scoring_class,season_stats from players 
	where current_season=2001 and player_name='Michael Jordan'
)
select player_name,scoring_class,season_stats from unnested;

