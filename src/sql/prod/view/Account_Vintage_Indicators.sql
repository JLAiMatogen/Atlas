CREATE OR REPLACE VIEW "Account_Vintage_Indicators"
AS WITH rollingmonths AS (
	SELECT generate_series(1, 12) AS "MonthsOnBook"
)
SELECT ad."AccountId",
	ad."OpenDate",
	ad."OpenMonth",
	ad."BranchName" AS "Branch",
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
	ad."BureauScoreBand",
	ad."ApplicationScoreBand",
	ad."Bureau_Returned" AS "Bureau",
	ad."FirstArrearDate",
	ad."AgeInMonths",
	ad."MonthsFirstArrear",
	ad."OverDue_Segment",
			CASE
					WHEN ad."MonthsFirstArrear" IS NOT NULL AND rm."MonthsOnBook"::numeric >= ad."MonthsFirstArrear" THEN 1
					ELSE 0
			END AS "Vintage_Indicator",
	rm."MonthsOnBook"
FROM "Account_Detail_MV" ad,	rollingmonths rm
WHERE ad."AgeInMonths" >= rm."MonthsOnBook"::numeric;

;
--eof