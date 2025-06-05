--Build in relation to Account mapping extract
--Loan Detail Query, run only for period of max 6 months, due to memory pool exceptions.
--Build in relation to Account mapping extract
--Loan Detail Query, run only for period of max 6 months, due to memory pool exceptions.
--Build in relation to Account mapping extract
--Loan Detail Query, run only for period of max 6 months, due to memory pool exceptions.
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
),
ACC_Account as materialized (
	select 	aa.*
		,   ap."IdNum"
		,	aam."ApplicationId"
		,   pc."Firstname"||' '||pc."Lastname" "Consultant"
		,	TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth"
		, 	apf."Description" as "PaymentFrequency"
		,   case 
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
		,   case 
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
			else	'10000 +' 
			end  "Loan_Size"
		,   case when ( aa."LoanStateReasonCode"  in ('H') ) then 1 else 0 end "HandedOver" 
		, 	a."NLRScore" "BureauScore"
		,	cs."ApplicationScore"
	from   	parameters p
		,	backoffice.public."ACC_Account" aa
		, 	backoffice.public."PER_Person" pc, backoffice.public."ACC_PeriodFrequency" apf , backoffice.public."ACC_LoanStateReason" lsr
		,   backoffice.public."PER_Person" ap
		,	backoffice.public."Application_AccountMapping" aam
				left outer join backoffice.sqlmig."Affordability" a
					on aam."ApplicationId" = a."ApplicationId" 
				left outer join backoffice.sqlmig."CreditScore" cs 
					on aam."ApplicationId"  = cs."ApplicationId"
	where  	--TO_CHAR(aa."OpenDate", 'YYYYMM')  = '202412'
		  	--aa."OpenDate" between '2025-01-01' AND '2025-01-31'
			--aa."OpenDate" between '{STARTDATE}' AND '{ENDDATE}'
			--aa."AccountId"  = 4659929
			aa."OpenDate" is not null
	and		(	
				aa."OpenDate" between p."StartDate"  and p."EndDate" 
			    or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					    or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd")
		    )
	and    	aa."LoanType" = 'L'
	and     aa."AccountId" = aam."AccountId"
	and     aa."CreatedBy" = pc."PersonId" 
	and     aa."PersonId"  = ap."PersonId"
	and     aa."PeriodFrequencyId"  = apf."PeriodFrequencyId"
	and     aa."LoanStateReasonCode" = lsr."Code"
	order by TO_CHAR(aa."OpenDate", 'YYYYMM')
),
Application as (
	Select  ac.*
		--,	a."ApplicationId"
		--,	a."AccountId"
		,   b."BranchName" 
		,	b2."Description" "Debtors_Bank"
		,   ppp2."Description"  "Product"
		,		case when ( q."IsRollOver") then 'Yes' else 'No' end "ROLLd_Loan"
		,   case when ( a."IsGetOfferOverride") then 'Yes' ELSE 'No' end "CDE_Override"
	from 	ACC_Account ac 
					left outer join backoffice.sqlmig."Application" a 
						on ac."ApplicationId" = a."ApplicationId"
					left outer join backoffice.sqlmig."Branch" b
						on	a."BranchId" = b."BranchId" 
					left outer join backoffice.Sqlmig."BankDetail" bd 
						on  a."BankDetailId"   = bd."BankDetailId"
					left outer join backoffice.sqlmig."Bank" b2 
						on  bd."BankId"  		 = b2."BankId"
					left outer join backoffice.Sqlmig."Quotation" q 
						on	a."QuotationId"    = q."QuotationId"
					left outer join backoffice.public."PRD_Products" ppp2 
						on	a."ProductId"      = ppp2."ProductId"
),
ACC_Schedules as materialized (
	select 	as1.* 
			--,	as1."Duedate"
			--,   as1."PaidDate"
			,   case when ( as1."Duedate" <= date_trunc('DAY',now()) ) then 1 else 0 end "IsDue"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) >  as1."Duedate" ) then 1 else 0 end "IsLate"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  as1."Duedate" ) then 1 else 0 end "IsLate7Days"
			--,		round(as1."Paid_Installment" / as1."Totalinstallment" * 100) "Installment_Paid_Perc"
			,		ROUND(
  				CASE 
    			WHEN as1."Totalinstallment" = 0 THEN 0
    			ELSE as1."Paid_Installment"::numeric / as1."Totalinstallment" * 100
 	 				END) "Installment_Paid_Perc"
	from 	backoffice.public."ACC_Schedules" as1 , Application aa
	where  	as1."AccountId" = aa."AccountId"
	--and     aa."LoanStateReasonCode"  in ('H','W','D','I','P')
	),
