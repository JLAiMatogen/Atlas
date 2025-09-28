

select 		"OpenMonth"
			,   count(*)                      Records
			,   sum("TotalAccounts")          "TOTAL_ACCOUNTS"
    	,   sum("TotalAccountsInArrears") "TOTAL_IN_ARREARS"
from 			prod."Cumulative_BadRates_Mv_Test"
group by 	"OpenMonth";


select count(*) from prod."Account_Detail_MV"
where "OpenMonth" = 202508;

select count(*) , min("OpenDate"),max("OpenDate")
from prod."ACC_Account"
where "OpenDate" between '2025-08-01' and '2025-08-31';



drop function prod."Cumulative_Bad_Rates" cascade;

create or replace function prod."Cumulative_Bad_Rates"(pStartMonth INT, pNumMonths INT) 
returns TABLE(
							"OpenMonth" 				TEXT,
					 		"Branch"    				TEXT,
					 		"Consultant" 				TEXT,
					 		"PaymentFrequency"	TEXT,
					    "Loan_Term"					TEXT,
					    "Debtors_Bank" 			TEXT,
					    "Loan_Size"					TEXT,
				      "ROLLd_Loan"				TEXT, 
				      "Product"						TEXT,
				      "ClientCategory"		TEXT, 
				      "ServiceProvider"		TEXT, 
				      "CDE_Override"			TEXT,
				      "Bureau"						TEXT, 
				      "BureauScore_Band"	TEXT,
					    "MonthsOnBook"			INT,
					    "TotalAccounts"			BIGINT,
					    "TotalAccountsInArrears" BIGINT	) as $$
declare
	vEndMonth 	INT;
	vNumMonths	INT;
