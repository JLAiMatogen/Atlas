--Account number
--Bad indicators
--Loan term 
--Loan Amount
--Loan size bucket
--Bureau Score
--Application Month
--ApplicationID
--AccountID

--Loan date   + Application_date
--Repayment date
--Product
--Bureau




drop materialized view prod."Enquiry_Data_Guardrails"

--CREATE MATERIALIZED VIEW IF NOT EXISTS prod."Enquiry_Data_Guardrails" AS

drop table prod."Enquiry_Data_Guardrails";
--create table prod."Enquiry_Data_Guardrails" as 
--insert into prod."Enquiry_Data_Guardrails"
select 	ap."ApplicationId" 
			, TO_CHAR(ap."CreateDate", 'YYYYMM') "EnquiryMonth" 
			, case 
				when ( ap."Amount"  between 0    and 1000  ) 	then '1000'
				when ( ap."Amount"  between 1001 and 2000  ) 	then '2000'
				when ( ap."Amount"  between 2001 and 3000  ) 	then '3000'
				when ( ap."Amount"  between 3001 and 4000  ) 	then '4000'
				when ( ap."Amount"  between 4001 and 5000  ) 	then '5000'
				when ( ap."Amount"  between 5001 and 6000  ) 	then '6000'
				when ( ap."Amount"  between 6001 and 7000  ) 	then '7000'
				when ( ap."Amount"  between 7001 and 8000  ) 	then '8000'
				when ( ap."Amount"  between 8001 and 9000  ) 	then '9000'
				when ( ap."Amount"  between 9001 and 10000 ) 	then '10000'
				when ( ap."Amount"  between 10001 and 11000 ) then '11000'
				when ( ap."Amount"  between 11001 and 12000 ) then '12000'
				when ( ap."Amount"  between 12001 and 13000 ) then '13000'
				when ( ap."Amount"  between 13001 and 14000 ) then '14000'
				else	'14000 +' 
				end  "Loan_Size"
			, ap."Amount" "LoanAmount"
			, ap."QuotationId" 
			, ac."AccountId" 
			--, ap."BranchId" 
			, b."BranchName" 
			--, ap."ProductId" 
			, p."Description" "Product?" 
			--, ap."BankDetailId" 
			, b2."Description" "Debtors_Bank"
			, coalesce(ac."OpenDate"  , q."LoanDate") "Loan_date"
			, q."RepaymentDate" 
			, coalesce (
					  case 
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 30  then  1
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 31  and 60  then  2
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 61  and 90  then  3
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 120 then  4
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 121 and 150 then  5
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 151 and 180 then  6
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 210 then  7
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 211 and 240 then  8
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 241 and 270 then  9
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 271 and 300 then 10
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 301 and 330 then 11
						when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 331 and 360 then 12
						else	null
						end  
					,	greatest(
							DATE_PART('year', AGE(q."RepaymentDate"   , coalesce(q."LoanDate",a."CreateDate") )) * 12 +
    					DATE_PART('month', AGE(q."RepaymentDate", coalesce(q."LoanDate",a."CreateDate") ))
    					, 1)
    				)  AS "Loan_Term"
    	,	case when ( q."IsRollOver") then 'Yes' else 'No' end "ROLLd_Loan"
    	, case when ( ap."IsGetOfferOverride") then 'Yes' ELSE 'No' end "CDE_Override"
    	, case when a."Accepted" then 'TRUE' else 'FALSE' end "Accepted"
    	, a."NLRScore" "BureauScore"
    	, a."EnqDate" "EnquiryDate"
    	, cs."ApplicationScore" 
    	, cs."BehaviourScore"
    	, cs."RiskType"
    	, coalesce(xds."Bureau_Returned",'Experian') "Bureau_Returned"
    	, case 
				when acs."First_Opened" is null then 'New'
				when ac."OpenDate" > acs."First_Opened" then 'Existing' 
				else 'New' 
				end "NRE_Status"
			, apf."Description" as "PaymentFrequency"
			,	abr."FirstDueDate_Missed_Flag"
			,	abr."FirstInstalment_Default_Flag"
			, abr."One_ever_3_Flag"
			, abr."Two_ever_6_Flag"
			, case when ( ac."LoanStateReasonCode"  in ('H') ) then 1 else 0 end "HandedOver"
			--, ap.*
