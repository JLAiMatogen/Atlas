--This query returns Applications for the curren month and 7 days prior to the start of the month
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
),
ApplicationData as (
  select 	a.*
        , lag(a."CreateDate") over (partition by c."IDNumber" order by a."CreateDate") Previous_Application_Date
  from 	  backoffice.sqlmig."Application" a , backoffice.sqlmig."Client" c
  where   a."ClientId" = c."ClientId"
)
select 	p.* , a.* 
from 		ApplicationData a, parameters p
where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate";