begin

	--Auto set pEndOf month if null
	IF pNumMonths IS NULL THEN
		RAISE NOTICE 'Set default month to 12 is null...';
		vNumMonths := 12;
	ELSE
		vNumMonths := pNumMonths;
	END IF;

	vEndMonth := TO_CHAR(
                 TO_DATE(pStartMonth::text, 'YYYYMM') + make_interval(months => vNumMonths),
                 'YYYYMM'
             )::INT;

	RAISE NOTICE 'vEndMonth is ...%', vEndMonth;
	
	RETURN QUERY
	WITH rollingmonths AS (
		SELECT generate_series(1, 8) AS "MonthsOnBook"
	), 
		vintageindicators AS (
		   SELECT 
		   		ad."AccountId",
		      ad."OpenDate",
		      ad."OpenMonth",
		      ad."BranchName" "Branch",
		      ad."Consultant",
		      ad."PaymentFrequency",
		      ad."Loan_Term",
		      ad."Debtors_Bank",
		      ad."Loan_Size", 
		      ad."ROLLd_Loan", 
		      ad."Product",
		      ad."ClientCategory", 
		      ad."ServiceProvider", 
		      ad."CDE_Override", 
		      case 
	       	when "BureauScore" < 560 then '  0 - 560'
	        when "BureauScore" >= 750 then '750 +'
	        else (TRUNC("BureauScore" / 5) * 5 + 1)::text ||' - '||(TRUNC("BureauScore" / 5) * 5 + 5)::text 
	        end  "BureauScore_Band",
		      ad."Bureau_Returned" "Bureau",
		      ad."FirstArrearDate",
		      ad."AgeInMonths",
		      ad."MonthsFirstArrear",
		      CASE
	        WHEN ad."MonthsFirstArrear" IS NOT NULL AND rm."MonthsOnBook"::numeric >= ad."MonthsFirstArrear" THEN 1
	        ELSE 0
	        END AS "Vintage_Indicator",
		      rm."MonthsOnBook"
		 	FROM 		prod."Account_Detail_MV" ad,	rollingmonths rm
		  WHERE 	ad."OpenMonth" between pStartMonth and vEndMonth
		  and     ad."AgeInMonths"  >= rm."MonthsOnBook"::numeric  --Added the one month to move the indiactors into the correct bucket.
		      ),
	vintageidicator_summary AS (
		     SELECT vi."OpenMonth"::text "OpenMonth",
		     				vi."Branch" ,
		     				vi."Consultant",
		     				vi."PaymentFrequency",
		            vi."Loan_Term",
		            vi."Debtors_Bank", 
		            vi."Loan_Size",
		            vi."ROLLd_Loan", 
					      vi."Product",
					      vi."ClientCategory", 
					      vi."ServiceProvider", 
					      vi."CDE_Override", 
		            vi."MonthsOnBook",
		            vi."Bureau",
		            vi."BureauScore_Band",
		            count(vi."AccountId") AS "TotalAccounts",
		            sum(vi."Vintage_Indicator") AS "TotalAccountsInArrears"
		     FROM vintageindicators vi
		     GROUP BY 	vi."OpenMonth", vi."Loan_Term", vi."Loan_Size", vi."MonthsOnBook"
		      			,		vi."Bureau",vi."BureauScore_Band",vi."Branch",vi."Consultant",vi."PaymentFrequency",vi."Debtors_Bank" 
		      			,		vi."ROLLd_Loan", vi."Product",	vi."ClientCategory", vi."ServiceProvider", vi."CDE_Override"
		      			,		vi."MonthsOnBook",  vi."Bureau", vi."BureauScore_Band"
		     --UNION ALL
		     --SELECT 'General'::text AS "OpenMonth",
		     --				vi."Branch",
		     --				vi."Consultant",
		     --				vi."PaymentFrequency",
		     --       vi."Loan_Term",
		     --      	vi."Debtors_Bank" ,
		     --       vi."Loan_Size",
		     --       vi."ROLLd_Loan", 
				 --       vi."Product",
				 --      vi."ClientCategory", 
				 --	      vi."ServiceProvider", 
				 --	      vi."CDE_Override", 
		     --       vi."MonthsOnBook",
		     --       vi."Bureau",
		     --       vi."BureauScore_Band",
		     --       count(vi."AccountId") AS "TotalAccounts",
		     --       sum(vi."Vintage_Indicator") AS "TotalAccountsInArrears"
		     --      FROM vintageindicators vi
		     -- GROUP BY 	vi."Loan_Term", vi."Loan_Size", vi."MonthsOnBook"
		     -- 			,		vi."Bureau",vi."BureauScore_Band",vi."Branch",vi."Consultant",vi."PaymentFrequency",vi."Debtors_Bank" 
		     -- 			,		vi."ROLLd_Loan", vi."Product",	vi."ClientCategory", vi."ServiceProvider", vi."CDE_Override"
		     -- 			,		vi."MonthsOnBook",  vi."Bureau", vi."BureauScore_Band"
		        
)
	SELECT 
		 		vs."OpenMonth",
		 		vs."Branch",
		 		vs."Consultant",
		 		vs."PaymentFrequency",
		    vs."Loan_Term",
		    vs."Debtors_Bank" ,
		    vs."Loan_Size",
	      vs."ROLLd_Loan", 
	      vs."Product",
	      vs."ClientCategory", 
	      vs."ServiceProvider", 
	      vs."CDE_Override",
	      vs."Bureau", 
	      vs."BureauScore_Band",
		    vs."MonthsOnBook",
		    vs."TotalAccounts",
		    vs."TotalAccountsInArrears"
		FROM vintageidicator_summary vs;
END;
$$ LANGUAGE plpgsql;


select * from prod."Cumulative_Bad_Rates"(202401,24);

drop materialized view prod."Cumulative_Bad_Rates_MV";

create materialized view prod."Cumulative_Bad_Rates_MV" as
select  a."OpenMonth"           "OPENMONTH" 
    ,   a."Loan_Term"           "LOAN_TERM"
    ,   a."Loan_Size"           "LOAN_SIZE"
    ,   a."MonthsOnBook"        "AGEINMONTHS"
    ,   sum(a."TotalAccounts")       "TOTAL_ACCOUNTS"
    ,   sum(a."TotalAccountsInArrears") "TOTAL_IN_ARREARS"
FROM   prod."Cumulative_Bad_Rates"(202401,24) a
group by a."OpenMonth"
			,	 a."Loan_Term" 
			,  a."Loan_Size"
			,   a."MonthsOnBook";


Create UNIQUE INDEX Cumulative_Bad_Rates_MV_UQ
on prod."Cumulative_Bad_Rates_MV" ("OPENMONTH","LOAN_TERM","LOAN_SIZE","AGEINMONTHS");

REFRESH MATERIALIZED VIEW CONCURRENTLY prod."Cumulative_Bad_Rates_MV";

select 	"OPENMONTH" , "AGEINMONTHS", SUM("TOTAL_ACCOUNTS"),sum("TOTAL_IN_ARREARS") 
from 		prod."Cumulative_Bad_Rates_MV"
where 	"OPENMONTH" = 'General'
group by "OPENMONTH","AGEINMONTHS";


