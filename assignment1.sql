select * from actor_films af ;
create type film_stats as (
	film text,
	votes integer,
	rating real,
	filmid text
);

DROP TYPE IF EXISTS film_stats CASCADE;
create type quality_class as enum('good','bad','average','star');

create table actors (
	actor text,
	actorid text,
	film_year integer,
	is_active boolean,
    film_stats film_stats[],
    primary key(actorid,film_year)
)

drop table if exists actors;

DO $$ 
DECLARE
    current_year INT := 1970; -- Start year
    max_year INT := 2021; -- End year
BEGIN
    WHILE current_year <= max_year LOOP
        INSERT INTO actors (
            actor,
            actorid,
            film_year,
            is_active,
            film_stats
        )
        WITH start_date AS (
            SELECT 
                actor, 
                actorid, 
                year AS film_year,
                array_agg((film, votes, rating, filmid)::film_stats) AS film_stats
            FROM actor_films 
            WHERE year = current_year
            GROUP BY actor, actorid, year
        ),
        end_date AS (
            SELECT 
                actor, 
                actorid, 
                year AS film_year,
                array_agg((film, votes, rating, filmid)::film_stats) AS film_stats
            FROM actor_films 
            WHERE year = current_year + 1
            GROUP BY actor, actorid, year
        )
        SELECT 
            COALESCE(e.actor, s.actor) AS actor,
            COALESCE(e.actorid, s.actorid) AS actorid,
            COALESCE(e.film_year, s.film_year) AS film_year,
            CASE 
                WHEN current_year = EXTRACT(YEAR FROM CURRENT_DATE) THEN TRUE
                ELSE FALSE
            END AS is_active,
            CASE 
                WHEN s.film_stats IS NULL THEN e.film_stats
                WHEN e.film_stats IS NULL THEN s.film_stats
                ELSE array_cat(s.film_stats, e.film_stats)
            END AS film_stats
        FROM start_date s 
        FULL OUTER JOIN end_date e
            ON e.actorid = s.actorid
        GROUP BY 
            COALESCE(e.actor, s.actor), 
            COALESCE(e.actorid, s.actorid), 
            COALESCE(e.film_year, s.film_year),
            current_year, s.film_stats, e.film_stats
        ON CONFLICT (actorid, film_year) 
        DO UPDATE SET 
            is_active = EXCLUDED.is_active,
            film_stats = array_cat(actors.film_stats, EXCLUDED.film_stats);

        current_year := current_year + 1; -- Increment year
    END LOOP;
END $$;


select * from actors;

