create or replace function prod."Cumulative_Bad_Rates"(pStartMonth INT, pEndMonth INT) 
returns TABLE("OpenMonth" TEXT, "Loan_Term" TEXT, "Loan_Size" TEXT, "MonthsOnBook" INT
						, "TotalAccounts" BIGINT, "TotalAccountsInArrears" BIGINT) as $$
declare
	vEndMonth INT;
begin

	--Auto set pEndOf month if null
	IF pEndMonth IS NULL THEN
		RAISE NOTICE 'pEndMonth is null...';
			vEndMonth := TO_CHAR(
											(TO_DATE(pStartMonth::text, 'YYYYMM') + INTERVAL '12 months') 
											, 'YYYYMM'
									)::INT;
	ELSE
		vEndMonth := pEndMonth;
	END IF;

	RAISE NOTICE 'vEndMonth is ...%', vEndMonth;
	
	RETURN QUERY
	WITH rollingmonths AS (
		SELECT generate_series(1, 8) AS "MonthsOnBook"
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
	  WHERE 	ad."OpenMonth"::integer between pStartMonth and vEndMonth
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
	 SELECT vs."OpenMonth",
	    vs."Loan_Term",
	    vs."Loan_Size",
	    vs."MonthsOnBook",
	    vs."TotalAccounts",
	    vs."TotalAccountsInArrears"
	FROM vintageidicator_summary vs
	ORDER BY "OpenMonth", "Loan_Term", "Loan_Size", "MonthsOnBook";
END;
$$ LANGUAGE plpgsql;