drop materialized view prod."Cumulative_Bad_Rates_MV_Detail";
create materialized view prod."Cumulative_Bad_Rates_MV_Detail" as
select * from prod."Cumulative_Bad_Rates"(202412,12);


--Audit on Record Count vs sum of indicators.
with TotalAccounts as (
	select "OpenMonth"::text , count(*)
	from   prod."Account_Detail_MV"
	where  "OpenMonth" >= 202412
	group by "OpenMonth"
),
AccountSummary as (
	select 	"OpenMonth" , "MonthsOnBook", count(*) "RecordCount"
			,	  sum("TotalAccounts") "TotalAccounts"  , sum("TotalAccountsInArrears") "TotalAccountsInArrears"
	from 		prod."Cumulative_Bad_Rates_MV_Detail" 
	group by "OpenMonth", "MonthsOnBook"
),
MViewdata as (
	select 	"OPENMONTH" , "AGEINMONTHS"
				, sum("TOTAL_ACCOUNTS")       "TOTAL_ACCOUNTS"
				, sum("TOTAL_IN_ARREARS") "TOTAL_IN_ARREARS"
	from  prod."Cumulative_Bad_Rates_MV"
		where  "OPENMONTH" = '202506'
	group by "OPENMONTH" , "AGEINMONTHS"
)
select t.* , a.* , m.*
from   TotalAccounts t , AccountSummary a , MViewdata m
where  t."OpenMonth" = a."OpenMonth" 
and    a."OpenMonth" = m."OPENMONTH" 
and    a."MonthsOnBook"  = m."AGEINMONTHS" 
order by t."OpenMonth" , a."MonthsOnBook" 



select * from  prod."Cumulative_Bad_Rates_MV";





from prod."Cumulative_Bad_Rates"(202401,18);

select "OPENMONTH","AGEINMONTHS",sum("TOTAL_ACCOUNTS") "TOTAL_ACCOUNTS"  , sum("TOTAL_IN_ARREARS") "TOTAL_IN_ARREARS"
from prod."Cumulative_Bad_Rates_MV"
where  "OPENMONTH" = '202507'
group by "OPENMONTH","AGEINMONTHS"
order by 1;


select * from prod."Cumulative_Bad_Rates_MV"
where  	"OPENMONTH"  = '202501';

select 	sum("TOTAL_ACCOUNTS") "TOTAL_ACCOUNTS"  , sum("TOTAL_IN_ARREARS") "TOTAL_IN_ARREARS"
from 		prod."Cumulative_Bad_Rates_MV"
where  	"OPENMONTH" = '202501';






SELECT  a."OpenMonth"::text           "OPENMONTH" 
    --,   a."Branch"              
	--,	a."PaymentFrequency"
	--,   a."Debtors_Bank" 
    ,   a."Loan_Term"           "LOAN_TERM"
    ,   a."Loan_Size"           "LOAN_SIZE"
    --,	a."ROLLd_Loan" 
	--,   a."Product"
	--,   a."ClientCategory" 
	--,   a."ServiceProvider" 
	--,   a."CDE_Override"
	--,   a."Bureau" 
	--,   a."BureauScore_Band"
    ,   a."MonthsOnBook"        "AGEINMONTHS"
    ,   sum(a."TotalAccounts")       "TOTAL_ACCOUNTS"
    ,   sum(a."TotalAccountsInArrears") "TOTAL_IN_ARREARS"
FROM    prod."Cumulative_Bad_Rates_MV" a;



select "AccountId" , count(*) , max("MonthsOnBook" )
from   prod."Account_Vintage_Indicators"
group by "AccountId" 
having 		count(*) < 8;


create materialized view prod."Account_Vintage_Indicators_Summary" as
SELECT vi."OpenMonth",
 				vi."Branch" ,
 				vi."Consultant",
 				vi."PaymentFrequency",
        vi."Loan_Term",
        vi."Debtors_Bank", 
        vi."Loan_Size",
        vi."ROLLd_Loan", 
	      vi."Product",
	      vi."ClientCategory", 
	      vi."ServiceProvider", 
	      vi."CDE_Override", 
        vi."MonthsOnBook",
        vi."Bureau",
        vi."BureauScore_Band",
        count(vi."AccountId") AS "TotalAccounts",
        sum(vi."Vintage_Indicator") AS "TotalAccountsInArrears"
 FROM 	prod."Account_Vintage_Indicators" vi 
 GROUP BY 	vi."OpenMonth", vi."Loan_Term", vi."Loan_Size", vi."MonthsOnBook"
  			,		vi."Bureau",vi."BureauScore_Band",vi."Branch",vi."Consultant",vi."PaymentFrequency",vi."Debtors_Bank" 
  			,		vi."ROLLd_Loan", vi."Product",	vi."ClientCategory", vi."ServiceProvider", vi."CDE_Override"
  			,		vi."MonthsOnBook",  vi."Bureau", vi."BureauScore_Band";
		      			

