--Build in relation to Account mapping extract
--Loan Detail Query, run only for period of max 6 months, due to memory pool exceptions.
with ACC_Account as materialized (
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
	from   	backoffice.public."ACC_Account" aa
		, 	backoffice.public."PER_Person" pc, backoffice.public."ACC_PeriodFrequency" apf , backoffice.public."ACC_LoanStateReason" lsr
		,   backoffice.public."PER_Person" ap
		,	backoffice.public."Application_AccountMapping" aam
				left outer join backoffice.sqlmig."Affordability" a
					on aam."ApplicationId" = a."ApplicationId" 
				left outer join backoffice.sqlmig."CreditScore" cs 
					on aam."ApplicationId"  = cs."ApplicationId"
	where  	--TO_CHAR(aa."OpenDate", 'YYYYMM')  = '202412'
		      --aa."OpenDate" between '2025-01-01' AND '2025-01-31'
					aa."OpenDate" between '{STARTDATE}' AND '{ENDDATE}'
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
			,   case when ( as1."Duedate" <= date_trunc('DAY',now()) ) then 1 else 0 end "IsDue"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) >  as1."Duedate" ) then 1 else 0 end "IsLate"
			,		round(as1."Paid_Installment" / as1."Totalinstallment" * 100) "Installment_Paid_Perc"
	from 	backoffice.public."ACC_Schedules" as1 , Application aa
	where  	as1."AccountId" = aa."AccountId"
	--and     aa."LoanStateReasonCode"  in ('H','W','D','I','P')
	)
,
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
		,		as1."Noofdays" , as1."Installment" , as1."Paid_Installment" , as1."Duedate" , as1."PaidDate"  , as1."Installment_Paid_Perc"
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
		,	case when ( ld."Installment_SrNo" = 1 and ld."Duedate" <= date_trunc('DAY',now())
								and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) >  ld."Duedate" )
						 -- Has the due date passed on the first installment
			then 1 
			else 0 
			end "FirstDueDate_Missed_Ind"
		,	case when ( ld."Installment_SrNo" = 1 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
					and ld."Duedate" + INTERVAL '7 DAYS' < date_trunc('DAY',now()) -- Has the due date passed on the first installment
			then 1 
			else 0 
			end "FirstInstalment_Default_Ind"
		,	case 
			when ( ld."AgeInMonths" <3  ) then null 
			when ( ld."Installment_SrNo" <= 3 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
					and ld."AgeInMonths" > 3 then 1 
			else 0
			end "InstallmentMissed_First3Months_Ind"
	,		case 
			when ( ld."AgeInMonths" < 6 ) then null 
			when ( ld."Installment_SrNo" <= 6 
					and	coalesce( date_trunc('DAY',ld."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  ld."Duedate" )
					and ld."AgeInMonths" > 6	then 1 
			else 0 
			end "InstallmentMissed_First6Months_Ind"
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