ACC_Repayment as materialized (
	select 	as1.* 
	from 	backoffice.public."ACC_Repayment" as1, Application aa
	where  	as1."AccountId" = aa."AccountId"
	--and     aa."LoanStateReasonCode"  in ('H','W','D','I','P')
	),
LoanDetail as materialized (
	select 	
				aa."AccountId",aa."ApplicationId" , aa."AccountNo" , aa."AccountTypeId", aa."CreateDate" , aa."Consultant"
		, 	as1."Installment_SrNo" 
		,		aa."OpenDate"
		,   TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth" 
		,   aa."NumOfInstalments"
		,   aa."IdNum"
		,   extract(year from age(now(), aa."OpenDate" )) * 12  + extract(month from age(now(), aa."OpenDate") ) "AgeInMonths"
		,   aa."LoanType"
		, 	aa."CloseDate" , aa."LoanAmount"  , aa."Period" 
		,	  aa."LoanStateReasonCode"
		,	  aa."HandoverAmount" 
		,   aa."HandoverDate" 
		,   aa."PersonId" , aa."ClientId"
		,   aa."PaymentFrequency"
		,   aa."Loan_Term"
		,   aa."HandedOver" 
		,   aa."Loan_Size"
		,	as1."Noofdays" , as1."Installment" , as1."Paid_Installment" , as1."Duedate" , as1."PaidDate"  
		, 	as1."IsDue", as1."IsLate", as1."IsLate7Days", as1."Installment_Paid_Perc"
		,   aa."BureauScore"
		,   aa."ApplicationScore"
		,   aa."BranchName" 
		,		aa."Debtors_Bank" 
		,   aa."Product"
		,		aa."ROLLd_Loan"
		,   aa."CDE_Override"
	from 	Application aa left outer join  ACC_Schedules as1 
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
	select  ld."HandedOver" "HandedOver_Ind"
		,	case when ( ld."Installment_SrNo" = 1 ) then
				case
				when ( ld."IsDue" = 1 and ld."IsLate" = 1 ) then 1
				when ( ld."IsDue" = 1 and ld."Installment_Paid_Perc" < 85) then 1
				else 0
				end
			else 0 
			end "FirstDueDate_Missed_Ind"
		,	case when ( ld."Installment_SrNo" = 1 ) then
				case
				when ( ld."IsDue" = 1 and ld."IsLate7Days" = 1 ) then 1
				when ( ld."IsDue" = 1 and ld."Installment_Paid_Perc" < 85) then 1
				else 0
				end 
			else 0 
			end "FirstInstalment_Default_Ind"
		,	case 
			when ( ld."AgeInMonths" < 3  ) then null 
			when ( ld."Installment_SrNo" <= 3 ) then
				case
				when ( ld."IsDue" = 1 and ld."IsLate7Days" = 1 ) then 1
				when ( ld."IsDue" = 1 and ld."Installment_Paid_Perc" < 85) then 1
				else 0
				end 
			else 0
			end "InstallmentMissed_First3Months_Ind"
		--,	case 
		--	when ( ld."AgeInMonths" <3  ) then null 
		--	when ( ld."Installment_SrNo" <= 3 
		--			and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
		--			and ld."AgeInMonths" > 3 then 1 
		--	else 0
		--	end "InstallmentMissed_First3Months_Ind"
		,	case 
			when ( ld."AgeInMonths" < 6  ) then null 
			when ( ld."Installment_SrNo" <= 6 ) then
				case
				when ( ld."IsDue" = 1 and ld."IsLate7Days" = 1 ) then 1
				when ( ld."IsDue" = 1 and ld."Installment_Paid_Perc" < 85) then 1
				else 0
				end 
			else 0
			end "InstallmentMissed_First6Months_Ind"
		--,	case 
		--	when ( ld."AgeInMonths" < 6 ) then null 
		--	when ( ld."Installment_SrNo" <= 6 
		--			and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
		--			and ld."AgeInMonths" > 6	then 1 
		--	else 0 
		--	end "InstallmentMissed_First6Months_Ind"
		,  	ld."PaymentFrequency"
		,   ld."Loan_Size"
		,		ld."Loan_Term"
		,		ld."OpenDate" + interval '3 MONTHS' "3MonthsOldAt"
		,   ld."AgeInMonths"
		,   ld."AccountId",ld."ApplicationId", ld."Installment_SrNo", ld."OpenDate", ld."ApplicationMonth" "OpenMonth", ld."IdNum", ld."Consultant"
		,   ld."LoanStateReasonCode"
		,		ld."FirstArrearDate"
		, 	ld."Duedate"
		, 	ld."PaidDate"
		,   ld."PaymentModeId", ld."PaymentCode", ld."PaymentDescription"
		,   ld."NumOfInstalments"
		,		ld."LoanType"
		,   ld."BureauScore"
		,   ld."ApplicationScore"
		,		ld."BranchName"
		,   ld."Debtors_Bank" 
		,   ld."Product"
		,	  ld."ROLLd_Loan"
		,   ld."CDE_Override"
	from 	LoanAndPaymentDetail ld
	),
FinalAccountMetrix as (
	select 	
			fld."OpenMonth" 
		,	fld."AccountId"
		,	fld."ApplicationId"
		,	fld."OpenDate"
		,	fld."IdNum"
		, fld."Consultant" 
		,	fld."AgeInMonths"
		, fld."NumOfInstalments"
		, fld."LoanType" "AccountType"
		, fld."PaymentFrequency"
		, fld."Loan_Size"
		, fld."Loan_Term"
		, fld."HandedOver_Ind" "HandedOver"
		,	max(fld."FirstDueDate_Missed_Ind")	"FirstDueDate_Missed_Flag"
		,	max(fld."FirstInstalment_Default_Ind") "FirstInstalment_Default_Flag"
		, case when 
				sum( fld."InstallmentMissed_First3Months_Ind" ) >= 1 then 1
			else 0 
			end "One_ever_3_Flag"
		, case when 
				sum( fld."InstallmentMissed_First6Months_Ind" ) >= 2	then 1
			else 0 
			end "Two_ever_6_Flag"
		, fld."BureauScore"
		, fld."ApplicationScore"
		,	fld."BranchName"
		, fld."Debtors_Bank" 
		, fld."Product"
		,	fld."ROLLd_Loan"
		, fld."CDE_Override"
	from	FinalLoanDetail fld
	group by 	
			fld."OpenMonth" 
		,	fld."AccountId"
		, fld."ApplicationId"
		, fld."OpenDate"
		, fld."IdNum"
		, fld."Consultant" 
		, fld."AgeInMonths"
		, fld."NumOfInstalments"
		, fld."LoanType"
		, fld."PaymentFrequency"
		, fld."Loan_Size"
		, fld."Loan_Term"
		,	fld."HandedOver_Ind" 
		, fld."BureauScore"
		, fld."ApplicationScore"
		,	fld."BranchName"
		, fld."Debtors_Bank" 
		, fld."Product"
		,	fld."ROLLd_Loan"
		, fld."CDE_Override"
)
select * from FinalAccountMetrix
order by 1 , 2 , 3;

--and     aa."LoanStateReasonCode"  in ('H','W','D','I','P')


--Take on procedure for all Accounts
--Parameters to be used
-- Start Date
-- End Date
-- Days prior to Start Date for Status change and close dates


--Account view to detremiine the accounts affected

with ACC_Account as (
	select  TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth", aa."OpenDate", aa."AccountId" , aa."AccountNo" , aa."StatusChangeDate", aa."LoanStateReasonCode" , aa."CloseDate" 
		--, 	lr."Description"
	from	backoffice.public."ACC_Account" aa --, backoffice.public."ACC_LoanStateReason" lr
	--where   aa."OpenDate" between '2025-01-01' AND '2025-01-31';
	where   aa."LoanType" = 'L'
	and     aa."OpenDate" is not null
	and		(	aa."OpenDate" between '2025-05-01' and '2025-05-31'
				or ( aa."StatusChangeDate" between '2025-04-21' and '2025-04-30' 
					or aa."CloseDate" between '2025-04-21' and '2025-04-30'
					)
			)
	--and     aa."LoanStateReasonCode" = lr."Code"
	order by aa."OpenDate"
)
select "ApplicationMonth", count(*) 
from 	ACC_Account a
group by "ApplicationMonth"
order by 1;

select * from backoffice.public."ACC_Account" aa
where  ( aa."StatusChangeDate" between '2025-04-21' and '2025-04-30' 
					or aa."CloseDate" between '2025-04-21' and '2025-04-30' )
and    aa."OpenDate" is null;

select * 
from backoffice.public."ACC_LoanStateReason";

select * from backoffice.sqlmig."LoanReason";

select 	Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '00 months') START_DATE
	,	Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '-1 months') END_DATE
	,	aa.* 
