--Required information
--Loan Date
--ID Number
--Loan Amount
--Number of Installments

--1 Ever 3 Flag per account
--2 Ever 6
--Installments Received (Detail records)
--Install Amount
--Installmanet Paid amount
--Interest Rate

--All data up to current.

create materialized view "Account_CashFlow_mv" as
select 	aa."AccountId" , aa."OpenDate" , aa."CloseDate", aa."NumOfInstalments", aa."LoanAmount" , aa."InterestRate"
		, 	aa."LoanStateReasonCode" , alsr."Description" 
		, 	c."Firstname" , c."Surname" , c."IDNumber"  
		--,   ash."Installment_SrNo" , ash."Duedate" , ash."Totalinstallment" , ash."Paid_Installment"  , ash."PaidDate" 
		,   ar."RepaymentDate" 
		--,   ar."RepaymentAmount"
		, 	replace(replace(REPLACE(ar."RepaymentAmount", 'R', ''),' ',''),',','.') as "RepaymentAmount"
		,   abr."One_ever_3_Flag" , abr."Two_ever_6_Flag" 
from  	"ACC_Account" aa
				left outer join "Account_BadRate_Indicators" abr
					on aa."AccountId" = abr."AccountId"
				left outer join "Client" c
					on aa."ClientId" = c."ClientId"
				--left outer join "ACC_Schedules" ash
				--	on aa."AccountId"  = ash."AccountId" 
				left outer join  prod."ACC_Repayment" ar
					on 	aa."AccountId"  = ar."AccountId" 
					--and	ash."Installment_SrNo" = ar."InstallmentNo"
					and ar."RepaymentAmount" is not null
--where   ash."Paid_Installment"  != ash."Totalinstallment" 
			,	prod."ACC_LoanStateReason" alsr 
--where  aa."AccountId"  = '4156436';
where 	aa."LoanStateReasonCode"  = alsr."Code" 
--and     aa."AccountId"  = '4125122'
--and      aa."OpenDate" >= '2024-01-01'
--order by ar."RepaymentDate"
;

select count(*) from "Account_CashFlow_mv";


--This is on the Schedules. Not reliable due to data inconsistancies.
select  aa."AccountId" , aa."OpenDate" , aa."CloseDate", aa."NumOfInstalments", aa."LoanAmount" , aa."InterestRate"
                ,       aa."LoanStateReasonCode" , alsr."Description" 
                ,       c."Firstname" , c."Surname" , c."IDNumber"  
                ,   ash."Installment_SrNo" , ash."Duedate" , ash."Totalinstallment" , ash."Paid_Installment"  , ash."PaidDate" 
                --,   ar."RepaymentDate" 
                --,   ar."RepaymentAmount"
                --,     replace(replace(REPLACE(ar."RepaymentAmount", 'R', ''),' ',''),',','.') as "RepaymentAmount"
                ,   abr."One_ever_3_Flag" , abr."Two_ever_6_Flag" 
from    "ACC_Account" aa
                                left outer join "Account_BadRate_Indicators" abr
                                        on aa."AccountId" = abr."AccountId"
                                left outer join "Client" c
                                        on aa."ClientId" = c."ClientId"
                                left outer join "ACC_Schedules" ash
                                        on aa."AccountId"  = ash."AccountId" 
                                --left outer join  prod."ACC_Repayment" ar
                                --      on      aa."AccountId"  = ar."AccountId" 
                                --      and     ash."Installment_SrNo" = ar."InstallmentNo"
                                --      and ar."RepaymentAmount" is not null
--where   ash."Paid_Installment"  != ash."Totalinstallment" 
                        ,       prod."ACC_LoanStateReason" alsr 
--where  aa."AccountId"  = '4156436';
where   aa."AccountId"  = '4125122'
and     aa."LoanStateReasonCode"  = alsr."Code" 
order by ash."Installment_SrNo",ash."Duedate"  ;


