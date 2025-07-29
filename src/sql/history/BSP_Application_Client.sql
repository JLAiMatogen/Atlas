--This query returns all Application_AccountMapping for applications between between two dates
select 	aam.* 
from 		backoffice.sqlmig."Application" a , backoffice.sqlmig."Application_Client" aam
where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     a."ApplicationClientId" =  aam."ApplicationClientId";
