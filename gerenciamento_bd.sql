-- Criando uma role
CREATE ROLE lucas2 LOGIN PASSWORD'123456' CREATEDB VALID UNTIL 'infinity';

-- Delete role
drop role lucas2

--
create role grupo1 inherit;
grant grupo1 to lucas;

-- Criação do banco de dados
create database meu_banco

-- deletando um banco de dados
drop database meu_banco

-- Criando um banco a partir de um template
create database meubd template template1;

-- Definido um template de um banco de dados
update pg_database set datistemplate = true where datname = 'meubd';

-- Schemas
-- O nome dos bancos devem ter nomes únicos
create schema minha_extensao;

-- privilégios e permissões
-- Privelgio -> dizer o que cada um deverá enxergar
--		Comando GRANT > select, insert, update, delete, truncate, references, trigger, create, connect, temporary, execute, usage
--		ALL PRIVILEGES > Total privilégio
grant algum_privilegio to algum_role

-- Revoke -> remove as permissões
-- Prvilégios padrões -> Define privilégios que seram padrões para todos os bancos

-- Tablespace
-- Mapeamento das unidades físicas do disco para nomes lógicos
-- Criando o tablespace
create tablespace
-- Deletando o tablespace
drop tablespace

