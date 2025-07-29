--This query returns Employer data
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	distinct adr.*
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Employer" adr , parameters p
where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate"
and     a."EmployerId" = adr."EmployerId";    