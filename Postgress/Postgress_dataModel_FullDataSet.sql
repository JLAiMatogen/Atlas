--Total Take-up
with TotalAccounts as materialized (
	select TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth", 	count(*) "Total" 
	from   backoffice.public."ACC_Account" aa , backoffice.public."ACC_LoanStateReason" alsr 
	where  aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    aa."LoanType" = 'L'
	and    aa."LoanStateReasonCode" = alsr."Code"
	group by TO_CHAR(aa."OpenDate", 'YYYYMM')
	order by 1
)
select * from TotalAccounts;

--Bad Rate indicators
--FirstDueDate_MissedRate
--FirstInstalment_DefaultRate
--"1+ever@3
--2+ever@6
			
select * from backoffice.public."ACC_PeriodFrequency" apf;

select count(*) 
from   backoffice.public."ACC_Account" aa
where  aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
and    aa."LoanType" = 'L';



with ACC_Account_H as materialized (
	select  aa.* , apf."Description" as "PaymentFrequency" 
		,   apf."DaysInOneTerm"
		,   aa."NumOfInstalments" * apf."DaysInOneTerm" "LoanTerm_Days"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf 
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."LoanStateReasonCode"  in ('H')
),
ACC_Account_W as materialized (
	select  aa.* , apf."Description" as "PaymentFrequency"
		,   apf."DaysInOneTerm"
		,   aa."NumOfInstalments" * apf."DaysInOneTerm" "LoanTerm_Days"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."LoanStateReasonCode"  = 'W'
),
ACC_Account_D as materialized (
	select  aa.* , apf."Description" as "PaymentFrequency" 
		,   apf."DaysInOneTerm"
		,   aa."NumOfInstalments" * apf."DaysInOneTerm" "LoanTerm_Days"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."LoanStateReasonCode" = 'D'
),
ACC_Account_I as materialized (
	select  aa.* , apf."Description" as "PaymentFrequency"
		,   apf."DaysInOneTerm"
		,   aa."NumOfInstalments" * apf."DaysInOneTerm" "LoanTerm_Days"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."LoanStateReasonCode" = 'I'
),
ACC_Account_P as materialized (
	select  aa.* , apf."Description" as "PaymentFrequency"
		,   apf."DaysInOneTerm"
		,   aa."NumOfInstalments" * apf."DaysInOneTerm" "LoanTerm_Days"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."LoanStateReasonCode" = 'P'
),
ACC_Account as materialized (
	select * 
	from ACC_Account_H
	union
	select * 
	from ACC_Account_W
	union
	select * 
	from ACC_Account_D
	union
	select * 
	from ACC_Account_I
	union
	select * 
	from ACC_Account_P
	),
ACC_Creditbureau_Response as (
	select 	aa."AccountId" , aam."ApplicationId" , count(*)
		--,	xpath('//string/text()', xml(xl."Response") )::text[] as  "JsonData"
	from 	ACC_Account aa, backoffice.public."Application_AccountMapping" aam 
				left outer join backoffice.public."XDSCustomerDetailsLog" xl
				on	cast(aam."ApplicationId" as varchar) = xl."ApplicationId"
				and     xl."Type"  		= 'FullVet'
	where   aa."AccountId" 		= aam."AccountId"
	group by aa."AccountId" , aam."ApplicationId"
)
select acrr."AccountId" , acrr."ApplicationId" , count(*)
from ACC_Creditbureau_Response acrr
group by acrr."AccountId" , acrr."ApplicationId"
having count(*) >= 2;

--77250
--* from ACC_Creditbureau_Response;


select * from backoffice.public."Application_AccountMapping" aam 
where 	aam."AccountId"  = 3378323	
and 	aam."ApplicationId" = 2465982;

select 	xl."Response" 
from 	backoffice.public."XDSCustomerDetailsLog" xl
where   xl."ApplicationId"  = '2465982'
and     xl."Type" = 'FullVet'
limit 1;

 
select * from backoffice.public."Application_AccountMapping" aam ;

with Acc_Account as materialized (
	select  aa.* 
		, apf."Description" as "PaymentFrequency" 
		,   apf."DaysInOneTerm"
		,   aa."NumOfInstalments" * apf."DaysInOneTerm" "LoanTerm_Days"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
		,   case when ( aa."LoanStateReasonCode" in ('H','W','D','I','P') ) then 1 else 0 end "IsDelinquent"			
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf 
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '3 months')
	and    	aa."LoanType" = 'L'
),
--BadAccountSummary as materialized (
--	select  TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth", aa."LoanStateReasonCode" , lsr."Description", count(*) Total
--	from    ACC_Account aa , backoffice.public."ACC_LoanStateReason" lsr
--	where   aa."LoanStateReasonCode" = lsr."Code"
--	group   by TO_CHAR(aa."OpenDate", 'YYYYMM') , aa."LoanStateReasonCode", lsr."Description"
--	),
ACC_Schedules as materialized (
	select 	as1.* 
	from 	backoffice.public."ACC_Schedules" as1 , ACC_Account aa
	where  	as1."AccountId" = aa."AccountId"
	),
