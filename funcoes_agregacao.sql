/* Funções de agregação
 * Executa um tipo de cálculo
 * 		Média, soma, número de valores ...
 * Group by -> divide os dados em conjunto de dados.
 */

select * from telefone
select round(avg(numero), 2) num from telefone t -- Médi
select count(*) from telefone -- Qtd de linhas
select max(numero) from telefone -- Máximo valor
select sum(numero) from telefone -- Soma 
select avg(numero)::numeric(20, 2) num from telefone t
-- Na função avg os valores null são simplesmente ignorados

-- array_agg -> aceita valores e retorna uma matriz
select numero, array_agg(operadora || ' ' || ddd) from telefone group by numero;

-- count -> Conta o número de linhas de uma tabela, conta os nulos 
select count(*) from telefone

-- sum -> soma valores, ela ignora valores nulos
-- coalesce -> converte valores nulos