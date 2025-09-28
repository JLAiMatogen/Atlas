create or replace function "Cumulative_Bad_Rates"(pStartMonth INT, pNumMonths INT) 
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
		 	FROM 		"Account_Detail_MV" ad,	rollingmonths rm
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