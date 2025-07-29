--This query returns all Accounts opened between two dates
select 	aa.*
from 	  backoffice.public."ACC_Account" aa 
where   aa."LoanType" = 'L'
and     aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}';