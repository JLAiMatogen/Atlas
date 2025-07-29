--This query returns all Application Clients for applications between between two dates
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	aam.* 
from 		backoffice.sqlmig."Application" a , backoffice.sqlmig."Application_Client" aam
      , parameters p
where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate"
and     a."ApplicationClientId" =  aam."ApplicationClientId";
