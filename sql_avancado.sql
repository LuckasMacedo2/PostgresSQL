/*
 * Load balance
 * 
 * HPROXY e PGBOUNCE
 * 	
 * 
 * Extensões
 * 	adminpack -> logs
 * 	bloom -> filtros para a redução para postgres
 * 			 Reduz muito a qtd de dados
 * 	file_fwd -> Dispõe um arquivo do SO para o bancos
 * 	pageinspect -> inspeção de dados para evitar que os dados fiquem em blocos do disco defeituosos
 * 	pg_buffercache -> verificar o cache do sistema operacional em tempo real
 * 	pgstatttuple -> vê o status das tuplas, das linhas das tabelas
 * 	postgres_fdw -> conectar os servidores em módulos utilizando o este módulo
 * 	timesqldb -> programa para BD postgres para lidar com grandes volumes de dados seriais
 * 
 * 
 * 
 * */

create extension bloom;

create table t_bloom (
	id serial,
	col1 int4 default random() * 1000,
	col2 int4 default random() * 1000,
	col3 int4 default random() * 1000,
	col4 int4 default random() * 1000,
	col5 int4 default random() * 1000,
	col6 int4 default random() * 1000,
	col7 int4 default random() * 1000,
	col8 int4 default random() * 1000,
	col9 int4 default random() * 1000,
	col10 int4 default random() * 1000
)

insert into t_bloom (id) select * from generate_series(1,10000000);

create index idx_bloom on t_bloom using bloom(col1, col2, col3, col4, col5, col6, col7, col8, col9, col10)

set max_parallel_workers_per_gather to 0;

-- Grouping set -> explicita os dados a serem utilizadas
-- ROLLUP -> adiciona uma linha geral
-- CUBE -> todas as combinações possíveis por grupo
CREATE TABLE t_oil (
	region text,
	country text,
	year int,
	production int,
	consumption int
);

COPY t_oil FROM PROGRAM 
	'curl https://raw.githubusercontent.com/Mazuco/PostgreSQL/master/oil_ext.txt';

SELECT region, avg(production) FROM t_oil GROUP BY region;

SELECT region, avg(production)
	FROM t_oil
	GROUP BY ROLLUP (region);

explain SELECT region, avg(production)
	FROM t_oil
	GROUP BY ROLLUP (region);

SELECT region, country, avg(production)
	FROM t_oil
	WHERE country IN ('USA', 'Canada', 'Iran', 'Oman')
	GROUP BY ROLLUP (region, country);

SELECT region, country, avg(production)
	FROM t_oil
	WHERE country IN ('USA', 'Canada', 'Iran', 'Oman')
	GROUP BY CUBE (region, country);

SELECT region, country, avg(production)
	FROM t_oil
	WHERE country IN ('USA', 'Canada', 'Iran', 'Oman')
	GROUP BY GROUPING SETS ( (), region, country);

explain SELECT region, country, avg(production)
	FROM t_oil
	WHERE country IN ('USA', 'Canada', 'Iran', 'Oman')
	GROUP BY GROUPING SETS ( (), region, country);

SET enable_hashagg TO off;

explain SELECT region, country, avg(production)
	FROM t_oil
	WHERE country IN ('USA', 'Canada', 'Iran', 'Oman')
	GROUP BY GROUPING SETS ( (), region, country);

SET enable_hashagg TO on;

SELECT region,
	avg(production) AS all,
	avg(production) FILTER (WHERE year < 1990) AS old,
	avg(production) FILTER (WHERE year >= 1990) AS new
	FROM t_oil
	GROUP BY ROLLUP (region);

-- Ordened-set aggreagate functions
-- Dados agrupados e ordenados dentro do grupo
SELECT region,
	percentile_disc(0.5) WITHIN GROUP (ORDER BY production)
	FROM t_oil
	GROUP BY 1;

SELECT region,
	percentile_disc(0.5) WITHIN GROUP (ORDER BY production)
	FROM t_oil GROUP BY ROLLUP (1);

SELECT percentile_disc(0.62) WITHIN GROUP (ORDER BY id),
	percentile_cont(0.62) WITHIN GROUP (ORDER BY id)
	FROM generate_series(1, 5) AS id;

SELECT production, count(*)
	FROM t_oil 
	WHERE country = 'Other Middle East' GROUP BY production
	ORDER BY 2 DESC
	LIMIT 4;

SELECT country, mode() WITHIN GROUP (ORDER BY production) 
	FROM t_oil 
	WHERE country = 'Other Middle East' 
	GROUP BY 1;

