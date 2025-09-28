CREATE OR REPLACE PROCEDURE "Refresh_All_MViews"()
LANGUAGE plpgsql
AS $$
DECLARE
	  t_start   	TIMESTAMP;
    t_step    	TIMESTAMP;
    elapsed   	NUMERIC;
		schemaname	TEXT = current_schema;
		viewname    TEXT;

		vViewsToRefresh TEXT[] := ARRAY[
				'"XDS_CusomerDetailsLog_MV"',
				'"ACC_Client_IDNumber_Summary"',
				'"ACC_DebitOrder_Latest"',
				'"Account_BadRate_Indicators"',
				'"ACC_PaymentStatusHistory_Latest"',
				'"Account_Detail_MV"'
		];

BEGIN
    -- Start timing
    t_start := clock_timestamp();
    RAISE NOTICE 'Refreshing materialized views for % at %', schemaname, t_start;

		FOREACH viewname IN ARRAY vViewsToRefresh
		LOOP
			t_step := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW CONCURRENTLY %s.%s', schemaname, viewname);
			elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_step));
			RAISE NOTICE '%.% complete in % seconds', schemaname, viewname, elapsed;
		END LOOP;


		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_start));
    RAISE NOTICE 'Refresh complete at % in % seconds',clock_timestamp(),elapsed;
EXCEPTION
    WHEN OTHERS THEN
    	RAISE EXCEPTION 'Error refreshing materialized view % in schema %: %',
                    viewname, schemaname, SQLERRM;
END;
$$;
