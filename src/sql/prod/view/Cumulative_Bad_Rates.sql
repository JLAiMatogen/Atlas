CREATE OR REPLACE VIEW prod."Cumulative_Bad_Rates"
AS WITH rollingmonths AS (
	SELECT generate_series(1, 8) AS "MonthsOnBook"
), 
accountsummary AS (
   SELECT ad."OpenMonth",
      count(*) AS "TotalAccounts"
     FROM prod."Account_Detail_MV" ad
    WHERE ad."OpenMonth" >= 202401
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
  WHERE 	ad."OpenMonth" >= 202401
  and     ad."AgeInMonths" + 1 >= rm."MonthsOnBook"::numeric  --Added the one month to move the indiactors into the correct bucket.
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
     --UNION ALL
     --SELECT 'General'::text AS "OpenMonth",
     --       vintageindicators."Loan_Term",
     --       vintageindicators."Loan_Size",
     --       vintageindicators."MonthsOnBook",
     --       count(vintageindicators."AccountId") AS "TotalAccounts",
     --       sum(vintageindicators."Vintage_Indicator") AS "TotalAccountsInArrears"
     --      FROM vintageindicators
     -- GROUP BY vintageindicators."Loan_Term", vintageindicators."Loan_Size", vintageindicators."MonthsOnBook"
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