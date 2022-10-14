/*
 * Restrições - constraints
 * 	Limitar os dados que podem ser armazenados
 * Controle de inserções de dados
 * 
 * Tipos de restrições
 * 	Check -> verificação
 * 	Unique -> valores únicos
 * 	Primary key -> chave primária
 * 	Foreign key -> chave estrangeira. Guarda a integridade referencial entre duas tabelas
 * 	Generated as identity -> atribuição de um valor único a uma coluna
 * 
 * Uma sequência é independente da tabela
 * */

create table produtos (codprod int, nome text, preco numeric check(preco > 0)); -- Preço deve > 0
insert into produtos(codprod, nome, preco) values (1, 'Biscoito', -5);
insert into produtos(codprod, nome, preco) values (1, 'Biscoito', 5);
select * from produtos


create table produtos_desconto(codprod int, nome text, preco numeric check(preco > 0),
desconto numeric check(desconto > 0), check (preco > desconto)); 
insert into produtos_desconto(codprod, nome, preco, desconto) values (1, 'Biscoito', 5, 5);
insert into produtos_desconto(codprod, nome, preco, desconto) values (1, 'Biscoito', 5, 2);
select * from produtos_desconto


create table alunos (id int, nome text not null, idade numeric check(idade >=18));
insert into alunos (id, nome, idade) values(1, 'teste', 15);
insert into alunos (id, nome, idade) values(2, 'teste', 19);
select * from alunos;

create table  produtos_unique (id int unique, descricao text not null, valor numeric);
insert into produtos_unique(id, descricao, valor) values (1, 'Biscoito', 5);
insert into produtos_unique(id, descricao, valor) values (1, 'Biscoito', 5);


create table  produtos_pk (id int primary key, descricao text not null, valor numeric);
insert into produtos_pk(id, descricao, valor) values (1, 'Biscoito', 5);
insert into produtos_pk(id, descricao, valor) values (2, 'Biscoito', 5);
select * from produtos_pk;


create table item (codigo integer primary key, descricao text, preco numeric);
create table pedido (codigo integer primary key, codprod integer references item(codigo), quantidade integer);


create table cores (id int generated always as identity, nome varchar not null);
insert into cores(nome) values ('Azul');
insert into cores(id, nome) overriding system value values(2, 'verde'); -- sobrescrevendo a restrição
select * from cores