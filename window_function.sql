/*
 * Window Functions
 * 	Realiza para executar um cálculo a partir de uma linha especifica
 * 	Faz um cálculo apenas em uma linha atual
 * 	Utiliza a cláusula Over
 * */


create table grupo_produtos (id serial primary key, nome varchar(255) not null);

drop table produtos;

create table produtos(id serial primary key, nome varchar(255), preco decimal (11, 2), grupo_id int not null, 
foreign key(grupo_id) references grupo_produtos(id));

insert into grupo_produtos(nome) values ('Smartphone'), ('PC'), ('Notebook');
insert into produtos(nome, preco, grupo_id) values ('HTC One', 400, 1), ('Nexus', 1400, 1), ('PC Gamer', 50400, 2), ('Notebook Gamer', 4400, 3)

select * from produtos

-- Função agregada -> retorna uma linha
select avg(preco) from produtos;

select grupo_produtos.nome, avg(preco) from produtos
inner join grupo_produtos using (id)
group by grupo_produtos.nome;

-- Window Function
-- partition by: distribui as linhas em grupos e a função é aplicada em cada grupo
select produtos.nome, preco, grupo_produtos.nome, 
avg(preco) over (partition by grupo_produtos.nome)
from produtos
inner join grupo_produtos using (id);

-- Rank -> Atribui uma classificação ordenada dentro de uma tabela em que for aplicar uma window function
-- Linhas com mesmos valores possuem a mesma classificação
-- rank() over (partition by order by descricao)
create table ranks (c varchar(10));
insert into ranks(c) values('A'), ('A'), ('B'), ('B'), ('B'), ('C'), ('E');

select c, rank() over (order by c) rank_numeros from ranks;

select id, nome, preco, rank() over (order by preco desc) preco_rank from produtos;

-- Dense_rank -> atribui uma classificação em cada linha, não possui lacunas diferente da função rank
-- dense_rank() over (partition by order by descricao)
select c, dense_rank() over (order by c) dense_rank_posicao from ranks;

select id, nome, preco, dense_rank() over (order by preco desc) preco_rank from produtos;

-- row_number -> atribui um número sequencial a cada linha e a cada partição
select id, nome, grupo_id, row_number() over (order by id) from produtos p;

-- cume_dist -> porcentagem de um conjunto de dados
-- Posição relativa de um valor em um conjunto de dados

CREATE TABLE estatisticas_vendas (
    nome VARCHAR(100) NOT NULL,
    ano SMALLINT NOT NULL CHECK (ano > 0),
    total DECIMAL(10,2) CHECK (total >= 0),
    PRIMARY KEY (nome,ano)
);

INSERT INTO estatisticas_vendas (nome, ano, total) VALUES ('John Doe',2018,120000),
    ('Jane Doe',2018,110000),
    ('Jack Daniel',2018,150000),
    ('Yin Yang',2018,30000),
    ('Stephane Heady',2018,200000),
    ('John Doe',2019,150000),
    ('Jane Doe',2019,130000),
    ('Jack Daniel',2019,180000),
    ('Yin Yang',2019,25000),
    ('Stephane Heady',2019,270000);
    
SELECT nome, ano, total, 
	CUME_DIST() OVER ( 
	ORDER BY total ) 
	FROM estatisticas_vendas  
	WHERE ano = 2018;
	
SELECT nome, ano, total, 
	CUME_DIST() OVER ( 
	PARTITION BY ano 
	ORDER BY total ) 
	FROM estatisticas_vendas ;

-- first_value e last_value
-- first_value -> Primeiro valor de uma partição
-- last_value -> último valor de uma partição
SELECT id, nome, grupo_id, preco, 
	FIRST_VALUE (nome) 
	OVER ( ORDER BY preco ) menor_preco 
	FROM produtos;

SELECT id, nome, preco, 
	LAST_VALUE(nome) 
	OVER( ORDER BY preco 
	RANGE BETWEEN UNBOUNDED PRECEDING 
	AND UNBOUNDED FOLLOWING ) 
	preco_alto FROM produtos;

SELECT id, nome, grupo_id, preco, 
	FIRST_VALUE(nome) 
	OVER ( PARTITION BY grupo_id 
	ORDER BY preco 
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING -- Define o quadro em cada partição e termina na última partição
	) 
	menor_preco FROM produtos;

SELECT id, nome, grupo_id, preco, 
	LAST_VALUE(nome) 
	OVER( PARTITION BY grupo_id 
	ORDER BY preco 
	RANGE BETWEEN UNBOUNDED PRECEDING 
	AND UNBOUNDED FOLLOWING ) preco_alto 
	FROM produtos;