from 	backoffice.public."ACC_Account" aa
where  	aa."AccountId"  = 4854053	;


with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	(date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	aa.*
from 	backoffice.public."ACC_Account" aa , 	parameters p
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and		(	aa."OpenDate" between p."StartDate"  and p."EndDate" 
			or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd"
					)
		);


with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	pp.*
from 	backoffice.public."ACC_Account" aa , parameters p , backoffice.public."PER_Person" pp 
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and		  (	aa."OpenDate" between p."StartDate"  and p."EndDate" 
			    or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd"
				)
		    )
and     ( aa."CreatedBy" = pp."PersonId" or aa."PersonId"  = pp."PersonId" )
;


with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	(date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
),;

with Application as materialized (
    select  aa."AccountId" 
    	, 	TO_CHAR(aa."OpenDate", 'YYYYMMDD') "ApplicationDate"
		,  	aam."ApplicationId"::TEXT
    from    backoffice.public."ACC_Account" aa  , backoffice.public."Application_AccountMapping" aam
    where   aa."LoanType" = 'L'
	and     aa."OpenDate" is not null
	and     aa."OpenDate" >= CURRENT_DATE - INTERVAL '7 days' 
    and     aa."AccountId" = aam."AccountId"
),
Response as (
    Select  a."ApplicationDate"
    	,	a."AccountId" 
		,	a."ApplicationId"  
		, 	xds."IdNumber"
		,	xds."Type" 
		, 	CASE
				WHEN xds."Response" IS NOT NULL AND xds."Response" ~ '<.+>' THEN
						((xpath('//string/text()', xds."Response"::xml))[1])::TEXT::jsonb
				ELSE NULL
			END AS "Obj"
    from    Application a , backoffice.public."XDSCustomerDetailsLog" xds
    where   a."ApplicationId" = xds."ApplicationId"
    and     xds."Response" LIKE '%rule_selected_bureau%'
)
select    r."ApplicationDate"	
		, r."AccountId" 			
		, r."ApplicationId" 	
		, r."IdNumber" 				
		, r."Type" 						
    , r."Obj"->>'bureau_returned' as "bureau_returned"
    , r."Obj"->>'score' as "bureau_score"
