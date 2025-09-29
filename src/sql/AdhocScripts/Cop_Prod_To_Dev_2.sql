DO $$
DECLARE
    tbl 			TEXT;
		t_start   TIMESTAMP;
BEGIN
		t_start := clock_timestamp();
		RAISE NOTICE 'Refreshing all tables for dev from prod at %', t_start;
    FOR tbl IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'prod'
        -- AND tablename = 'PER_Person'
    LOOP
				t_start := clock_timestamp();
				RAISE NOTICE 'Refreshing % at %',tbl, t_start;
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

set search_path to prod;

CALL prod."Refresh_All_MViews"();


REFRESH MATERIALIZED VIEW concurrently "Cumulative_Bad_Rates_MV";


set search_path to dev;
drop view dev."Account_Vintage_Indicators"
    
drop MATERIALIZED VIEW dev."Cumulative_Bad_Rates_MV";
CREATE MATERIALIZED VIEW dev."Cumulative_Bad_Rates_MV"	AS 
SELECT 	"OpenMonth" 
    ,		"Loan_Term" 
    ,		"Loan_Size" 
    ,		"MonthsOnBook" 
    ,   "PaymentFrequency" 
		,		"Debtors_Bank" 
		,   "ROLLd_Loan" 
		,   "Product" 
		,		"ClientCategory" 
		,   "ServiceProvider" 
		, 	"CDE_Override" 
		,		"BureauScoreBand"
		,   "Bureau" 	
		,   "OverDue_Segment"
    ,		sum(1) AS "Total_Accounts"
    ,		sum("Vintage_Indicator") AS "Total_Accounts_InArrears" 		
FROM 		"Account_Vintage_Indicators"
GROUP BY 	"OpenMonth"
    ,		"Loan_Term" 
    ,		"Loan_Size" 
    ,		"MonthsOnBook" 
    ,   "PaymentFrequency" 
		,		"Debtors_Bank" 
		,   "ROLLd_Loan" 
		,   "Product" 
		,		"ClientCategory" 
		,   "ServiceProvider" 
		, 	"CDE_Override" 
		,		"BureauScoreBand"
		,   "Bureau" 	
		,   "OverDue_Segment";

select "OpenMonth",  max("MonthsOnBook") ,count(*), sum("Total_Accounts") , sum("Total_Accounts_InArrears")
from   dev."Cumulative_Bad_Rates_MV"
where  "OpenMonth" >= 202401
group by "OpenMonth"
order by 1,2;


select "OpenMonth",  count(*), sum("Total_Accounts") , sum("Total_Accounts_InArrears")
from   dev."Cumulative_Bad_Rates_MV"
where  "OpenMonth" >= 202401
group by "OpenMonth"
order by 1,2;

select 	"AccountId","OpenMonth" , "OpenDate", "FirstDueDate" , "FirstArrearDate" , "MonthsOnBook", "AgeInMonths" ,"Vintage_Indicator"
from 		dev."Account_Vintage_Indicators"
where 	"FirstDueDate" > "OpenDate"
and		 TO_CHAR("FirstDueDate", 'YYYYMM')::int = 202503 and "MonthsOnBook" = 6
order by "OpenDate" desc;

select "OpenMonth" , count(*) 
from dev."Account_Vintage_Indicators"
group  by "OpenMonth";


select "AccountId","MonthsOnBook","OpenMonth" , "OpenDate", "FirstDueDate" , "FirstArrearDate" ,  "AgeInMonths" ,"Vintage_Indicator"
from dev."Account_Vintage_Indicators"
where  "OpenMonth" = 202505
--and    "FirstDueDate" < "OpenDate"
--and    "AgeInMonths" > 6
order by "AgeInMonths" asc;

select "OpenMonth",count(*) from dev."Account_Detail_MV"
where "FirstDueDate" < "OpenDate"
group by "OpenMonth";

select count(*) from dev."Account_Detail_MV";



select "BureauScore" , count(*) , min("BureauScore"),max("BureauScore") from prod."Account_Detail_MV"
where "OpenMonth" = 202509
group by "BureauScore"
order by 1
and   "AccountId"  = '5193999';


select * from dev."Account_Detail"
;
