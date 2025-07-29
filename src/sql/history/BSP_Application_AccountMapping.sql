--This query returns all Application_AccountMapping for applications between between two dates
select 	aam.* 
from 		backoffice.sqlmig."Application" a , backoffice.public."Application_AccountMapping" aam
where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     a."ApplicationId" = aam."ApplicationId";