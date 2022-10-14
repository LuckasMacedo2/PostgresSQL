/*
 * Indice - Index
 * 	Estrutura de informações para melhorar as consultas
 * 	Sumário de um livro	
 * 
 * Tipos:
 * 	B-Tree (padrão) - acesso sequencial, grandes blocos de dados
 * 	Hash - pouco usado, util para a diferenciação e igualdade
 *  GiST - perda, cada documento é representado por uma hash
 * 	SP-GiST - Particionamento de espaço
 * 	GIN - pesquisa de texto
 * 	BRIN - tabela muito grandes
 * 
 * Criação do indice
 * 	CREATE INDEX index_nome ON tabela_nome [USING método] 
 * (
 * 		coluna_nome [ASC | DESC] [NULLS {FIRST | LAST} ]
 * );
 * 
 * */

explain select * from users where email = 'meuemail';

create index idx_users_email on users(email);

-- Listando indices
select * from pg_indexes where schemaname = 'public';

-- Deletando indice
drop index idx_users_email;

-- Unique index
create table funcionarios (id serial primary key, nome varchar(255) not null, email varchar(255) not null);
create unique index idx_funcionarios_email on funcionarios(email);

-- Indexes on expression 
-- Criar indices baseados em expressões
-- A expressão é avaliada a cada inserção / deleção na tabela e pode gerar muito custo computacional
create index idx_exp_funcionarios on funcionarios(lower(nome));

-- Partial index
-- Melhora a consulta e reduz o tamanho do indice
create table clientes (id serial primary key, nome varchar(255) not null, email varchar(255) not null, ativo bool);
create index idx_parcial_cliente_inativo on clientes(nome) where ativo = false;

-- Multicolumn index
-- Indice de muitas colunas
-- só funciona em indices b-tree, GIST, GIN e BRIN
-- Deve-se utilizar o contexto para definir o indice nas colunas
create index idx_multi_clientes on clientes(id, nome, email);

-- Fuse insert - entradas difusas
-- Busca imprecisa nos dados
create extension pg_trgm;
create table t_location(name text)

insert into t_location values('Abacaxi')
insert into t_location values('Batata')
insert into t_location values('Chiclete')
insert into t_location values('Dinossauro')
insert into t_location values('Camaro')
insert into t_location values('Camarão')

select * from t_location order by name <-> 'Camaro' limit 4;

create index idx_trgm on t_location using GiST(name GiST_trgm_ops);

explain select * from t_location order by name <-> 'Camaro' limit 4;

-- Explain
-- Visualização a consulta de um comando de forma especifica
-- Cria o melhor plano de execução e mostra
-- cost inicial..final = esforço para executar um nó da busca
-- rows = qtd de linhas 
-- width = quantos bits cada tupla ocoparará na memória
explain select * from users

-- Analyse
-- Explicar melhor a consulta de cados
explain analyse select * from users order by username desc
explain (analyse, summary on) select * from users order by username desc
explain (analyse, summary on, format json) select * from users order by username desc

-- Index HypoPG
-- Extensão
-- Indice hipotetico ou virtual e não é armazenado
-- Fica em memória privada
-- Testar antes de criar um indice
create extension hypopg;

-- Cria o indice hipotetico
select * from hypopg_create_index('create index order_created_idx on orders(order_created);');




