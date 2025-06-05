--This query returns all Accounts opened in the current month and all accounts that has changed in the last 7 days
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	bd.*
from 	  backoffice.public."ACC_Account" aa , 	parameters p 
      , backoffice.public."Application_AccountMapping" aam, backoffice.sqlmig."Application" ap
			, backoffice.sqlmig."BankDetail" bd
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and		  (	aa."OpenDate" between p."StartDate"  and p."EndDate" 
			    or ( aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
					    or aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd")
		    )
and     aa."AccountId" = aam."AccountId"
and     aam."ApplicationId" = ap."ApplicationId"
and     ap."BankDetailId"   = bd."BankDetailId";
