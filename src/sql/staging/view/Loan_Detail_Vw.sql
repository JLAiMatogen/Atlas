drop index staging."Application_AccountMapping_AccountId";
drop index staging."PER_Person_PersonId";
drop index staging."Affordability_ApplicationId";
drop index staging."CreditScore_ApplicationId";
drop index staging."Application_ApplicationId";
drop index staging."BankDetail_BankDetailId";
drop index staging."Quotation_QuotationId";
drop index staging."ACC_Schedules_AccountId";
drop index staging."ACC_Repayment_AccountId";
drop index staging."Client"

create index "Application_AccountMapping_AccountId" on staging."Application_AccountMapping"("AccountId");
create index "PER_Person_PersonId" on staging."PER_Person"("PersonId");
create index "Affordability_ApplicationId" on staging."Affordability"("ApplicationId");
create index "CreditScore_ApplicationId" on staging."CreditScore"("ApplicationId");
create index "Application_ApplicationId" on staging."Application"("ApplicationId");
create index "BankDetail_BankDetailId" on staging."BankDetail"("BankDetailId");
create index "Quotation_QuotationId" on staging."Quotation"("QuotationId");
create index "ACC_Schedules_AccountId" on staging."ACC_Schedules"("AccountId");
create index "ACC_Repayment_AccountId" on staging."ACC_Repayment"("AccountId");
create index "Client_ClientId" on staging."Client"("ClientId");
create index "ACC_DebitOrder_AccountId" on staging."ACC_DebitOrder"("AccountId");

drop view staging."Loan_Detail_vw";

create or replace view staging."Loan_Detail_vw" as
with BureauResponse as materialized (
	select 	sbr.* 
			,	  staging.safe_json_parse(sbr."JsonResponse") "Obj"
	from 		staging."BureauResponse" sbr
	order by sbr."AccountId"
),
ACC_Account as materialized (
	select 	aa.*
			--,   ap."IdNum"
			,		aam."ApplicationId"
			,   pc."Firstname"||' '||pc."Lastname" 	"Consultant"
			,		TO_CHAR(aa."OpenDate", 'YYYYMM') 		"ApplicationMonth"
			, 	apf."Description" as 								"PaymentFrequency"
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
			,		cs."ApplicationScore"
			,   br."Obj"->>'bureau_returned' as "Bureau"
			,   null "OverdueStatus"
	from	staging."ACC_Account" aa
					left outer join	staging."PER_Person" ap
						on aa."PersonId"  = ap."PersonId"
			 		left outer join staging."PER_Person" pc
						on aa."CreatedBy" = pc."PersonId"
					left outer join staging."Application_AccountMapping" aam
						on aa."AccountId" = aam."AccountId" 
					left outer join staging."Affordability" a
						on 	aam."ApplicationId" = a."ApplicationId" 
					left outer join staging."CreditScore" cs 
						on 	aam."ApplicationId"  = cs."ApplicationId"
					left outer join BureauResponse br
						on	aam."AccountId"  		= br."AccountId"
		, 	staging."ACC_PeriodFrequency" apf 
		, 	staging."ACC_LoanStateReason" lsr
	where	aa."PeriodFrequencyId"  = apf."PeriodFrequencyId"
	and   aa."LoanStateReasonCode" = lsr."Code"
	--and   aa."AccountId" = 2685590
),
ACC_DebitOrder as materialized (
	select d.* from (
		select 	ado.*
					,	rank() over (partition by ado."AccountId" order by ado."CreateDate" desc) "IsLatest"
		from 		ACC_Account a, staging."ACC_DebitOrder" ado 
		where   a."AccountId" = ado."AccountId"
	) d
	where d."IsLatest" = 1
),
Application as (
	Select  ac.*
		,   b."BranchName" 
		,		b2."Description" "Debtors_Bank"
		,   ppp2."Description"  "Product"
		,		case when ( q."IsRollOver") then 'Yes' else 'No' end "ROLLd_Loan"
		,   case when ( a."IsGetOfferOverride") then 'Yes' ELSE 'No' end "CDE_Override"
		,   c."IDNumber" "IdNum"
		,   a."ClientCategory"
		,   ado."ServiceProvider"
	from 	ACC_Account ac 
					left outer join staging."Application" a 
						on ac."ApplicationId" = a."ApplicationId"
					left outer join staging."Branch" b
						on	a."BranchId" = b."BranchId" 
					left outer join staging."BankDetail" bd 
						on  a."BankDetailId"   = bd."BankDetailId"
					left outer join staging."Bank" b2 
						on  bd."BankId"  		 = b2."BankId"
					left outer join staging."Quotation" q 
						on	a."QuotationId"    = q."QuotationId"
					left outer join staging."PRD_Products" ppp2 
						on	a."ProductId"      = ppp2."ProductId"  
					left outer join staging."Client" c
						on  a."ClientId"   = c."ClientId"
					left outer join ACC_DebitOrder ado
						on  a."AccountId" = ado."AccountId"
),
ACC_Schedules as materialized (
	select 	as1.* 
			,   case when ( as1."Duedate" <= date_trunc('DAY',now()) ) then 1 else 0 end "IsDue"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) >  as1."Duedate" ) then 1 else 0 end "IsLate"
			,   case when ( coalesce( date_trunc('DAY',as1."PaidDate"),date_trunc('DAY',now())) - INTERVAL '7 DAYS' >  as1."Duedate" ) then 1 else 0 end "IsLate7Days"
			,		ROUND(
  				CASE 
    			WHEN as1."Totalinstallment" = 0 THEN 0
    			ELSE as1."Paid_Installment"::numeric / as1."Totalinstallment" * 100
 	 				END) "Installment_Paid_Perc"
	from 	staging."ACC_Schedules" as1 , Application aa
	where  	as1."AccountId" = aa."AccountId"
	),
