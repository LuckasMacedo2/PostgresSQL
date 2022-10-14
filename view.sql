/*
 * VIEWS - cisões
 * 	Consulta armazenada, especie de tabela virtual que gera uma tabela a partir de uma tabela
 * 
 * Updatable views
 * 	Uma view é atualizada quando:
 * 		- Existe apenas um FROm
 * 		- não contém: WITH, DISTINCT, GROUP BY, HAVING, LIMITE ou OFFSET
 * 		- não pode conter operações de conjuntos: UNION, INTERSECT ou EXCEPT
 * 		- não pode conter qualquer agregação, funções de janela ou fun~çoes de retorno de conjuntos
 * 	CHECK OPTION -> as alterações satisfaçam a condição
 * 
 * Materilized views
 * 	Armazenamento de dados de forma física dos dados da view
 * 	Refresh materilized view nome view -> a tabela fica bloqueada até que o refresh seja concluído, impedindo que qualquer consulta seja realizada nessa tabela
 * 
 * Recursive view
 * 	
 * */

create view nome_view as consulta;