select 	"OpenMonth",
				"Loan_Term",
				"Loan_Size",
				"MonthsOnBook",
				"TotalAccounts"
				"TotalAccountsInArrears"
from 		prod."Account_Vintage_Indicators_Summary" where "OpenMonth" between 202401 and 202406;
group by "OpenMonth",
				"Loan_Term",
				"Loan_Size",
				"MonthsOnBook";



create materialized view prod."Cumulative_Bad_Rates_MV2"
WITH rollingmonths AS (
		SELECT generate_series(1, 8) AS "MonthsOnBook"
	), 
		vintageindicators AS (
		   SELECT 
		   		ad."AccountId",
		      ad."OpenDate",
		      ad."OpenMonth",
		      ad."BranchName" "Branch",
		      ad."Consultant",
		      ad."PaymentFrequency",
		      ad."Loan_Term",
		      ad."Debtors_Bank",
		      ad."Loan_Size", 
		      ad."ROLLd_Loan", 
		      ad."Product",
		      ad."ClientCategory", 
		      ad."ServiceProvider", 
		      ad."CDE_Override", 
		      case 
	       	when "BureauScore" < 560 then '  0 - 560'
	        when "BureauScore" >= 750 then '750 +'
	        else (TRUNC("BureauScore" / 5) * 5 + 1)::text ||' - '||(TRUNC("BureauScore" / 5) * 5 + 5)::text 
	        end  "BureauScore_Band",
		      ad."Bureau_Returned" "Bureau",
		      ad."FirstArrearDate",
		      ad."AgeInMonths",
		      ad."MonthsFirstArrear",
		      CASE
	        WHEN ad."MonthsFirstArrear" IS NOT NULL AND rm."MonthsOnBook"::numeric >= ad."MonthsFirstArrear" THEN 1
	        ELSE 0
	        END AS "Vintage_Indicator",
		      rm."MonthsOnBook"
		 	FROM 		prod."Account_Detail_MV" ad,	rollingmonths rm
		  WHERE 	ad."AgeInMonths" + 1 >= rm."MonthsOnBook"::numeric  --Added the one month to move the indiactors into the correct bucket.
		      ),
	vintageidicator_summary AS (
		     SELECT vi."OpenMonth",
		     				vi."Branch" ,
		     				vi."Consultant",
		     				vi."PaymentFrequency",
		            vi."Loan_Term",
		            vi."Debtors_Bank", 
		            vi."Loan_Size",
		            vi."ROLLd_Loan", 
					      vi."Product",
					      vi."ClientCategory", 
					      vi."ServiceProvider", 
					      vi."CDE_Override", 
		            vi."MonthsOnBook",
		            vi."Bureau",
		            vi."BureauScore_Band",
		            count(vi."AccountId") AS "TotalAccounts",
		            sum(vi."Vintage_Indicator") AS "TotalAccountsInArrears"
		     FROM vintageindicators vi
		     GROUP BY 	vi."OpenMonth", vi."Loan_Term", vi."Loan_Size", vi."MonthsOnBook"
		      			,		vi."Bureau",vi."BureauScore_Band",vi."Branch",vi."Consultant",vi."PaymentFrequency",vi."Debtors_Bank" 
		      			,		vi."ROLLd_Loan", vi."Product",	vi."ClientCategory", vi."ServiceProvider", vi."CDE_Override"
		      			,		vi."MonthsOnBook",  vi."Bureau", vi."BureauScore_Band"
)
	SELECT 
		 		vs."OpenMonth",
		 		vs."Branch",
		 		vs."Consultant",
		 		vs."PaymentFrequency",
		    vs."Loan_Term",
		    vs."Debtors_Bank" ,
		    vs."Loan_Size",
	      vs."ROLLd_Loan", 
	      vs."Product",
	      vs."ClientCategory", 
	      vs."ServiceProvider", 
	      vs."CDE_Override",
	      vs."Bureau", 
	      vs."BureauScore_Band",
		    vs."MonthsOnBook",
		    vs."TotalAccounts",
		    vs."TotalAccountsInArrears"
		FROM vintageidicator_summary vs;






