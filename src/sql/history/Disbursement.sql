--This query returns all Accounts opened between two dates
select 	distinct d.*
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Disbursement" d
where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     a."DisbursementId"  = d."DisbursementId"