SELECT region,
	rank(9000) WITHIN GROUP
	(ORDER BY production DESC NULLS LAST)
	FROM t_oil
	GROUP BY ROLLUP (1);

-- Window function
-- Compara uma linha com a linha atual
-- Não agrupa as linhas em uma única linha
SELECT avg(production) FROM t_oil;

SELECT country, year, production, consumption, 
	avg(production) OVER ()
	FROM t_oil
	LIMIT 4;

SELECT country, year, production, 
	consumption, avg(production) FROM t_oil;

SELECT country, year, production, consumption,
	avg(production) OVER (PARTITION BY country)
	FROM t_oil;

SELECT year, production,
	avg(production) OVER (PARTITION BY year < 1990)
	FROM t_oil
	WHERE country = 'Canada'
	ORDER BY year;

SELECT country, year, production, min(production) 
	OVER (PARTITION BY country ORDER BY year)
	FROM t_oil
	WHERE year BETWEEN 1978 AND 1983
	AND country IN ('Iran', 'Oman');

SELECT country, year, production,
	min(production) OVER (),
	min(production) OVER (ORDER BY year)
	FROM t_oil
	WHERE year BETWEEN 1978 AND 1983
	AND country = 'Iran';

SELECT country, year, production, min(production)
	OVER (PARTITION BY country
	ORDER BY year ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
	FROM t_oil
	WHERE year BETWEEN 1978 AND 1983
	AND country IN ('Iran', 'Oman');

SELECT *, array_agg(id)
	OVER (ORDER BY id ROWS BETWEEN 1 PRECEDING AND 1
	FOLLOWING)
	FROM generate_series(1, 5) AS id;

SELECT *, 
	array_agg(id) OVER (ORDER BY id ROWS BETWEEN
	UNBOUNDED PRECEDING AND 0 FOLLOWING)
	FROM generate_series(1, 5) AS id;

SELECT *,
	array_agg(id) OVER (ORDER BY id
	ROWS BETWEEN 2 FOLLOWING
	AND UNBOUNDED FOLLOWING)
	FROM generate_series(1, 5) AS id;

SELECT year, production, array_agg(production) OVER (
	ORDER BY year
	ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
	EXCLUDE CURRENT ROW)
	FROM t_oil
	WHERE country = 'USA'
	AND year < 1970;

-- Mais claúsulas
SELECT country, year, production,
	min(production) OVER (w),
	max(production) OVER (w)
	FROM t_oil
	WHERE country = 'Canada'
	AND year BETWEEN 1980
	AND 1985
	WINDOW w AS (ORDER BY year);

SELECT year, production,
	rank() OVER (ORDER BY production)
	FROM t_oil
	WHERE country = 'Other Middle East'
	ORDER BY rank
	LIMIT 7;

SELECT year, production,
	dense_rank() OVER (ORDER BY production)
	FROM t_oil
	WHERE country = 'Other Middle East'
	ORDER BY dense_rank
	LIMIT 7;

SELECT year, production,
	ntile(4) OVER (ORDER BY production)
	FROM t_oil
	WHERE country = 'Iraq'
	AND year BETWEEN 2000 AND 2006;

SELECT grp, min(production), max(production), count(*)
	FROM (
		SELECT year, production,
		ntile(4) OVER (ORDER BY production) AS grp
		FROM t_oil
		WHERE country = 'Iraq' 
	) AS x
	GROUP BY ROLLUP (1);

-- Mover a linha nos resultados
-- lead -> move as linhas para baixo
-- lag -> move as linhas para cima
SELECT year, production,
	lag(production, 1) OVER (ORDER BY year)
	FROM t_oil
	WHERE country = 'Mexico'
	LIMIT 5;

SELECT year, production,
	production - lag(production, 1) OVER (ORDER BY year)
	FROM t_oil
	WHERE country = 'Mexico'
	LIMIT 3;

SELECT year, production,
	production - lead(production, 1) OVER (ORDER BY year)
	FROM t_oil
	WHERE country = 'Mexico'
	LIMIT 3;

SELECT year, production,
	lag(t_oil, 1) OVER (ORDER BY year)
	FROM t_oil
	WHERE country = 'USA'
	LIMIT 3;

SELECT *
	FROM (SELECT t_oil, lag(t_oil) OVER (ORDER BY year)
	FROM t_oil
	WHERE country = 'USA'
	) AS x
	WHERE t_oil = lag;

-- Values
SELECT year, production,
	first_value(production) OVER (ORDER BY year)
	FROM t_oil
	WHERE country = 'Canada'
	LIMIT 4;

SELECT year, production,
	nth_value(production, 3) OVER (ORDER BY year)
	FROM t_oil
	WHERE country = 'Canada';

SELECT *, min(nth_value) OVER ()
	FROM (
		SELECT year, production,
		nth_value(production, 3) OVER (ORDER BY year)
		FROM t_oil
		WHERE country = 'Canada'
	) AS x
	LIMIT 4;

SELECT country, production,
	row_number() OVER (ORDER BY production)
	FROM t_oil
	LIMIT 3;

SELECT country, production,
	row_number() OVER()
	FROM t_oil
	LIMIT 3;


-- Aggregate
CREATE TABLE t_taxi (trip_id int, km numeric);

INSERT INTO t_taxi
	VALUES (1, 4.0), (1, 3.2), (1, 4.5), (2, 1.9), (2, 4.5);

CREATE OR REPLACE FUNCTION taxi_per_line (numeric, numeric)
RETURNS numeric AS
$$
	BEGIN
		RAISE NOTICE 'intermediário: %, por linha: %', $1, $2;
		RETURN $1 + $2*2.2;
	END;
$$
LANGUAGE 'plpgsql';

CREATE AGGREGATE taxi_price (numeric)
(
	INITCOND = 2.5,
	SFUNC = taxi_per_line,
	STYPE = numeric
);

SELECT trip_id, taxi_price(km) FROM t_taxi GROUP BY 1;

SELECT *, taxi_price(km) OVER (PARTITION BY trip_id ORDER BY km) FROM t_taxi;

DROP AGGREGATE taxi_price(numeric);

CREATE OR REPLACE FUNCTION taxi_final (numeric)
	RETURNS numeric AS
$$
	SELECT $1 * 1.1;
$$
LANGUAGE sql IMMUTABLE;

CREATE AGGREGATE taxi_price (numeric)
(
	INITCOND = 2.5,
	SFUNC = taxi_per_line,
	STYPE = numeric,
	FINALFUNC = taxi_final
);

SELECT trip_id, taxi_price(km) FROM t_taxi GROUP BY 1;

SELECT taxi_price(x::numeric)
	OVER (ROWS BETWEEN 0 FOLLOWING AND 3 FOLLOWING)
	FROM generate_series(1, 5) AS x;

CREATE OR REPLACE FUNCTION taxi_msfunc(numeric, numeric)
RETURNS numeric AS
$$
BEGIN
RAISE NOTICE 'taxi_msfunc chamado com % e %', $1, $2;
RETURN $1 + $2;
END;
$$ LANGUAGE 'plpgsql' STRICT;

CREATE OR REPLACE FUNCTION taxi_minvfunc(numeric, numeric) RETURNS numeric AS
$$
BEGIN
	RAISE NOTICE 'taxi_minvfunc chamado com % e %', $1, $2;
	RETURN $1 - $2;
END;
$$
LANGUAGE 'plpgsql' STRICT;

CREATE AGGREGATE taxi_price (numeric)
(
	INITCOND = 0,
	STYPE = numeric,
	SFUNC = taxi_per_line,
	MSFUNC = taxi_msfunc,
	MINVFUNC = taxi_minvfunc,
	MSTYPE = numeric
);

SELECT taxi_price(x::numeric)
	OVER (ROWS BETWEEN 0 FOLLOWING AND 3 FOLLOWING)
	FROM generate_series(1, 5) AS x;

-- With ordinality
SELECT * FROM unnest('{my,dog, eats, dog food}'::text[] ) 
	WITH ordinality;

SELECT f.* FROM unnest('{my,dog, eats, dog food}'::text[] ) 
	WITH ordinality As f(phrase, sort_order);

CREATE TABLE pets(pet varchar(100) PRIMARY KEY, tags text[]);

INSERT INTO pets(pet, tags)
    VALUES ('dog', '{big, furry, friendly, eats steak}'::text[]),
        ('cat', '{small, snob, eats greenbeans, plays with mouse}'::text[]),
        ('mouse', '{very small, fits in pocket, eat peanuts, watches cat}'::text[]),
        ('fish', NULL);

SELECT pet, sort_order, tag
FROM pets, unnest(tags) 
    WITH ORDINALITY As f(tag, sort_order) ;

SELECT pet, sort_order, tag
FROM pets LEFT JOIN 
    LATERAL unnest(tags) 
        WITH ORDINALITY As f(tag, sort_order) ON true;