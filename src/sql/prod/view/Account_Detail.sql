--Age in Months Calculation:
-- Email from Adelle 08 August 2025. The Age in motnhs starts with 1 in the month that the first instalment is due.
-- In my kop (maar daar is seker ander manière ook om dit te doen) is “1” die eerste maand wat ‘n instalment due is, so ja in jou eerste geval is May = “1” en in jou tweede voorbeeld is May eintlik “0” as daar so iets was en June = “1”
-- Changed the bands to include bands until R14,000

Drop view "Account_Detail" cascade;

create or replace view "Account_Detail" as 
WITH parameters AS (
 SELECT date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) + '1 mon -1 days'::interval AS last_day_of_month
)
select 	
		aa."AccountId"
	,	aam."ApplicationId"
	, pc."Firstname"||' '||pc."Lastname" "Consultant"
	, aa."OpenDate" 
	, aa."CloseDate"
	,	TO_CHAR(aa."OpenDate", 'YYYYMM')::int "OpenMonth"
	, apf."Description" as "PaymentFrequency"
	, case 
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 30  then '1'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 31  and 60  then '2'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 61  and 90  then '3'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 120 then '4'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 121 and 150 then '5'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 151 and 180 then '6'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 210 then '7'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 211 and 240 then '8'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 241 and 270 then '9'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 271 and 300 then '10'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 301 and 330 then '11'
		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 331 and 360 then '12'
		else	'12+' 
		end  "Loan_Term"
	, case 
		when ( aa."LoanAmount"  between 0    and 1000  ) then '   0 - 1000'
		when ( aa."LoanAmount"  between 1001 and 2000  ) then '1001 - 2000'
		when ( aa."LoanAmount"  between 2001 and 3000  ) then '2001 - 3000'
		when ( aa."LoanAmount"  between 3001 and 4000  ) then '3001 - 4000'
		when ( aa."LoanAmount"  between 4001 and 5000  ) then '4001 - 5000'
		when ( aa."LoanAmount"  between 5001 and 6000  ) then '5001 - 6000'
		when ( aa."LoanAmount"  between 6001 and 7000  ) then '6001 - 7000'
		when ( aa."LoanAmount"  between 7001 and 8000  ) then '7001 - 8000'
		when ( aa."LoanAmount"  between 8001 and 9000  ) then '8001 - 9000'
		when ( aa."LoanAmount"  between 9001 and 10000 ) then '9001 - 10000'
		when ( aa."LoanAmount"  between 10001 and 11000 ) then '10001 - 11000'
		when ( aa."LoanAmount"  between 11001 and 12000 ) then '11001 - 12000'
		when ( aa."LoanAmount"  between 12001 and 13000 ) then '12001 - 13000'
		when ( aa."LoanAmount"  between 13001 and 14000 ) then '13001 - 14000'
		else	'14000 +' 
		end  "Loan_Size"
	, case when ( aa."LoanStateReasonCode"  in ('H') ) then 1 else 0 end "HandedOver" 
	, a."NLRScore" "BureauScore"
	,	cs."ApplicationScore"
	, case 
		when ( ap."ClientCategory" is not null ) then ap."ClientCategory" 
	  when ( aa."CreateDate" > acs."First_Opened" ) then 'Existing Client' 
		else 'New Clients' 
		end "ClientCategory"
	, ado."ServiceProvider"
	, b."BranchName"
	, case 
		when acs."First_Opened" is null then 'New'
		when aa."OpenDate" > acs."First_Opened" then 'Existing' 
		else 'New' 
		end "NRE_Status"
	, b2."Description" "Debtors_Bank"
	,	p."Description"  "Product"
	,	case when ( q."IsRollOver") then 'Yes' else 'No' end "ROLLd_Loan"
	, case when ( ap."IsGetOfferOverride") then 'Yes' ELSE 'No' end "CDE_Override"
	, c."IDNumber"
	, abr."FirstDueDate"
	, abr."FirstArrearDate"
	, age_in_months(date_trunc('month'::text, greatest(aa."OpenDate",abr."FirstDueDate") )::date, pp.last_day_of_month::date) AS "AgeInMonths"
  ,	age_in_months(date_trunc('month'::text, greatest(aa."OpenDate",abr."FirstDueDate") )::date, (date_trunc('month'::text, abr."FirstArrearDate") + '1 mon -1 days'::interval)::date) AS "MonthsFirstArrear"
	,	abr."FirstDueDate_Missed_Flag"
	,	abr."FirstInstalment_Default_Flag"
	, abr."One_ever_3_Flag"
	, abr."Two_ever_6_Flag"
	, coalesce(xds."Bureau_Returned",'Experian') "Bureau_Returned"
	, xds."Bureau_Score"
	,	case 
		when a."NLRScore" <= 579 then '  0 - 580'
		when a."NLRScore" >= 621 then '621 +'
		else (TRUNC(a."NLRScore" / 5) * 5 + 1)::text ||' - '||(TRUNC(a."NLRScore" / 5) * 5 + 5)::text 
		end  "BureauScoreBand"
  , case 
		when cs."ApplicationScore" < 560 then '  0 - 560'
		when cs."ApplicationScore" >= 750 then '750 +'
		else ((cs."ApplicationScore" / 5) * 5 + 1)::text||' - '||((cs."ApplicationScore" / 5) * 5 + 5)::text
		end  "ApplicationScoreBand"
	, case 
		when ( psh."PaymentStatusDescription" is not null ) then  psh."PaymentStatusDescription"
		when ( aa."OpenDate" < '2024-11-01' ) then 'Pre-Segmentation' --only started recording overdue after this date.
		when ( psh."PaymentStatusDescription" is null ) then 'Pre-Segmentation'
		else 'Other' end "OverDue_Segment"
from  "ACC_Account" aa
				left outer join "Account_BadRate_Indicators" abr
					on aa."AccountId" = abr."AccountId"
				left outer join "Branch" b
					on	aa."BranchId" = b."BranchId" 
				left outer join "ACC_DebitOrder_Latest" ado
					on aa."AccountId" =  ado."AccountId"
				left outer join "Client" c
					on aa."ClientId" = c."ClientId"
				left outer join "ACC_Client_IDNumber_Summary" acs
					on c."IDNumber" = acs."IDNumber"
				left outer join "ACC_PaymentStatusHistory_Latest" psh
					on aa."AccountId" = psh."AccountId"
	,		"PRD_Products" p
	, 	"PER_Person" pc
	, 	"ACC_PeriodFrequency" apf 
	, 	"ACC_LoanStateReason" lsr
	,		"Application_AccountMapping" aam
				left outer join "Application" ap
					on aam."ApplicationId" = ap."ApplicationId"
				left outer join "BankDetail" bd 
					on  ap."BankDetailId"   = bd."BankDetailId"
				left outer join "Bank" b2 
					on  bd."BankId"  		 = b2."BankId"
				left outer join "Quotation" q 
					on	ap."QuotationId" = q."QuotationId"
				left outer join "Affordability" a
					on aam."ApplicationId" = a."ApplicationId" 
				left outer join "CreditScore" cs 
					on aam."ApplicationId"  = cs."ApplicationId"
				left outer join "XDS_CusomerDetailsLog_MV" xds
					on aam."ApplicationId"  = xds."ApplicationId"
	,   parameters pp 
where   aa."LoanType" = 'L'
and     aa."AccountId" = aam."AccountId"
and     aa."CreatedBy" = pc."PersonId" 
and     aa."PeriodFrequencyId"  = apf."PeriodFrequencyId"
and     aa."LoanStateReasonCode" = lsr."Code" 
and     aa."ProductId" = p."ProductId";

