-- Criar um usuário
CREATE USER Lucas WITH PASSWORD '123456';

-- Criar um banco de dados
CREATE DATABASE Teste;

-- Dando acesso total ao usuário Lucas
GRANT ALL PRIVILEGES ON DATABASE teste to Lucas;

-- Logando no banco
psql -d teste -U Lucas

-- Comando psql
-- Ferramenta do postgresql

SELECT current_time

-- Principais comandos PSQL
/*
	Listar todos os bancos de dados
		\l
	Trocar de banco de dados
		\c nome_banco
	Listar todas as tabelas
		\dt
	Listar nome de tabelas específicas
		\d nome_aluno
	Listar todos os schemas
		\dn
	Listar todas as funções
		\df
	Listar todas as visões
		\dv
	Listar usuários
		\du
	Histórioc de comandos
		\s
*/