ACC_Repayment as materialized (
	select 	as1.* 
	from 	backoffice.public."ACC_Repayment" as1, ACC_Account ar
	where  	as1."AccountId" = ar."AccountId"		
	),
LoanDetail as materialized (
	select 	aa."AccountId" , aa."AccountNo" , aa."AccountTypeId", aa."CreateDate", as1."Installment_SrNo" 
		,	aa."OpenDate",  TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth" , aa."NumOfInstalments"
		,   extract(year from age(now(), aa."OpenDate" )) * 12  + extract(month from age(now(), aa."OpenDate") ) "AgeInMonths"
		,   aa."LoanType"
		, 	aa."CloseDate" , aa."LoanAmount"  , aa."Period" 
		,	aa."LoanStateReasonCode"
		,	aa."HandoverAmount" 
		,   aa."HandoverDate" 
		,   aa."PersonId" , aa."ClientId"
		,   aa."PaymentFrequency"
		,   aa."LoanTerm_Days"
		,   aa."Loan_Term"
		,   aa."IsDelinquent"
		,	as1."Noofdays" , as1."Installment" , as1."Paid_Installment" , as1."Duedate" , as1."PaidDate" 
	from 	ACC_Account aa left outer join  ACC_Schedules as1 
						on  aa."AccountId" = as1."AccountId"
	)
