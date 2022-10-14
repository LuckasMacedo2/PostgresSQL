/*
 * Tipos de dados no postgresql
 * 		Númerico -> 
 * 			NUMERIC(precisão, escala)
 * 			NaN: Não é um número
 * 		Texto
 * 			vatiyng(n), varchar(n) -> tamanho variavel com limite
 * 			character(n), char(n)  -> tamanho fixo
 * 			text -> Pode conter qualquer tamanho
 * 		Boolean
 * 			boolean
 * 			Verdadeiro = true, yes, on, 1
 * 			Falso = false, no, off, 0
 * 			Ocupa 1 byte
 * 		Date
 * 			Data
 * 			timestamp, date, time, interval
 * 			timestamp -> Armazenar a data e hora com/sem o fuso horário, utiliza 8 bytes
 * 			
 * */

-- Numeric ------------------------------------------------------
create table produtos (id serial primary key, preco numeric(5,2))
insert into produtos (preco) values (500.215);
insert into produtos (preco) values (500312312.215);
update produtos set preco = 'NaN' where id = 1;
select * from produtos;

-- Caractere ------------------------------------------------------
create table teste_caracteres (x char(1), y varchar(10), z text);
insert into teste_caracteres (x, y, z) values ('S', 'TESTe', 'TESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETETTESTETETETETTEETETETETETETETETETETETETET')
select * from teste_caracteres 

-- Boolean ------------------------------------------------------
create table estoque_disponivel (produto_id int primary key, disponivel boolean not null)
insert into estoque_disponivel (produto_id, disponivel) values ('1', true), (2, false), (3, 'yes'), (4, '0')
select * from estoque_disponivel

-- Data ------------------------------------------------------
create table documentos (id serial primary key, texto varchar(255) not null, 
data date not null default current_date); -- Pega por padrão a data atual
insert into documentos(texto) values ('Teste');
insert into documentos(texto) values ('Teste1');
select * from documentos;

create table alunos (id serial primary key, nome varchar(255), nascimento date not null, data_matricula date not null);
insert into alunos (nome, nascimento, data_matricula) values 
('Lucas', '1978-02-05', '2001-02-05'),
('Teste', '2099-02-05', '3000-07-08');
select * from alunos;
-- Obtendo a data atual
select now()::date;
select current_date;
select to_char(now()::date, 'dd/mm/yyyy');

-- Obtendo a idade
select id, nome, age(nascimento) from alunos;
select id, nome, age(data_matricula, nascimento) from alunos; -- A partir de uma data especifica

-- Extraindo ano, mês e dia
select id, nome, extract (year from nascimento) as year
, extract (month from nascimento) as month
, extract (day from nascimento) as day
from alunos;

-- Timestamp atual
select current_timestamp;
select timeofday(); 

-- Interval
-- Armazenar um período de tempo em horas, minutos, segundos ...
-- ISO 8601
select now(), now() - interval '1 year 3 hours 20 minutes'

-- Time
-- Armazena apenas a hora e o dia
create table turnos (id serial primary key, nome varchar not null, inicio time not null, fim time not null);
insert into turnos (nome, inicio, fim) values ('Manha', '08:00:00', '12:00:00'),
('Tarde', '13:00:00', '17:00:00'),
('Noite', '18:00:00', '22:00:00');
select * from turnos;

select current_time(5);
select localtime(0);

-- Serial
-- Sequencial que gera números inteiros. Ele é auto incremental
-- Serial, smallserial, bigserial
create table frutas (id serial primary key, nome varchar not null);
insert into frutas(nome) values ('abacaxi'), ('maça'), ('banana');
insert into frutas(id, nome) values (default, 'morango');
select * from frutas

-- Obter o último valor gerado por uma sequence
select currval(pg_get_serial_sequence('frutas', 'id'));
insert into frutas(id, nome) values (default, 'goiaba') returning id; -- insere e retorna o id

-- UUID
-- Identificar único universal
-- Exclusividade, garante uma exclusividade
-- Endereço MAC do PC + data atual + Número aleatório -> v1
-- Apenas números aleatórios -> v4
create extension if not exists "uuid-ossp"; -- Precisa criar a extensão
select uuid_generate_v1();
select uuid_generate_v4();
create table contatos (id uuid default uuid_generate_v4(), nome varchar not null, primary key (id));
insert into contatos(nome) values('Lucas'), ('José');
select * from contatos;

-- Json
-- Par chave e valor
create table pedidos (id serial not null primary key, info json not null);
insert into pedidos (info) values ('{"cliente" : "Teste", "itens": {"produto": "Batata", "qtd": 6}}');
select * from pedidos;
-- Consultando um item do json
select info -> 'cliente' as cliente from pedidos;
select info ->> 'cliente' as cliente from pedidos;
select info -> 'itens' ->> 'produto' as cliente from pedidos;
-- json_each
select json_each(info) from pedidos;
-- json_objects_keys -> chaves do json
select json_object_keys(info -> 'itens') from pedidos;
select json_typeof(info -> 'itens') from pedidos;

-- Hstore
-- Dado para armazenamento do tipo chave-valor -> chave => valor
-- Dados semi estruturados
create extension if not exists hstore; -- Habilita a extensão
create table livros (id serial primary key, titulo varchar(255), attr hstore);
insert into livros (titulo, attr) values ('Banco de dados', '"brochura" => "455", "editora" => "postgresql", "idioma" => "English"');
select * from livros;
select attr -> 'brochura' as brochura from livros;
select titulo from livros where attr @> '"brochura"=>"455"' :: hstore;
select titulo from livros where attr ?& array['idioma', 'editora'];
select akeys(attr) from livros; -- Chaves do hstore
select skeys(attr) from livros;
select avals(attr) from livros;
select svals(attr) from livros;
select titulo, hstore_to_json(attr) from livros; -- Converter para json
select titulo, (each(attr)).* from livros;

-- Jsonb
-- Json binário, converte os dados de forma binária, melhora o desempenho e permite trabalhar com indices
create table familias_b (id serial primary key, profile jsonb);
insert into familias_b (profile) values (
'{"nome": "Joao", "membros": 
[
{"membro" : {"relation":"pai", "nome":"José"}},
{"membro" : {"relation":"mãe", "nome":"Maria"}}
]}'
)

-- Matrizes - Arrays
select array[2001, 2002, 2003] as yrs;

-- Range types - Tipos de intervalo que tem início e fim
-- Usa notações matematicas para definir o intervalor
select '[2020-01-05, 2020-08-13]'::daterange;
select '(2020-01-05, 2020-08-13]'::daterange;
select '(0,)'::int8range;

-- Create type - define um novo tipo de dados
create type film_summary as (id int, title varchar, year smallint);
-- Create domain - cria um tipo de dados
-- Criando um domínio
create table contatos_lista (id serial primary key, nome varchar not null, check (nome !~ '\s')); -- Forma antiga
drop table contatos_lista;
--
create domain nome_contato as varchar not null check (value !~ '\s');
create table contatos_lista (id serial primary key, nome nome_contato);
insert into contatos_lista(nome) values ('Teste');
insert into contatos_lista(nome) values ('Abacai c'); -- Viola a restrição
-- /dD -> Lista todos os domínios do banco de dados

-- XML
create table familias2 (id serial primary key, perfil xml);
insert into familias2(perfil) values (
'<familia nome="Gomez">
<membro><relacao>pai</relacao><nome>Alex</nome></membro>
<membro><relacao>mae</relacao><nome>Maria</nome></membro>
</familia >');
select * from familias2







