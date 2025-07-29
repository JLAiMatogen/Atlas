--This query returns all Account Bank detail records for Accounts opened between two dates
select 	bd.*
from    backoffice.sqlmig."Application" ap, backoffice.sqlmig."BankDetail" bd
where   ap."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     ap."BankDetailId" = bd."BankDetailId";
