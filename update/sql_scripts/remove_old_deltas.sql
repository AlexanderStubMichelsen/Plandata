\set env_schema `echo "$SCHEMA"`
\set env_max_delta `echo "$MAX_DELTA"`

SET env.schema to :env_schema;
SET env.max_delta to :env_max_delta;
DO
$$
DECLARE
    this_schema text := current_setting('env.schema');
    this_max_time int := current_setting('env.max_delta');
	drop_strings text :=(
		SELECT string_agg(format('DROP SCHEMA %I CASCADE;', d.schema_name), E'\n') 
			FROM (
				SELECT nspname schema_name, to_date(substring(nspname FROM '_\d{4}_\d\d_\d\d$'),'_YYYY_MM_DD') delta_date
				FROM pg_namespace
				WHERE  nspname LIKE this_schema || '_%'
			) d  
		WHERE d.delta_date <= NOW() - make_interval(days => this_max_time));
BEGIN
	if drop_strings NOTNULL then
	EXECUTE (
		drop_strings
	);
	end if;
END;
$$