--This query returns all Accounts opened between two dates
select 	distinct adr.*
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Employer" adr
where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     a."EmployerId" = adr."EmployerId";    