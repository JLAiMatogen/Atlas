--This query returns all Application information regarding the affordability opened between two dates
select 	aff.*
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Affordability" aff
where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     a."ApplicationId" = aff."ApplicationId";
