CREATE OR REPLACE PROCEDURE staging."Table_Cleanup"()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT  tablename
        FROM    pg_tables
        WHERE   schemaname = 'staging'
    LOOP
        EXECUTE 'TRUNCATE TABLE staging.' || quote_ident(r.tablename) || ' CASCADE;';
    END LOOP;
END;
$$;