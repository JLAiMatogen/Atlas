-- prod."Cumulative_Bad_Rates" source

CREATE OR REPLACE VIEW prod."Cumulative_Bad_Rates"
AS WITH rollingmonths AS (
	SELECT generate_series(1, 8) AS "MonthsOnBook"
), 
accountsummary AS (
   SELECT ad."OpenMonth",
      count(*) AS "TotalAccounts"
     FROM prod."Account_Detail_MV" ad
    WHERE ad."OpenMonth" >= '202401'::text
    GROUP BY ad."OpenMonth"
  ), 
vintageindicators AS (
   SELECT ad."AccountId",
      ad."OpenDate",
      ad."OpenMonth",
      ad."FirstArrearDate",
      ad."AgeInMonths",
      ad."MonthsFirstArrear",
      ad."Loan_Term",
      ad."Loan_Size",
      ad."Bureau_Returned",
          CASE
              WHEN ad."MonthsFirstArrear" IS NOT NULL AND rm."MonthsOnBook"::numeric >= ad."MonthsFirstArrear" THEN 1
              ELSE 0
          END AS "Vintage_Indicator",
      rm."MonthsOnBook"
 	FROM 	prod."Account_Detail_MV" ad,	rollingmonths rm
  WHERE 	ad."AgeInMonths" >= rm."MonthsOnBook"::numeric AND ad."OpenMonth"::integer >= 202401
      ), 
vintageidicator_summary AS (
     SELECT vintageindicators."OpenMonth",
            vintageindicators."Loan_Term",
            vintageindicators."Loan_Size",
            vintageindicators."MonthsOnBook",
            count(vintageindicators."AccountId") AS "TotalAccounts",
            sum(vintageindicators."Vintage_Indicator") AS "TotalAccountsInArrears"
     FROM vintageindicators
     GROUP BY vintageindicators."OpenMonth", vintageindicators."Loan_Term", vintageindicators."Loan_Size", vintageindicators."MonthsOnBook"
     UNION ALL
     SELECT 'General'::text AS "OpenMonth",
            vintageindicators."Loan_Term",
            vintageindicators."Loan_Size",
            vintageindicators."MonthsOnBook",
            count(vintageindicators."AccountId") AS "TotalAccounts",
            sum(vintageindicators."Vintage_Indicator") AS "TotalAccountsInArrears"
           FROM vintageindicators
      GROUP BY vintageindicators."Loan_Term", vintageindicators."Loan_Size", vintageindicators."MonthsOnBook"
        )
 SELECT "OpenMonth",
    "Loan_Term",
    "Loan_Size",
    "MonthsOnBook",
    "TotalAccounts",
    "TotalAccountsInArrears"
FROM vintageidicator_summary vs
ORDER BY "OpenMonth", "Loan_Term", "Loan_Size", "MonthsOnBook";
--eof




	select 	"OpenMonth" 
					--"Loan_Term"
				,	count(*) "TotalAccounts"
	from   prod."Account_Detail_MV" ad 
	where  ad."OpenMonth" = '202411'
	group by "OpenMonth" 
	
with RollingMonths as (
	SELECT generate_series(1, 8) AS "MonthsOnBook"
),
VintageIndicators as (
	select 	ad."AccountId"
			,   ad."OpenDate" 
			,		ad."OpenMonth"::TEXT "OpenMonth"
			,   ad."FirstArrearDate"
	    ,		ad."AgeInMonths"
			,   ad."MonthsFirstArrear"
			,		ad."Loan_Term"
			,   ad."Loan_Size"
			,   ad."Bureau_Returned"
			,   rm."MonthsOnBook"
			,   case when (ad."MonthsFirstArrear" is not null and rm."MonthsOnBook" >= ad."MonthsFirstArrear" ) then 1 else 0 end "Vintage_Indicator"
	from   prod."Account_Detail_MV" ad , RollingMonths rm
	where  ad."OpenMonth"::int >= 202401
	and    ad."OpenMonth"::int = 202411
	--and    ad."AgeInMonths" >= rm."MonthsOnBook"
	--and		ad."AccountId" in ( 3726934 , 4463710 , 4802217)
)
select	"OpenMonth", "AgeInMonths", "MonthsOnBook"
			,	count("AccountId") "TotalAccounts"
	    , sum("Vintage_Indicator") "TotalAccountsInArrears"
from    VintageIndicators
group by "OpenMonth", "AgeInMonths", "MonthsOnBook";