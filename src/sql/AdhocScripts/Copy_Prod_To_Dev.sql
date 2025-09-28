DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'prod'
        -- AND tablename = 'PER_Person'
    LOOP
        -- If table already exists in dev, truncate and insert
        IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'dev' AND tablename = tbl) THEN
            EXECUTE format('TRUNCATE TABLE dev.%I', tbl);
            EXECUTE format('INSERT INTO dev.%I SELECT * FROM prod.%I', tbl, tbl);
        ELSE
            -- Otherwise, create it fresh from prod
            EXECUTE format('CREATE TABLE dev.%I AS TABLE prod.%I', tbl, tbl);
        END IF;
    END LOOP;
END$$;