from    Response r;



with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	aam.*
from 	  backoffice.public."ACC_Account" aa , 	parameters p , backoffice.public."Application_AccountMapping" aam
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and		  (	aa."OpenDate" between p."StartDate"  and p."EndDate" 
			    or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					    or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd")
		    )
and     aa."AccountId" = aam."AccountId";


--This query returns all Accounts opened in the current month and all accounts that has changed in the last 7 days
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	cs.*
from 	  backoffice.public."ACC_Account" aa , 	parameters p 
      , backoffice.public."Application_AccountMapping" aam, backoffice.sqlmig."CreditScore" cs
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and		  (	aa."OpenDate" between p."StartDate"  and p."EndDate" 
			    or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					    or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd")
		    )
and     aa."AccountId" = aam."AccountId"
and     aam."ApplicationId" = cs."ApplicationId";

--This query returns all Accounts opened in the current month and all accounts that has changed in the last 7 days
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	q.*
from 	  backoffice.public."ACC_Account" aa , 	parameters p 
      , backoffice.public."Application_AccountMapping" aam, backoffice.sqlmig."Application" ap
      , backoffice.sqlmig."Quotation" q
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and		  (	aa."OpenDate" between p."StartDate"  and p."EndDate" 
			    or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					    or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd")
		    )