with Parameters as (
    SELECT 202401::int AS "StartMonth",
       TO_CHAR(
           (TO_DATE(202401::text, 'YYYYMM') + (12 || ' months')::interval),
           'YYYYMM'
       )::int AS "EndMonth"
)
select    count(*)
from   prod."Account_Detail_MV" , parameters p
WHERE  "OpenMonth" BETWEEN p."StartMonth" and p."EndMonth";


with Parameters as (
    SELECT 202401::int AS "StartMonth",
       TO_CHAR(
           (TO_DATE(202401::text, 'YYYYMM') + (12 || ' months')::interval),
           'YYYYMM'
       )::int AS "EndMonth"
)
select count(*) from prod."Account_Vintage_Indicators_Summary" , parameters p
WHERE  "OpenMonth" BETWEEN p."StartMonth" and p."EndMonth";



with Parameters as (
    SELECT 202401::int AS "StartMonth",
       TO_CHAR(
           (TO_DATE(202401::text, 'YYYYMM') + (12 || ' months')::interval),
           'YYYYMM'
       )::int AS "EndMonth"
),
rollingmonths AS (
		SELECT generate_series(1, 8) AS "MonthsOnBook"
	),
VintageData as (
	SELECT 
	    ad."AccountId",
	    ad."OpenDate",
	    ad."OpenMonth"::text "OpenMonth",
	    ad."BranchName" "Branch",
	    ad."Consultant",
	    ad."PaymentFrequency",
	    ad."Loan_Term",
	    ad."Debtors_Bank",
	    ad."Loan_Size", 
	    ad."ROLLd_Loan", 
	    ad."Product",
	    ad."ClientCategory", 
	    ad."ServiceProvider", 
	    ad."CDE_Override", 
	    case 
	    when "BureauScore" < 560 then '  0 - 560'
	    when "BureauScore" >= 750 then '750 +'
	    else (TRUNC("BureauScore" / 5) * 5 + 1)::text ||' - '||(TRUNC("BureauScore" / 5) * 5 + 5)::text 
	    end  "BureauScore_Band",
	    ad."Bureau_Returned" "Bureau",
	    ad."FirstArrearDate",
	    ad."AgeInMonths",
	    ad."MonthsFirstArrear",
	    CASE
	    WHEN ad."MonthsFirstArrear" IS NOT NULL AND rm."MonthsOnBook"::numeric >= ad."MonthsFirstArrear" THEN 1
	    ELSE 0
	    END AS "Vintage_Indicator",
		rm."MonthsOnBook"
	 FROM 	prod."Account_Detail_MV" ad , Parameters p , rollingmonths rm
	 where "OpenMonth" between p."StartMonth" and p."EndMonth"
	 and   ad."AgeInMonths" + 1 >= rm."MonthsOnBook"::numeric
)
select "AccountId",
	    "OpenDate",
	    "OpenMonth",
	     "Branch",
	    "Consultant",
	    "PaymentFrequency",
	    "Loan_Term",
	    "Debtors_Bank",
	    "Loan_Size", 
	    "ROLLd_Loan", 
	    "Product",
	    "ClientCategory", 
	    "ServiceProvider", 
	    "CDE_Override", 
	    "BureauScore_Band",
	    "Bureau",
	    "FirstArrearDate",
	    "AgeInMonths",
	    "MonthsFirstArrear",
	    "Vintage_Indicator",
			"MonthsOnBook"
from  VintageData
union all
select "AccountId",
	    "OpenDate",
	    'General'  "OpenMonth",
	     "Branch",
	    "Consultant",
	    "PaymentFrequency",
	    "Loan_Term",
	    "Debtors_Bank",
	    "Loan_Size", 
	    "ROLLd_Loan", 
	    "Product",
	    "ClientCategory", 
	    "ServiceProvider", 
	    "CDE_Override", 
	    "BureauScore_Band",
	    "Bureau",
	    "FirstArrearDate",
	    "AgeInMonths",
	    "MonthsFirstArrear",
	    "Vintage_Indicator",
			"MonthsOnBook"
from  VintageData;

with rollingmonths AS (
		SELECT generate_series(1, 8) AS "MonthsOnBook"
	)
select "AgeInMonths","MonthsFirstArrear" , count(*)
from   prod."Account_Detail_MV" , rollingmonths rm
where  "OpenMonth" = 202507
and    "AgeInMonths" + 1 >= rm."MonthsOnBook"::numeric
group by "AgeInMonths","MonthsFirstArrear"
order by 1 , 2;