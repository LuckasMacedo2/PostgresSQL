/*
 * Triggers 
 * 	Antes de criar uma trigger deve ser criada uma função
 * 
 * create function trigger_funcao()
 * 		returns trigger
 * 		language plpgsql
 * as $$
 * begin
 * 		-- lógica
 * end;
 * 
 * create trigger nome 
 * 	{ before | after} {evento}
 * on tabela
 * [for [each] {row | statement}]
 * 		execute proccedure trigger_funcao
 * 
 * row -> disparado para cada linha
 * statement -> disparado a cada transação
 * */


drop table if exists funcionarios

create table funcionarios (
	id int generated always as identity,
	nome varchar(40) not null,
	primary key (id)
)

create table funcionarios_auditoria (
	id int generated always as identity,
	funcionario_id int not null,
	nome varchar(40) not null,
	alteracao timestamp(6) not null,
	primary key (id)
)


create or replace function log_alteracao_nome()
	returns  trigger 
	language plpgsql
	as 
$$
begin 
	if new.nome <> old.nome then 
		insert into funcionarios_auditoria(funcionario_id, nome, alteracao)
		values (old.id, old.nome, now());
	end if;
return new;
end;
$$;

create trigger trg_log_alteracao_nome 
	before update 
	on funcionarios for each row 
	execute procedure log_alteracao_nome();
	
insert into funcionarios (nome) values ('Lucas');
insert into funcionarios (nome) values ('Teste');

update funcionarios set nome = 'Temp' where id = 2;

select * from funcionarios_auditoria;
select * from funcionarios;

-- Alter trigger
-- Alterar uma trigger
create table funcionarios (
	id int generated always as identity,
	nome varchar(40) not null,
	salario decimal(11,2) not null default 0,
	primary key (id)
)