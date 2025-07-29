--This query returns all Accounts opened between two dates
select 	q.*
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Quotation" q
where   q."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     a."QuotationId" = q."QuotationId";