select * from LoanDetail;
,
LoanAndPaymentDetail as materialized (
	select  ld.*
		,   min( case when ( DATE_TRUNC('DAY',coalesce(ar."RepaymentDate",NOW()) ) > DATE_TRUNC('DAY',ld."Duedate") )
					then ld."Duedate"
					else null end )
					over (partition  by ld."AccountId" ) "FirstArrearDate"
		, 	ar."RepaymentAmount" , ar."RepaymentDate" , ar."PaymentModeId" 
		,   pm."PaymentCode" , pm."PaymentDescription"
	from	LoanDetail ld left outer join ACC_Repayment ar
									on 	ld."AccountId" = ar."AccountId"
									and ld."Installment_SrNo" = ar."InstallmentNo"
						  left outer join backoffice.public."PaymentModes" pm 
						  			on  ar."PaymentModeId" = pm."PaymentModeId"
	--where   ld."AccountId" = 3715566
	--and     ( DATE_TRUNC('DAY',ar."RepaymentDate") > DATE_TRUNC('DAY',ld."Duedate")  )
	--where   (ld."Paid_Installment" < ld."Installment" or DATE_TRUNC('DAY',ar."RepaymentDate") > DATE_TRUNC('DAY',ld."Duedate")  ) --or ar."PaymentModeId" in (10,11) 
),
FinalLoanDetail as materialized (
	select 	
		    case when ( ld."Installment_SrNo" = 1 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) >  ld."Duedate" )
			then 1 else 0 end "FirstDueDate_MissedRate"
		,	case when ( ld."Installment_SrNo" = 1 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
			then 1 else 0 end "FirstInstalment_DefaultRate"
		,	case when ( ld."Installment_SrNo" <= 3 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
					and ld."AgeInMonths" > 3
			then 1 else 0 end "InstallmentMissed_First3Months"
		,	case when ( ld."Installment_SrNo" <= 6 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
					and ld."AgeInMonths" > 6
			then 1 else 0 end "InstallmentMissed_First6Months"
		,	ld."PaymentFrequency"
		,	ld."LoanTerm_Days"
		,   ld."Loan_Term"
		--,	ld."OpenDate" + interval '3 MONTHS' "3MonthsOldAt"
		,   ld."AgeInMonths"
		,   ld."AccountId", ld."Installment_SrNo", ld."OpenDate", ld."ApplicationMonth", ld."LoanStateReasonCode"
		,	ld."FirstArrearDate"
		, 	ld."Duedate"
		, 	ld."PaidDate"
		,   ld."PaymentModeId", ld."PaymentCode", ld."PaymentDescription"
		,   ld."NumOfInstalments"
		,	ld."LoanType"
	from 	LoanAndPaymentDetail ld
	),
FinalAccountMetrix as (
	select 	fld."ApplicationMonth" 
		,	fld."AccountId"
		, 	fld."OpenDate"
		, 	fld."AgeInMonths"
		,   fld."LoanStateReasonCode"
		,   fld."NumOfInstalments"
		,   fld."LoanType"
		,   fld."PaymentFrequency"
		,   fld."Loan_Term"
		, 	max(fld."FirstDueDate_MissedRate") "FirstDueDate_Missed_Flag"
		,	max(fld."FirstInstalment_DefaultRate") "FirstInstalment_Default_Flag"
		,   case when 
				sum( fld."InstallmentMissed_First3Months" ) >= 1 then 1
			else 0 end "1+ever@3_Flag"
		,   case when 
				sum( fld."InstallmentMissed_First6Months" ) >= 2
			then 1
			else 0 end "2+ever@6_Fag"
	from	FinalLoanDetail fld
	group by 	fld."ApplicationMonth" 
		,	fld."AccountId"
		, 	fld."OpenDate"
		, 	fld."AgeInMonths"
		,   fld."LoanStateReasonCode"
		,   fld."NumOfInstalments"
		,   fld."LoanType"
		,   fld."PaymentFrequency"
		,   fld."Loan_Term"
)
select * from FinalAccountMetrix;
select 	fm."ApplicationMonth" 
	,   fm."PaymentFrequency"
	,   fm."Loan_Term"
	,   'Unknown' as "Bureau"
	, 	count(*) "TotalArrears"
	,   sum(fm."FirstDueDate_Missed_Flag") as "FirstDueDate_Missed_Count"
	,   sum(fm."FirstInstalment_Default_Flag") as "FirstInstalment_Default_Count"
	,	sum(fm."1+ever@3_Flag") as "1+ever@3_Count"
	,	sum(fm."2+ever@6_Fag") as "2+ever@6_Count"
from 	FinalAccountMetrix fm
group by 	fm."ApplicationMonth"
		,   fm."PaymentFrequency"
		,   fm."Loan_Term"
order by 1 , 2, 3;

select * from   backoffice.public."ACC_Account";

select max("RepaymentDate") from backoffice.public."ACC_Repayment";


select 	count(*)
	--,	rank() over (partition by lpd."AccountId")
from	LoanAndPaymentDetail lpd
where   lpd."Duedate" = lpd."FirstArrearDate";
group by ldp."LoanStateReasonCode";


--Payment Mode linked to payment is important.
--Afforability in MSSql: Affordabilty ID linked to application 


select 	aa."AccountId" , aa."AccountNo" , aa."AccountTypeId", aa."CreateDate"
	,	aa."OpenDate",  TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth"
	, 	aa."CloseDate" , aa."LoanAmount"  , aa."Period" 
	,	aa."LoanStateReasonCode"
	,	aa."HandoverAmount" 
	,   aa."HandoverDate" 
	,   aa."PersonId" , aa."ClientId" 
	,   coalesce(aa."CreateDate",NOW()) Paid_date
	--,  	as1.*
from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_Schedules" as1 
where 	"aa"."LoanType" = 'L'
and     aa."LoanStateReasonCode"  in ('H','W','D','I','P')
and     aa."AccountId"  in (2593394, 235464 )
and     aa."AccountId"  = as1."AccountId" ;

--Test Account ID's
--Handed Over 235464 (H)
--Written off 2593394 (W)
--Partial 1485873

select * from backoffice.public."ACC_Repayment" ar ;
select * from backoffice.public."PaymentModes" pm ; 

select 	* 
from	backoffice.public."ACC_Schedules" as2 
where   1=1
--and     as2."AccountId"  = 2593394
and     as2."PaymentModeId" = 10
order by "Duedate" ;

select * from backoffice.public."Application_AccountMapping" aam 
where  aam."AccountId"  = 2593394;


select 	* 
from 	backoffice.public."ACC_LoanStateReason" alsr 


select *
from  backoffice.public."LGR_Transaction" lt
where lt."IsfinancialTransaction" != false 
;

--TypeId=1=Debit, 2=Credit
select  lt."TransactionDate" ,lt."TypeId" , lt."TransactionTypeId", ltt."Description" , lt."Amount" 
from 	backoffice.public."LGR_Transaction" lt , backoffice.public."LGR_TransactionType" ltt 
where  	lt."TransactionTypeId"  = ltt."TransactionTypeId" 
and		lt."AccountId"  = 1485873
and     lt."IsfinancialTransaction" = true
order   by lt."TransactionDate" ;

group by lt."TypeId", lt."TransactionTypeId",ltt."Description"  
;

select * from backoffice.public."LGR_TransactionType" ltt 
select * from backoffice.public."LGR_TransactionTypeGroup" lttg

select * from backoffice.public."BOS_Status" bs 
;

select * from backoffice.public."AccountType" at2 ;

select extract(year from age(timestamp1, timestamp2)) * 12 +
extract(month from age(timestamp1, timestamp2));


select * from backoffice.public."ACC_PaymentPlan" p
where p."AccountId" = 2949401;


select * from backoffice.public."PRD_Company" pc ;

select * from backoffice.public."ACC_Quotation" aq ;


select * from backoffice.public."CreditScore";

with Jsondata as (
	SELECT (
	  '{
	    "codex_rules_fired": [
	      {
	        "codex_rule_description": "Application Score < 536",
	        "codex_rule_id": "Scr_1.1",
	        "codex_12_month_status": "Decline",
	        "codex_1_month_capped_status": "Decline",
	        "codex_1_month_status": "Decline",
	        "codex_2_4_month_status": "Decline",
	        "codex_5_6_month_status": "Decline",
	        "codex_rule_type": "Application Score",
	        "codex_1_month_thinfile_status": "Decline"
	      },
	      {
	        "codex_rule_description": "1 High Arrears(9) In The Last 1 year(s)",
	        "codex_rule_id": "Arr_2.4.4",
	        "codex_12_month_status": "Decline",
	        "codex_1_month_capped_status": "Accept",
	        "codex_1_month_status": "Accept",
	        "codex_2_4_month_status": "Accept",
	        "codex_5_6_month_status": "Accept",
	        "codex_rule_type": "Arrears",
	        "codex_1_month_thinfile_status": "Accept"
	      }
	    ]
	  }'::jsonb
	) AS json_object
)
SELECT 
  element->>'codex_rule_type' AS codex_rule_fired,
  element->>'codex_rule_description' AS value
FROM jsondata,
LATERAL jsonb_array_elements(json_object->'codex_rules_fired') AS element
WHERE element->>'codex_rule_type' = 'Application Score';

select distinct "Type"
from   backoffice.public."XDSCustomerDetailsLog"

with JsonData as (
	select 	xpath('//string/text()', xml(xl."Response") )::text[] as "JsonData"
	from 	backoffice.public."XDSCustomerDetailsLog" xl
	where   xl."Type"  = 'FullVet'
	limit   10
	),
JsonObject as (
	SELECT (jsondata."JsonData")[1]::jsonb AS json_object
	FROM JsonData
)
SELECT 
  element->>'codex_rule_type' AS codex_rule_fired,
  element->>'codex_rule_description' AS value
FROM JsonObject,
LATERAL jsonb_array_elements(json_object->'codex_rules_fired') AS element
WHERE element->>'codex_rule_type' = 'Application Score';

,
JsonObject as (
	select ( JsonData."Text"::jsonb) as JsonObject 
	from Jsondata
)
select * from JsonObject;

select 	rule->>'codex_rule_description' AS application_score
from 	JsonData,
	LATERAL jsonb_array_elements(JsonData->'codex_rules_fired') rule
	WHERE rule->>'codex_rule_type' = 'Application Score';

SELECT rule->>'codex_rule_description' AS application_score
FROM your_table,
LATERAL jsonb_array_elements(json_data->'codex_rules_fired') rule
WHERE rule->>'codex_rule_type' = 'Application Score'

--and     xl."ApplicationId" = '2169146'
;

select * from backoffice.public."XDSCustomerDetailsLog";


CREATE TABLE my_table (
  id serial PRIMARY KEY,
  xml_data xml
);

with Data as (
	select xml('<?xml version="1.0" encoding="utf-16"?><string>"This is a test for extracting string"</string>') xmlData)
select 	xpath('//string/text()', xmldata )::text[] JsonData
from 	Data;

select 	--aa."AccountId", aa."Period", aa."NumOfInstalments" , apf.* 
		
from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf
where   aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
and 	aa."AccountId" in ( 2593394, 235464 );

select 	* 
from 	backoffice.public."ACC_PeriodFrequency" apf ;

with ACC_Account_H as materialized (
	select  aa.* , apf."Description"
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and		aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."LoanStateReasonCode"  in ('H')
)
select distinct acch."Description" , acch."NumOfInstalments"
from   ACC_Account_H acch
order by 1,2;

select 	aam."AccountId" , count(*) 
from 	backoffice.public."Application_AccountMapping" aam 
group by aam."AccountId"
having count(*) >= 2;