and     aa."AccountId" = aam."AccountId"
and     aam."ApplicationId" = ap."ApplicationId"
and     ap."QuotationId" = q."QuotationId";

with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	distinct pp.*
from 	backoffice.public."ACC_Account" aa , parameters p , backoffice.public."PER_Person" pp 
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and		  (	aa."OpenDate" between p."StartDate"  and p."EndDate" 
			    or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd"
				)
		    )
and     ( aa."CreatedBy" = pp."PersonId" or aa."PersonId"  = pp."PersonId" );


Select  *
from    backoffice.public."XDSCustomerDetailsLog" xds
where   "ApplicationId" = '3724207'	
and     xds."Response" LIKE '%rule_selected_bureau%';


with Application as materialized (
  select  aa."AccountId" 
      , 	TO_CHAR(aa."OpenDate", 'YYYYMMDD') "ApplicationDate"
		  ,  	aam."ApplicationId"::TEXT
  from    backoffice.public."ACC_Account" aa  , backoffice.public."Application_AccountMapping" aam
  where   aa."LoanType" = 'L'
	and     aa."OpenDate" is not null
	and     aa."OpenDate" >= CURRENT_DATE - INTERVAL '10 days' 
  and     aa."AccountId" = aam."AccountId"
  and     aam."ApplicationId" = 3724207
),
Response as (
    Select  a."ApplicationDate"
    	    ,	a."AccountId" 
		      ,	a."ApplicationId"  
		      , 	xds."IdNumber"
		      ,	xds."Type" 
          , 	CASE
              WHEN xds."Response" IS NOT NULL AND xds."Response" ~ '<.+>' THEN
                  ((xpath('//string/text()', xds."Response"::xml))[1])::TEXT::jsonb
              ELSE NULL
            END AS "Obj"
          , dense_rank() over ( partition by xds."ApplicationId" order by "InsertTime" desc ) ranking
    from    Application a , backoffice.public."XDSCustomerDetailsLog" xds
    where   a."ApplicationId" = xds."ApplicationId"
    and     xds."Type" = 'PreVet'
    and     xds."Response" LIKE '%rule_selected_bureau%'
)
select  r."ApplicationDate"	
		  , r."AccountId" 			
		  , r."ApplicationId" 	
		  , r."IdNumber" 				
		  , r."Type" 						
      , r."Obj"->>'bureau_returned' as "bureau_returned"
      , r."Obj"->>'score' as "bureau_score"
from    Response r
where   ranking = 1;


select * from backoffice.public."XDSCustomerDetailsLog" xds
where  xds."ApplicationId" = '3724207';