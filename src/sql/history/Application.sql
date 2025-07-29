--This query returns all Accounts opened between two dates
With ApplicationData as (
  select 	a.*
        , lag(a."CreateDate") over (partition by c."IDNumber" order by a."CreateDate") Previous_Application_Date
  from 	  backoffice.sqlmig."Application" a , backoffice.sqlmig."Client" c
  where   a."ClientId" = c."ClientId"
)
select 	a.* 
from 		ApplicationData a
where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}';