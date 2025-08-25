--This query returns all Accounts opened in the current month and all accounts that has changed in the last 7 days
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	ar.*
from 	  backoffice.public."ACC_Account" aa , 	parameters p , backoffice.public."ACC_Repayment" ar
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and     (  		aa."CloseDate" is null
					or 	aa."CloseDate" between p."SevenDaysPriorStart" and p."EndDate"
					or  aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."EndDate" 
			)
and  	ar."AccountId" = aa."AccountId";