--This query returns all Account information on Repayments opened between two dates
select 	ar.*
from 	  backoffice.public."ACC_Account" aa , backoffice.public."ACC_Repayment" ar
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and     aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}'
and  		ar."AccountId" = aa."AccountId";