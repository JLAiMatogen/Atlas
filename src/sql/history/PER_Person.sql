--This script return all Account related person records for accounts opened between two dates.
select 	distinct pp.*
from 		backoffice.public."ACC_Account" aa , backoffice.public."PER_Person" pp 
where   aa."LoanType" = 'L'
and     aa."OpenDate" is not null
and     aa."OpenDate" between '{STARTDATE}' and '{ENDDATE}'
and     ( aa."CreatedBy" = pp."PersonId" or aa."PersonId"  = pp."PersonId" );