from 		 	--parameters pr, 
					prod."Application" ap
					--left outer join prod."Application_AccountMapping" aam
					--	on ap."ApplicationId" = aam."ApplicationId" 
					left outer join prod."BankDetail" bd 
						on  ap."BankDetailId"   = bd."BankDetailId"
					left outer join prod."Bank" b2 
						on  bd."BankId"  		 = b2."BankId"
					left outer join prod."Branch" b 
						on  ap."BranchId" = b."BranchId" 
					left outer join prod."PRD_Products" p
						on ap."ProductId" = p."ProductId" 
					left outer join prod."Quotation" q 
						on	ap."QuotationId" = q."QuotationId"
					left outer join prod."Affordability" a
						on ap."ApplicationId" = a."ApplicationId" 
					left outer join prod."CreditScore" cs 
						on ap."ApplicationId"  = cs."ApplicationId"
					left outer join prod."XDS_CusomerDetailsLog_MV" xds
						on ap."ApplicationId"  = xds."ApplicationId"
					left outer join prod."ACC_Account" ac 
						on ap."AccountId" = ac."AccountId" 
					left outer join prod."Client" c
						on ac."ClientId" = c."ClientId"
					left outer join prod."ACC_Client_IDNumber_Summary" acs
						on c."IDNumber" = acs."IDNumber"	
					left outer join prod."ACC_PeriodFrequency" apf
						on ac."PeriodFrequencyId" = apf."PeriodFrequencyId" 
					left outer join prod."Account_BadRate_Indicators" abr
						on ac."AccountId" = abr."AccountId"
where   ap."ApplicationId" = 3892988
;


select * 
from   prod."Quotation"  ;


truncate table prod."Enquiry_Data_Guardrails";

DO
$$
DECLARE
    v_start_date DATE := DATE '2024-01-01';
    v_end_date   DATE := DATE '2025-06-30';
    v_month_start DATE;
    v_month_end   DATE;
