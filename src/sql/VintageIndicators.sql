with Parameters as (
    SELECT {StartDate}::int AS "StartMonth",
       TO_CHAR(
           (TO_DATE({StartDate}::text, 'YYYYMM') + ({NumberOfMonths} || ' months')::interval),
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



with Parameters as (
    SELECT {StartDate}::int AS "StartMonth",
       TO_CHAR(
           (TO_DATE({StartDate}::text, 'YYYYMM') + ({NumberOfMonths} || ' months')::interval),
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
select "OpenMonth" "OPENMONTH",
	    "Loan_Term" "LOAN_TERM",
	    "Loan_Size" "LOAN_SIZE", 
	    "MonthsFirstArrear" "AGEINMONTHS",
	    1 "TOTAL_ACCOUNTS",
	    "Vintage_Indicator" "TOTAL_IN_ARREARS"
from  VintageData
union all
select 'General' "OPENMONTH",
	    "Loan_Term" "LOAN_TERM",
	    "Loan_Size" "LOAN_SIZE", 
	    "MonthsFirstArrear" "AGEINMONTHS",
	    1 "TOTAL_ACCOUNTS",
	    "Vintage_Indicator" "TOTAL_IN_ARREARS"
from  VintageData;