LoanDetail as materialized (
	select 	
				aa."AccountId",aa."ApplicationId" , aa."AccountNo" , aa."AccountTypeId", aa."CreateDate" , aa."Consultant"
		, 	as1."Installment_SrNo" 
		,		aa."OpenDate"
		,   TO_CHAR(aa."OpenDate", 'YYYYMM') "ApplicationMonth" 
		,   extract(year from age(now(), aa."OpenDate" )) * 12  + extract(month from age(now(), aa."OpenDate") ) "AgeInMonths"	
		,   aa."NumOfInstalments"
		,   aa."IdNum"
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
		,		as1."Noofdays" , as1."Installment" , as1."Paid_Installment" , as1."Duedate" , as1."PaidDate"  
		, 	as1."IsDue", as1."IsLate", as1."IsLate7Days", as1."Installment_Paid_Perc"
		,   aa."BureauScore"
		,   aa."ApplicationScore"
		,   aa."BranchName" 
		,		aa."Debtors_Bank" 
		,   aa."Product"
		,		aa."ROLLd_Loan"
		,   aa."CDE_Override"
		,   aa."Bureau"
		,   aa."ClientCategory"
		,   aa."ServiceProvider"
		,   aa."OverdueStatus"
	from 	Application aa left outer join  ACC_Schedules as1 
						on  aa."AccountId" = as1."AccountId"
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
		,	case when ( ld."IsDue" = 1 and ld."IsLate7Days" = 1 ) then ld."Duedate" 
			else null
			end  "ArrearDate"
		,  	ld."PaymentFrequency"
		,   ld."Loan_Size"
		,		ld."Loan_Term"
		,		ld."OpenDate" + interval '3 MONTHS' "3MonthsOldAt"
		,   ld."AccountId",ld."ApplicationId", ld."Installment_SrNo", ld."OpenDate", ld."ApplicationMonth" "OpenMonth", ld."IdNum", ld."Consultant"
		,   ld."LoanStateReasonCode"
		, 	ld."Duedate"
		, 	ld."PaidDate"
		,   ld."NumOfInstalments"
		,		ld."LoanType"
		,   ld."BureauScore"
		,   ld."ApplicationScore"
		,		ld."BranchName"
		,   ld."Debtors_Bank" 
		,   ld."Product"
		,	  ld."ROLLd_Loan"
		,   ld."CDE_Override"
		,   ld."Bureau"
		,   ld."ClientCategory"
		,   ld."ServiceProvider"
		,   ld."OverdueStatus"
	from 	LoanDetail ld
	),
FinalAccountMetrix as (
	select 	
			fld."OpenMonth" 
		,	fld."AccountId"
		,	fld."ApplicationId"
		,	fld."OpenDate"
		,	fld."IdNum"
		, fld."Consultant" 
		, fld."NumOfInstalments"
		, fld."LoanType" "AccountType"
		, fld."PaymentFrequency"
		, fld."Loan_Size"
		, fld."Loan_Term"
		, fld."HandedOver_Ind" "HandedOver"
		, min(fld."ArrearDate") "FirstArrearDate"
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
		, fld."Bureau"
		, fld."ClientCategory"
		, fld."ServiceProvider"
		, fld."OverdueStatus"
	from	FinalLoanDetail fld
	group by 	
			fld."OpenMonth" 
		,	fld."AccountId"
		, fld."ApplicationId"
		, fld."OpenDate"
		, fld."IdNum"
		, fld."Consultant" 
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
		, fld."Bureau"
		, fld."ClientCategory"
		, fld."ServiceProvider"
		, fld."OverdueStatus"
)
select * from FinalAccountMetrix;

select * from "Loan_Detail_vw" ldv 
