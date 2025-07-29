--This query returns all Account Debit Orders for accounts opened between two dates.
select  psh.*
from    backoffice.public."ACC_Account" aa 
      , backoffice.public."ACC_PaymentStatusHistory" psh
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and     aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}'
and     aa."AccountId" = psh."AccountId";