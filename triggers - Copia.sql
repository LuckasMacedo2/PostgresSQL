/*
 * Segurança
 * 
 * */

-- impedir que um usuário realize login
alter user usuario nologin; -- Não derruba o usuário imediatamente

-- limitando o número de conexões de um usuário
alter user usuario connection limit numConexoes;
alter user usuario connection limit -1; -- Conexões ilimitadas

-- passando todas as propriedades de um usuário para outro
reassign owned by usuario to postgres;

-- auditoria de dados no postgres
-- Via trigger

-- Criptografia
-- pgcrypto

-- Politicas

-- Permissões