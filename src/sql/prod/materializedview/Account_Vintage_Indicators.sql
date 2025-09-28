drop materialized view prod."Account_Vintage_Indicators";

create materialized view prod."Account_Vintage_Indicators" as
WITH rollingmonths AS (
		SELECT generate_series(1, 8) AS "MonthsOnBook"
	)
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
WHERE 	ad."AgeInMonths" + 1 >= rm."MonthsOnBook"::numeric;

Create UNIQUE index Account_Vintage_Indicators_uq 
on prod."Account_Vintage_Indicators" ("AccountId","MonthsOnBook");

create index Account_Vintage_Indicators_OpenMonth
on prod."Account_Vintage_Indicators" ("OpenMonth");