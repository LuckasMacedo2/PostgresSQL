/*
 * Clausula like
 * like 'termo%' -> inicia com o termo
 * like '%termo' -> finaliza com o termo
 * like '%termo%' -> tem o termo
 * 
 * Comando ilike ignora letras maiusculas e minusculas
 * 
 * Clausula distinct
 * 	Retorna valores distintos
 * 	Classifica os dados
 * 	Pode deixar a busca mais lenta
 * 
 * Coalescencia -> dois dados retornam a mesma coisa e não é nulo
 * 
 * Clausula limit
 * 	Limita o número de linhas retornadas em uma consulta
 * 
 * Clausula offset
 * 	Pula o número de linhas em uma busca
 * 
 * --
 * Consultas aninhadas
 * 	EXISTS
 * 	IN
 * 	NOT IN
 * 
 * JOINs
 * 	CROSS JOIN
 * 	INNER JOIN
 * 	LEFT JOIN
 * 	RIGHT JOIN
 * 	FULL INNER JOIN -> União de tudo
 * 	SELF JOIN -> Tabela associada a si mesmo
 * 
 * Case
 * 
 * Coalesce
 * 	Lidar com valores nulos
 * 	Retorna o primeiro argumento não nulo
 * 
 * NULLIF
 * 	Lidar com valores nulos
 * 	
 * 
 * 
 * */

select * from fun;

select * from fun where nome like 'l%'; -- Começa com a letra
select * from fun where nome like '%e'; -- Finaliza com a letra
select * from fun where nome like '%Lucas%'; -- tem o termo

select * from fun where cargo not ilike 'S%';

-- coalesce
select coalesce(null, 'teste');

-- limit
select * from fun order by nome limit 1;

-- in
select * from fun where nome in ('lucas');

-- coalesce
select coalesce(null, 2, 1);

-- nullif
select nullif(1,1)
select nullif(1,0)
