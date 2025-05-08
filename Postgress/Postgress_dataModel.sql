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


--Total Take-up
with TotalAccounts as materialized (
	select 	TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth"
		, 	apf."Description" as "PaymentFrequency"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
		, 	count(*) "Total" 
	from   	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf 
	where  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	group by TO_CHAR(aa."OpenDate", 'YYYYMM')
		,	apf."Description"
		,	case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end
)

--Bad Rate indicators
--FirstDueDate_MissedRate
--FirstInstalment_DefaultRate
--"1+ever@3
--2+ever@6
			

select count(*) from backoffice.public."ACC_Account" aa
where  aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
and    aa."LoanType" = 'L'
and    aa."LoanStateReasonCode" = alsr."Code";

--Total Take-up
--create materialized view AI_MATOGEN_BADRATE as
with  as materialized (
	select 	TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth"
		, 	apf."Description" as "PaymentFrequency"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
		--, 	count(*) "Total" 
	from   	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf 
	where  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	--group by TO_CHAR(aa."OpenDate", 'YYYYMM')
 	--	,	apf."Description"
	--	,	case 
	--		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
	--		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
	--		when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
	--		else	'+1 Year'
	--		end
),
ACC_Account as materialized (
	select  aa.* , apf."Description" as "PaymentFrequency" 
		,   apf."DaysInOneTerm"
		,   aa."NumOfInstalments" * apf."DaysInOneTerm" "LoanTerm_Days"
		,   case 
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 0   and 90  then '0-90 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 91  and 180 then '91-180 Days'
			when ( aa."NumOfInstalments" * apf."DaysInOneTerm") between 181 and 360 then '181-360 Days'
			else	'+1 Year'
			end  "Loan_Term"
		--,	lsr."Description" "LoanStateReason"
	from 	backoffice.public."ACC_Account" aa , backoffice.public."ACC_PeriodFrequency" apf , backoffice.public."ACC_LoanStateReason" lsr
	where  	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId" 
	and  	aa."OpenDate" >= Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '15 months')
	and    	aa."LoanType" = 'L'
	and     aa."LoanStateReasonCode"  in ('H','W','D','I','P')
	and     aa."LoanStateReasonCode" = lsr."Code"
),
--ACC_Creditbureau_Response as (
--	select 	aa."AccountId" , aam."ApplicationId" , count(*)
--		--,	xpath('//string/text()', xml(xl."Response") )::text[] as  "JsonData"
--	from 	ACC_Account aa, backoffice.public."Application_AccountMapping" aam 
--				left outer join backoffice.public."XDSCustomerDetailsLog" xl
--				on	cast(aam."ApplicationId" as varchar) = xl."ApplicationId"
--				and     xl."Type"  		= 'FullVet'
--	where   aa."AccountId" 		= aam."AccountId"
--	group by aa."AccountId" , aam."ApplicationId"
--)
--select acrr."AccountId" , acrr."ApplicationId" , count(*)
--from ACC_Creditbureau_Response acrr
--group by acrr."AccountId" , acrr."ApplicationId"
--having count(*) >= 2;
--77250
--* from ACC_Creditbureau_Response;
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
		,	as1."Noofdays" , as1."Installment" , as1."Paid_Installment" , as1."Duedate" , as1."PaidDate" 
	from 	ACC_Account aa left outer join  ACC_Schedules as1 
						on  aa."AccountId" = as1."AccountId"
	),
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
						  			--and ar."PaymentModeId" in (10,11) 
),
FinalLoanDetail as materialized (
	select 	
		    case when ( ld."Installment_SrNo" = 1 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) >  ld."Duedate" )
			then 1 else 0 end "FirstDueDate_MissedRate"
		,	case when ( ld."Installment_SrNo" = 1 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
			then 1 else 0 end "FirstInstalment_DefaultRate"
		,	case 
			when ( ld."AgeInMonths" <=3  ) then null 
			when ( ld."Installment_SrNo" <= 3 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
					and ld."AgeInMonths" > 3 then 1 
			else 0 
			end "InstallmentMissed_First3Months"
		,	case 
			when ( ld."AgeInMonths" <= 6 ) then null 
			when ( ld."Installment_SrNo" <= 6 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
					and ld."AgeInMonths" > 6	then 1 
			else 0 end "InstallmentMissed_First6Months"
		,	ld."PaymentFrequency"
		,	ld."LoanTerm_Days"
		,   ld."Loan_Term"
		--,	ld."OpenDate" + interval '3 MONTHS' "3MonthsOldAt"
		,   ld."AgeInMonths"
		,   ld."AccountId", ld."Installment_SrNo", ld."OpenDate", ld."ApplicationMonth"
		,   ld."LoanStateReasonCode"
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
		,   fld."NumOfInstalments"
		,   fld."LoanType"
		,   fld."PaymentFrequency"
		,   fld."Loan_Term"
)
select 	fm."ApplicationMonth" 
	,   fm."PaymentFrequency"
	,   fm."Loan_Term"
	,   'Unknown' as "Bureau"
	,   min(ta."Total") Total_Takup
	, 	count(*) "TotalArrears"
	,   sum(fm."FirstDueDate_Missed_Flag") as "FirstDueDate_Missed_Count"
	,   sum(fm."FirstInstalment_Default_Flag") as "FirstInstalment_Default_Count"
	,	sum(fm."1+ever@3_Flag") as "1+ever@3_Count"
	,	sum(fm."2+ever@6_Fag") as "2+ever@6_Count"
from 	FinalAccountMetrix fm , TotalAccounts ta
where   fm."ApplicationMonth" = ta."ApplicationMonth"
and		fm."PaymentFrequency" = ta."PaymentFrequency"
and		fm."Loan_Term"        = ta."Loan_Term"
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


select 	xpath('//string/text()', xml(xl."Response") )::text[] as  "JsonData"
from 	backoffice.public."XDSCustomerDetailsLog" xl
where   xl."Type"  = 'FullVet'
limit   10
--and     xl."ApplicationId" = '2169146'
;


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

select * from "Application_AccountMapping" aam 



