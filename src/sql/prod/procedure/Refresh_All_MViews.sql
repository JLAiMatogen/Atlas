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

Create UNIQUE index Account_Detail_MV_uq 
on prod."Account_Detail_MV" ("AccountId");

--List all the Mviews to be updated
CREATE OR REPLACE PROCEDURE prod."Refresh_All_MViews"()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Refreshing materialized views...';

    -- Refresh each materialized in sequence
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."XDS_CusomerDetailsLog_MV";
	RAISE NOTICE 'XDS_CusomerDetailsLog_MV complete.';
    
    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."ACC_Client_IDNumber_Summary";
	RAISE NOTICE 'ACC_Client_IDNumber_Summary complete.';

    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."ACC_DebitOrder_Latest";
	RAISE NOTICE 'ACC_DebitOrder_Latest complete.';

    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."Account_BadRate_Indicators";
	RAISE NOTICE 'Account_BadRate_Indicators complete.';

    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."ACC_PaymentStatusHistory_Latest";
	RAISE NOTICE 'ACC_PaymentStatusHistory_Latest complete.';

--    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."ACC_PaymentStatusHistory_Latest";
--	RAISE NOTICE 'ACC_PaymentStatusHistory_Latest complete.';

    REFRESH MATERIALIZED VIEW CONCURRENTLY prod."Account_Detail_MV";
	RAISE NOTICE 'Account_Detail_MV complete.';

    RAISE NOTICE 'Refresh complete.';
END;
$$;

CALL prod."Refresh_All_MViews"();

select Count(*)
from   prod."Account_Detail_MV"
where "OpenMonth"::int >= 202401;