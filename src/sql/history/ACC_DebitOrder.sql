--This query returns all Account Debit Orders for accounts opened between two dates.
select  ado.*
from    backoffice.public."ACC_Account" aa 
      , backoffice.public."ACC_DebitOrder" ado 
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and     aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}'
and     aa."AccountId" = ado."AccountId";