drop procedure  "Merge_Tables_Auto";
CREATE OR REPLACE PROCEDURE prod."Merge_Tables_Auto"(
    IN source_schema TEXT,
    IN source_table TEXT,
    IN target_schema TEXT,
    IN target_table TEXT,
    IN key_columns TEXT[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    matching_columns TEXT[];
    update_columns TEXT[];
    col_list TEXT;
    update_list TEXT;
    key_condition TEXT;
    sql TEXT;
    qualified_source TEXT := format('%I.%I', source_schema, source_table);
    qualified_target TEXT := format('%I.%I', target_schema, target_table);
    table_exists BOOL;
    key_col TEXT;
    index_name TEXT;
BEGIN
    -- 1. Check if target table exists
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = target_schema
          AND table_name = target_table
    )
    INTO table_exists;

    -- 2. If it doesn't exist, create it from source table
    IF NOT table_exists THEN
        sql := format(
            'CREATE TABLE %I.%I (LIKE %I.%I INCLUDING ALL);',
            target_schema, target_table, source_schema, source_table
        );
        RAISE NOTICE 'Creating target table: %', sql;
        EXECUTE sql;

        -- 3. Create indexes on each key column
        FOREACH key_col IN ARRAY key_columns LOOP
            index_name := format('%I_%I_idx', target_table, key_col);
            sql := format(
                'CREATE INDEX IF NOT EXISTS %I ON %I.%I (%I);',
                index_name, target_schema, target_table, key_col
            );
            RAISE NOTICE 'Creating index: %', sql;
            EXECUTE sql;
        END LOOP;
    END IF;

    -- 4. Get matching columns between source and target
    SELECT array_agg(quote_ident(c.column_name))
    INTO matching_columns
    FROM information_schema.columns c
    WHERE c.table_name = target_table
      AND c.table_schema = target_schema
      AND c.column_name IN (
          SELECT column_name
          FROM information_schema.columns
          WHERE table_name = source_table
            AND table_schema = source_schema
      );

    IF matching_columns IS NULL THEN
        RAISE EXCEPTION 'No matching columns found between % and %', source_table, target_table;
    END IF;

    -- 5. Remove key columns from update list
    update_columns := ARRAY(
        SELECT unnest(matching_columns)
        EXCEPT
        SELECT quote_ident(k) FROM unnest(key_columns) AS k
    );

    -- 6. Build key condition
    SELECT string_agg(
        format('T.%1$s = S.%1$s', quote_ident(k)), ' AND '
    )
    INTO key_condition
    FROM unnest(key_columns) AS k;

    -- 7. Build update clause
    SELECT string_agg(
        format('%1$s = S.%1$s', col), ', '
    )
    INTO update_list
    FROM unnest(update_columns) AS col;

    -- 8. Build and execute MERGE
    sql := format($f$
        MERGE INTO %s AS T
        USING %s AS S
        ON %s
        WHEN MATCHED THEN
            UPDATE SET %s
        WHEN NOT MATCHED THEN
            INSERT (%s)
            VALUES (%s);
    $f$,
        qualified_target,
        qualified_source,
        key_condition,
        update_list,
        array_to_string(matching_columns, ', '),
        array_to_string(ARRAY(SELECT format('S.%s', col) FROM unnest(matching_columns) AS col), ', ')
    );

    RAISE NOTICE 'Executing SQL: %', sql;
    EXECUTE sql;
END;
$$;


create table prod."ACC_Account" as
select 	* 
from 		staging."ACC_Account"
limit 100;


select count(*) from prod."ACC_Account";


call prod."Merge_Tables_Auto"(
    'staging','ACC_Account',
    'prod','ACC_Account',
    array['AccountId']
);


select count(*) from prod."ACC_Account"

drop table prod."ACC_Account"; 