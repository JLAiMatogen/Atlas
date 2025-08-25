--1. Ensure all the Materialized Views has an unqie Index to esnure the Concurrent update of the Mviews.
CREATE UNIQUE INDEX ACC_Client_IDNumber_Summary_uq
ON prod."ACC_Client_IDNumber_Summary" ("IDNumber");

CREATE UNIQUE INDEX ACC_DebitOrder_Latest_uq
ON prod."ACC_DebitOrder_Latest" ("DebitOrderId");

CREATE UNIQUE INDEX Account_BadRate_Indicators_uq
ON prod."Account_BadRate_Indicators" ("AccountId");

CREATE UNIQUE INDEX XDS_CusomerDetailsLog_MV_uq
ON prod."XDS_CusomerDetailsLog_MV" ("ApplicationId");

Create UNIQUE INDEX ACC_PaymentStatusHistory_Latest_uq
on prod."ACC_PaymentStatusHistory_Latest" ("AccountId");


--List all the Mviews to be updated
CREATE OR REPLACE PROCEDURE prod."Refresh_All_MViews"()
LANGUAGE plpgsql
AS $$
DECLARE
	  t_start   TIMESTAMP;
    t_step    TIMESTAMP;
    elapsed   NUMERIC;
BEGIN
    -- Start timing
    t_start := clock_timestamp();
    RAISE NOTICE 'Refreshing materialized views at %', t_start;


    -- Refresh each materialized in sequence
		t_step := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."XDS_CusomerDetailsLog_MV";
		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_step));
		RAISE NOTICE 'XDS_CusomerDetailsLog_MV complete in % seconds', elapsed;


		t_step := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."ACC_Client_IDNumber_Summary";
		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_step));
		RAISE NOTICE 'ACC_Client_IDNumber_Summary complete in % seconds', elapsed;

		t_step := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."ACC_DebitOrder_Latest";
		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_step));
		RAISE NOTICE 'ACC_DebitOrder_Latest complete in % seconds', elapsed;

		t_step := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."Account_BadRate_Indicators";
		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_step));
		RAISE NOTICE 'Account_BadRate_Indicators complete in % seconds', elapsed;

		t_step := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."ACC_PaymentStatusHistory_Latest";
		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_step));
		RAISE NOTICE 'ACC_PaymentStatusHistory_Latest complete in % seconds', elapsed;

		t_step := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."Account_Detail_MV";
		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_step));
		RAISE NOTICE 'Account_Detail_MV complete in % seconds', elapsed;

		elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - t_start));
    RAISE NOTICE 'Refresh complete at % in % seconds',clock_timestamp(),elapsed;
END;
$$;

CALL prod."Refresh_All_MViews"();
