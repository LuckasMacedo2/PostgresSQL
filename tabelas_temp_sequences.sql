/*
 * Tabelas
 * 
 * Tabelas temporárias
 * 
 * Tabelas não registradas
 * 
 * Tabelas registradas
 * 	Tabelas normais
 * 
 * Indices facilitam a busca e tornam-a mais rápida
 * 
 * Tupla == colunas
 * */

-- Tabela normal
create table logs (id serial primary key, -- identificador da tabela
usuario varchar(50),
descricao text,
log_ts timestamp with time zone not null default current_timestamp)

create table users (pk int generated always as identity, -- identificador da tabela
username text not null,
gecos text,
email text not null,
primary key(pk),
unique (username)
)

-- EXISTS
create table if not exists users (pk int generated always as identity, -- identificador da tabela
username text not null,
gecos text,
email text not null,
primary key(pk),
unique (username)
)

-- Transações
-- Uma seção é um conjunto de transações
-- Tabela temporária só vai existir dentro da transação
create temp table if not exists users_temp (
pk int generated always as identity, -- identificador da tabela
username text not null,
gecos text,
email text not null,
primary key(pk),
unique (username))

drop table if exists users_temp

-- Tabela temporária dentro da transação

begin work; -- Inicio da transação
	
create temp table if not exists users_temp (
pk int generated always as identity,
-- identificador da tabela
username text not null,
gecos text,
email text not null,
primary key(pk),
unique (username)) on
commit drop;

select * from users_temp;

commit work -- Fim da transação


-- Tabelas unlogged
-- Tabelas não registrados
-- Tabela mais velozes, redundância.
-- Apagados ao desligar o computador

create unlogged table if not exists users_unlogged (
pk int generated always as identity,
-- identificador da tabela
username text not null,
gecos text,
email text not null,
primary key(pk),
unique (username));

-- Type
create type usuario_basico as (usuario varchar(50), pwd varchar(10));

create table super_user of usuario_basico (constraint pk_su primary key (usuario));

-- Realizando inserts
insert into users (username, gecos, email) values ('meuusr', 'meugecos', 'meuemail')
insert into users (username, gecos, email) values ('meuusr1', 'meugecos1', 'meuemail1')
insert into users (username, gecos, email) values ('meuusr2', 'meugecos2', 'meuemail2')
select * from users

-- Valores nulos -> marcador especial
-- indica que um valor não existe no banco de dados
-- colocando null em primeiro em um select
-- select * from categories order by description nulls first;

-- Criando tabelas temporárias
create temp table temp_users as select * from users;

update temp_users set username = 'login' where pk = 1;
delete from temp_users where pk = 1;
delete from temp_users

select * from temp_users;

insert into temp_users select * from users;

-- truncate semelhante ao delete, mas deleta todos os registros da tabela e de forma mais rápida
-- Não permite filtragem
truncate table temp_users;

-- Auto incremento serial
-- Pode ser usado como chave primária
-- Ele não define automaticamente que a coluna será chave primária, isso deve ser especificado
create table tabela_serial (id serial); -- função serial, já faz automaticamente

create sequence table_nome_id_seq; -- Cria a sequence
create table table_nome (id integer not null default nextval('table_nome_id_seq')); -- Cria a tabela
alter sequence table_nome_id_seq owned by table_nome.id; -- Define a sequence para a tabela

select * from table_nome

-- Tipo de serials
-- smallserial 2 bytes - 1 a 32767
-- serial 4 bytes - 1 a 2147483647
-- bigserial 8 bytes - 1 a 9223372036954775807

-- Obtendo o serial atual da tabela
select currval(pg_get_serial_sequence('table_nome', 'id'));

-- Alterar uma sequence
alter sequence table_nome_id_seq restart with 3 increment by 3;

select * from tabela_serial;

-- Valor mais recente de uma sequencia
select lastval() 

-- retornando um campo no insert
insert into users (username, gecos, email) values ('meuusr4', 'meugecos4', 'meuemail4') returning username

-- Sequences
create sequence minhasequencia increment 5 start 100; -- ascendente
select nextval('minhasequencia')

create sequence minhasequencia_desc increment -1 minvalue 1 maxvalue 3 start 3 cycle; -- descendente
-- cycle indica que ao checar no valor máximo volta para o inicio
select nextval('minhasequencia_desc')