BEGIN
    v_month_start := v_start_date;

    WHILE v_month_start <= v_end_date LOOP

        v_month_end := (v_month_start + INTERVAL '1 month');

        INSERT INTO prod."Enquiry_Data_Guardrails"
        SELECT  ap."ApplicationId",
                TO_CHAR(ap."CreateDate", 'YYYYMM') AS "EnquiryMonth",
                CASE 
                    WHEN ap."Amount" BETWEEN 0     AND 1000  THEN '1000'
                    WHEN ap."Amount" BETWEEN 1001  AND 2000  THEN '2000'
                    WHEN ap."Amount" BETWEEN 2001  AND 3000  THEN '3000'
                    WHEN ap."Amount" BETWEEN 3001  AND 4000  THEN '4000'
                    WHEN ap."Amount" BETWEEN 4001  AND 5000  THEN '5000'
                    WHEN ap."Amount" BETWEEN 5001  AND 6000  THEN '6000'
                    WHEN ap."Amount" BETWEEN 6001  AND 7000  THEN '7000'
                    WHEN ap."Amount" BETWEEN 7001  AND 8000  THEN '8000'
                    WHEN ap."Amount" BETWEEN 8001  AND 9000  THEN '9000'
                    WHEN ap."Amount" BETWEEN 9001  AND 10000 THEN '10000'
                    WHEN ap."Amount" BETWEEN 10001 AND 11000 THEN '11000'
                    WHEN ap."Amount" BETWEEN 11001 AND 12000 THEN '12000'
                    WHEN ap."Amount" BETWEEN 12001 AND 13000 THEN '13000'
                    WHEN ap."Amount" BETWEEN 13001 AND 14000 THEN '14000'
                    ELSE '14000 +'
                END AS "Loan_Size",
                ap."Amount" AS "LoanAmount",
                q."QuotationId",
                ac."AccountId",
                b."BranchName",
                p."Description" AS "Product?",
                b2."Description" AS "Debtors_Bank",
                coalesce(ac."OpenDate"  , q."LoanDate") "Loan_date",
								q."RepaymentDate",
								coalesce (
										  case 
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 30  then  1
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 31  and 60  then  2
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 61  and 90  then  3
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 120 then  4
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 121 and 150 then  5
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 151 and 180 then  6
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 210 then  7
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 211 and 240 then  8
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 241 and 270 then  9
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 271 and 300 then 10
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 301 and 330 then 11
											when ( ac."NumOfInstalments" * apf."DaysInOneTerm") between 331 and 360 then 12
											else	null
											end  
										,	greatest(
												DATE_PART('year', AGE(q."RepaymentDate"   , coalesce(q."LoanDate",a."CreateDate") )) * 12 +
					    					DATE_PART('month', AGE(q."RepaymentDate", coalesce(q."LoanDate",a."CreateDate") ))
					    					, 1)
					    				)  AS "Loan_Term",
                CASE WHEN q."IsRollOver" THEN 'Yes' ELSE 'No' END AS "ROLLd_Loan",
                CASE WHEN ap."IsGetOfferOverride" THEN 'Yes' ELSE 'No' END AS "CDE_Override",
                case when a."Accepted" then 'TRUE' else 'FALSE' end "Accepted",
                a."NLRScore" AS "BureauScore",
                a."EnqDate" AS "EnquiryDate",
                cs."ApplicationScore",
                cs."BehaviourScore",
                cs."RiskType",
                COALESCE(xds."Bureau_Returned",'Experian') AS "Bureau_Returned",
                CASE 
                    WHEN acs."First_Opened" IS NULL THEN 'New'
                    WHEN ac."OpenDate" > acs."First_Opened" THEN 'Existing'
                    ELSE 'New'
                END AS "NRE_Status",
                apf."Description" AS "PaymentFrequency",
                abr."FirstDueDate_Missed_Flag",
                abr."FirstInstalment_Default_Flag",
                abr."One_ever_3_Flag",
                abr."Two_ever_6_Flag",
                CASE WHEN ac."LoanStateReasonCode" IN ('H') THEN 1 ELSE 0 END AS "HandedOver"
        FROM    prod."Application" ap
        LEFT JOIN prod."BankDetail" bd
               ON ap."BankDetailId" = bd."BankDetailId"
        LEFT JOIN prod."Bank" b2
               ON bd."BankId" = b2."BankId"
        LEFT JOIN prod."Branch" b
               ON ap."BranchId" = b."BranchId"
        LEFT JOIN prod."PRD_Products" p
               ON ap."ProductId" = p."ProductId"
        LEFT JOIN prod."Quotation" q
               ON ap."QuotationId" = q."QuotationId"
        LEFT JOIN prod."Affordability" a
               ON ap."ApplicationId" = a."ApplicationId"
        LEFT JOIN prod."CreditScore" cs
               ON ap."ApplicationId" = cs."ApplicationId"
        LEFT JOIN prod."XDS_CusomerDetailsLog_MV" xds
               ON ap."ApplicationId" = xds."ApplicationId"
        LEFT JOIN prod."ACC_Account" ac
               ON ap."AccountId" = ac."AccountId"
        LEFT JOIN prod."Client" c
               ON ac."ClientId" = c."ClientId"
        LEFT JOIN prod."ACC_Client_IDNumber_Summary" acs
               ON c."IDNumber" = acs."IDNumber"
        LEFT JOIN prod."ACC_PeriodFrequency" apf
               ON ac."PeriodFrequencyId" = apf."PeriodFrequencyId"
        LEFT JOIN prod."Account_BadRate_Indicators" abr
               ON ac."AccountId" = abr."AccountId"
        WHERE   ap."CreateDate" >= v_month_start
        AND     ap."CreateDate" <  v_month_end;

        COMMIT; -- optional but recommended per month

        v_month_start := v_month_start + INTERVAL '1 month';

    END LOOP;
END;
$$;



select * from prod."Enquiry_Data_Guardrails"
--where  "EnquiryMonth" = '202501'
--and "AccountId" is not null;
where  "ApplicationId" = 3892988;
--where "AccountId" = '5078394';



select * from prod."Quotation"
where  "ApplicationId" = '2496313';

select * from prod."Quotation" q 
where q."QuotationId" = 2508936;

select * from prod."Quotation" q 
order by "CreateDate" asc;


select  from prod."Application" a 
where a."ApplicationId" = 2496313;






