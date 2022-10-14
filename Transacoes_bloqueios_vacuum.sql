/*
 * Transações e bloqueios
 * 	Tudo em um BD é uma transações
 * 
 * Para utilizar mais de uma transações utilizar o begin
 */

begin;
select now();
select now();
commit; -- Commita a transação. Roolback retorna a transação

show transaction_read_only;

begin transaction read only;

commit and chain; -- Transação confirmada, lê e desaparece

commit and no chain; 

-- Savepoint
-- Define um novo ponto de salvamento com a transação corrente
begin;
select 1 
savepoint ok;
select 2 / 0;
select 2;
rollback to savepoint ok; -- Retornando para antes do erro
commit;

-- Transações DDL
-- DDL -> comandos que alteram a estrutura dos dados em tempo de execução
-- Todas as DDLs no postgres são transacionais

begin;
create table teste(id int);
alter table teste alter column id type int8;
rollback;

select * from teste; -- Não cria a tabela

-- Bloqueio
-- Leitura pode ocorrer de forma simultânea
-- MVCC -> Controle de transações
--		Uma transação só vê alterações que já foram confirmadas
-- Feito pela palavra chave reservada = LOCK
create table teste(id int);
insert into teste values (0);

begin;
lock table product in access exclusive mode;
insert into product select max(id) + 1, ... from product;
commit;

-- Os dados são selecionados no BD
-- For search
-- For update -> pode impactar no desempenho do banco
-- Condição de corrida -> falha em que um processo é dependente de outros processos
begin;
select * from teste;
update teste set id = 2 where id = 1;
commit;

begin;
select * from teste for update; -- Bloqueia para update e garante que nenhuma alteração simultanea ocorrerá
update teste set id = 2 where id = 1;
commit;

-- nowait -> não espera
-- set timeout -> configura o timeout
-- skip locked -> pula o lock e faz a outra consulta

-- Níveis de isolamento de transação
-- No postgres as transações possuem isolamento instantaneo
-- Níveis de isolamento:
--		Read uncommited;
--		Read commited;
--		Repeatable read;
--		Serializable.

-- Deadlock
-- Uma transação fica esperando a outra terminar para ser realizada

-- Vacuum
-- Realiza a limpeza de tuplas mortas no banco de dados
-- Rastrea e encontra espaços livres no banco, mas não reduz o tamanho de uma tabela
