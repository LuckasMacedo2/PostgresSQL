/*
 * Backup e restauração
 * 
 * Backup
 * 
 * 	pg_dump -> faz o backup, mas é mais limitado
 * 	pg_dumpall -> faz o backup de tudo
 * 
 * Restauração
 * 	pg_restaure
 * 	pg_retore -> Recria caso o banco já exista
 * 
 * Backup com o psql
 * 	psql -U username -f nomeArquivoBackup.sql
 * 
 * 
 * 
 * */

-- Criando um backup do banco de dados
pg_dump -h localhost -p 5432 -U postgres -W -F t dteam > team.tar