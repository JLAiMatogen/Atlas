--This query returns all Account information on payment Schedules opened between two dates
select 	as1.*
from 	  backoffice.public."ACC_Account" aa , backoffice.public."ACC_Schedules" as1
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and     aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}'
and  		as1."AccountId" = aa."AccountId";