--This query returns all Account Debit Orders for accounts open between two dates.
with parameters as (
  select  date_trunc('month', CURRENT_DATE)::date AS "StartDate"
        , (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
        , (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
        , (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	ado.*
from 	  backoffice.public."ACC_Account" aa , parameters p , backoffice.public."ACC_DebitOrder" ado 
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and     (  		aa."CloseDate" is null
          or 	aa."CloseDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd"
          or  aa."StatusChangeDate" between p."SevenDaysPriorStart" and p."SevenDaysPriorEnd" 
        )
and     aa."AccountId" = ado."AccountId";