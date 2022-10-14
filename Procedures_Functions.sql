/* Procedimentos armazenados
 * plpgsql
 * 	Linguagem SQL com uma maior liberdade
 */

CREATE FUNCTION broken(text) RETURNS void AS
$$
DECLARE
	v_sql text;
BEGIN
	v_sql := 'SELECT schemaname
			  FROM pg_tables
		      WHERE tablename = ''' || $1 || '''';
	RAISE NOTICE 'v_sql: %', v_sql;
	RETURN;
END;
$$ LANGUAGE 'plpgsql';

select broken('''; DROP TABLE LogErro; '); -- sql Injection

SELECT quote_literal(E'o''vitor'), quote_ident(E'o''vitor');

CREATE TABLE "Exemlo de nome" ("ID" int);

SELECT quote_literal(NULL);

SELECT quote_nullable(123), quote_nullable(NULL);

CREATE FUNCTION simple_format() RETURNS text AS
$$
DECLARE
	v_string text;
	v_result text;
BEGIN
	v_string := format('SELECT schemaname|| '' .'' || tablename
	FROM pg_tables
	WHERE %I = $1
	AND %I = $2', 'schemaname', 'tablename');
	EXECUTE v_string USING 'public', 't_test' INTO v_result;
	RAISE NOTICE 'result: %', v_result;
	RETURN v_string;
END;
$$ LANGUAGE 'plpgsql';

select simple_format();

SELECT format('Ola, %s %s','PostgreSQL', 12);

SELECT format('Ola, %s %10s','PostgreSQL', 12);

SELECT format('%1$s, %1$s, %2$s', 'one', 'dois');

-- Gerenciamento de escopo
-- Escopo = variaveis utilizadas dentro de um contexto
-- Declare -> define uma variavel
CREATE FUNCTION scope_test () RETURNS int AS
$$
	DECLARE
		i int := 0;
	BEGIN
		RAISE NOTICE 'i1: %', i;
		DECLARE
			i int;
		BEGIN
			RAISE NOTICE 'i2: %', i;
		END;
		RETURN i;
	END;
$$ LANGUAGE 'plpgsql';

SELECT scope_test();

-- Tratamento de erros
-- try except
CREATE FUNCTION error_test1(int, int) RETURNS int AS
$$
BEGIN
	RAISE NOTICE 'debug message: % / %', $1, $2;
	BEGIN
		RETURN $1 / $2;
	EXCEPTION
		WHEN division_by_zero THEN
		RAISE NOTICE 'divisao por zero detectada: %', sqlerrm;
		WHEN others THEN
		RAISE NOTICE 'algum outro erro: %', sqlerrm;
	END;
	RAISE NOTICE 'all errors handled';
	RETURN 0;
END;
$$ LANGUAGE 'plpgsql';

SELECT error_test1(9, 0);

SELECT error_test1(0, 9);

CREATE FUNCTION get_diag() RETURNS int AS
$$
DECLARE
	rc int;
	_sqlstate text;
	_message text;
	_context text;
BEGIN
	EXECUTE 'SELECT * FROM generate_series(1, 10)';
	GET DIAGNOSTICS rc = ROW_COUNT;
	RAISE NOTICE 'row count: %', rc;
	SELECT rc / 0;
EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
		_sqlstate = returned_sqlstate,
		_message = message_text,
		_context = pg_exception_context;
		RAISE NOTICE 'sqlstate: %, message: %, context: [%]',
			_sqlstate,
			_message,
			replace( _context, E'n', ' <- ' );
	RETURN rc;
END;
$$ LANGUAGE 'plpgsql';

SELECT get_diag();

-- Cursor
-- Pode ser utilizado por outras procedures
-- Consultas muito grandes podem consumir muito recursos do BD

CREATE OR REPLACE FUNCTION c(int)
	RETURNS setof text AS
$$
DECLARE
	v_rec record;
BEGIN
	FOR v_rec IN SELECT tablename
		FROM pg_tables
		LIMIT $1
	LOOP
		RETURN NEXT v_rec.tablename;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE 'plpgsql';

SELECT * FROM c(3);

-- Dados do cursor são buscados no chamador
CREATE OR REPLACE FUNCTION d(int)
	RETURNS setof text AS
$$
DECLARE
	v_cur refcursor;
	v_data text;
BEGIN
	OPEN v_cur FOR
		SELECT tablename
		FROM pg_tables
		LIMIT $1;
	WHILE true LOOP
		FETCH v_cur INTO v_data;
		IF FOUND THEN
			RETURN NEXT v_data;
		ELSE
			RETURN;
		END IF;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION e(int)
	RETURNS setof text AS
$$
DECLARE
	v_cur CURSOR (param1 int) FOR
		SELECT tablename
		FROM pg_tables
		LIMIT param1;
	v_data text;
BEGIN
	OPEN v_cur ($1);
	WHILE true LOOP
		FETCH v_cur INTO v_data;
		IF FOUND THEN
			RETURN NEXT v_data;
		ELSE
			RETURN;
		END IF;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cursor_test(c refcursor)
	RETURNS refcursor AS
$$
BEGIN
	OPEN c FOR SELECT *
		FROM generate_series(1, 10) AS id;
	RETURN c;
END;
$$ LANGUAGE plpgsql;

BEGIN;
SELECT cursor_test('mytest');

-- Tipos compostos
-- Trabalhar com tipos de dados definidos pelo próprio usuário


CREATE TYPE my_cool_type AS (s text, t text);

CREATE FUNCTION f(my_cool_type)
	RETURNS my_cool_type AS
$$
DECLARE
	v_row my_cool_type;
BEGIN
	RAISE NOTICE 'schema: (%) / table: (%)'
	, $1.s, $1.t;
	SELECT schemaname, tablename
	INTO v_row
	FROM pg_tables
	WHERE tablename = trim($1.t)
		AND schemaname = trim($1.s)
	LIMIT 1;
	RETURN v_row;
END;
$$ LANGUAGE 'plpgsql';

SELECT (f).s, (f).t
	FROM f ('("public", "t_test")'::my_cool_type);

-- Triggers
-- Disparo no banco de dados, a partir de uma claúsla insert, update, delete ...

\h CREATE TRIGGER

CREATE TABLE t_sensor (
	id serial,
	ts timestamp,
	temperature numeric
);

CREATE OR REPLACE FUNCTION trig_func()
RETURNS trigger AS
$$
	BEGIN
		IF NEW.temperature < -273
		THEN
		NEW.temperature := 0;
		END IF;
		RETURN NEW;-- new = nova linha
	END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER sensor_trig
	BEFORE INSERT ON t_sensor
	FOR EACH ROW
	EXECUTE PROCEDURE trig_func();

INSERT INTO t_sensor (ts, temperature)
	VALUES ('2020-05-04 14:43', -300) RETURNING *;

INSERT INTO t_sensor (ts, temperature)
	VALUES ('2020-05-04 14:43', -200) RETURNING *;

DROP TRIGGER sensor_trig ON t_sensor;

CREATE OR REPLACE FUNCTION trig_demo()
	RETURNS trigger AS
$$
BEGIN
	RAISE NOTICE 'TG_NAME: %', TG_NAME;
	RAISE NOTICE 'TG_RELNAME: %', TG_RELNAME;
	RAISE NOTICE 'TG_TABLE_SCHEMA: %', TG_TABLE_SCHEMA;
	RAISE NOTICE 'TG_TABLE_NAME: %', TG_TABLE_NAME;
	RAISE NOTICE 'TG_WHEN: %', TG_WHEN;
	RAISE NOTICE 'TG_LEVEL: %', TG_LEVEL;
	RAISE NOTICE 'TG_OP: %', TG_OP;
	RAISE NOTICE 'TG_NARGS: %', TG_NARGS;
	-- RAISE NOTICE 'TG_ARGV: %', TG_NAME;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER sensor_trig
	BEFORE INSERT ON t_sensor
	FOR EACH ROW
	EXECUTE PROCEDURE trig_demo();

INSERT INTO t_sensor (ts, temperature)
	VALUES ('2020-03-04 14:43', -300) RETURNING *;

CREATE OR REPLACE FUNCTION transition_trigger()
	RETURNS TRIGGER AS $$
	DECLARE
	v_record record;
	BEGIN
		IF (TG_OP = 'INSERT') THEN
	RAISE NOTICE 'new data: ';
	FOR v_record IN SELECT * FROM new_table
	LOOP
		RAISE NOTICE '%', v_record;
	END LOOP;
		ELSE
	RAISE NOTICE 'old data: ';
	FOR v_record IN SELECT * FROM old_table
	LOOP
		RAISE NOTICE '%', v_record;
	END LOOP;
		END IF;
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER transition_test_trigger_ins
	AFTER INSERT ON t_sensor
	REFERENCING NEW TABLE AS new_table
	FOR EACH STATEMENT EXECUTE PROCEDURE transition_trigger();

CREATE TRIGGER transition_test_trigger_del
	AFTER DELETE ON t_sensor
	REFERENCING OLD TABLE AS old_table
	FOR EACH STATEMENT EXECUTE PROCEDURE transition_trigger();

INSERT INTO t_sensor
	SELECT *, now(), random() * 20
	FROM generate_series(1, 5);

DELETE FROM t_sensor;

-- Procedimento de armazenamento real
\h CREATE PROCEDURE


CREATE PROCEDURE test_proc()
	LANGUAGE plpgsql
AS $$
	BEGIN
		CREATE TABLE a (aid int);
		CREATE TABLE b (bid int);
		COMMIT;
		CREATE TABLE c (cid int);
		ROLLBACK;
	END;
$$;

CALL test_proc();

\d

-- PL-Perl

apt install postgresql-plperl-12

yum install postgresql-plperl-12

create extension plperl;

create extension plperlu;

CREATE OR REPLACE FUNCTION verify_email(text)
RETURNS boolean AS
$$
if ($_[0] =~ /^[a-z0-9.]+@[a-z0-9.-]+$/)
{
	return true;
}
return false;
$$ LANGUAGE 'plperl';

SELECT verify_email('teste@teste.com');

SELECT verify_email('teste de email');

\h CREATE DOMAIN

CREATE DOMAIN email AS text
	CHECK (verify_email(VALUE) = true);

CREATE TABLE t_email (id serial, data email);

INSERT INTO t_email (data)
	VALUES ('teste@teste.com');

INSERT INTO t_email (data)
	VALUES ('teste_errado_teste.com');

CREATE OR REPLACE FUNCTION test_security()
RETURNS boolean AS
$$
use strict;
my $fp = open("/etc/password", "r");
return false;
$$ LANGUAGE 'plperl';

CREATE OR REPLACE FUNCTION first_line()
	RETURNS text AS
	$$
	open(my $fh, '<:encoding(UTF-8)', "/etc/passwd")
		or elog(NOTICE, "Could not open file '$filename' $!");
	my $row = <$fh>;
	close($fh);
	return $row;
	$$ LANGUAGE 'plperlu';

SELECT first_line();

-- SPI = Server Programming Interface = interface em C para se comunicar com os dados
-- internos do BD

-- PROCEDURE
-- Parecido com funções
-- Para invocar um procedure deve-se utilizar a palavra reservada -> call
drop table if exists accounts;

create table accounts (
    id int generated by default as identity,
    name varchar(100) not null,
    balance dec(15,2) not null,
    primary key(id)
);

insert into accounts(name,balance)
values('Bob',10000);

insert into accounts(name,balance)
values('Alice',10000);

select * from accounts;

create or replace procedure transfer(
   sender int,
   receiver int, 
   amount dec
)
language plpgsql    
as $$
begin
    -- subtraindo o valor da conta do remetente
    update accounts 
    set balance = balance - amount 
    where id = sender;

    -- adicionando o valor à conta do destinatário
    update accounts 
    set balance = balance + amount 
    where id = receiver;

    commit;
end;$$;


call transfer(2,1,1050);

SELECT * FROM accounts;

-- Drop procedure
create or replace procedure insert_actor(
	fname varchar, 
	lname varchar)
language plpgsql	
as $$
begin
	insert into actor(first_name, last_name)
	values('John','Doe');
end;
$$;

create or replace procedure insert_actor(
	full_name varchar
)
language plpgsql	
as $$
declare
	fname varchar;
	lname varchar;
begin
	-- split the fullname into first & last name
	select 
		split_part(full_name,' ', 1),
		split_part(full_name,' ', 2)
	into fname,
	     lname;
	
	-- insert first & last name into the actor table
	insert into actor(first_name, last_name)
	values('John','Doe');
end;
$$;

create or replace procedure delete_actor(
	p_actor_id int
)
language plpgsql
as $$
begin
	delete from actor 
	where actor_id = p_actor_id;
end; 
$$;

create or replace procedure update_actor(
	p_actor_id int,
	fname varchar,
	lname varchar
)
language plpgsql
as $$
begin
	update actor  set
	first_name = fname,
	last_name = lname
	where actor_id = p_actor_id;
end; 
$$;

drop procedure insert_actor;

drop procedure insert_actor(varchar);

drop procedure insert_actor;

drop procedure insert_actor(varchar,varchar);

drop procedure delete_actor, update_actor;