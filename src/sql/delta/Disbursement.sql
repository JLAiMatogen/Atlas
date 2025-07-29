--Return Disbursement data.
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	distinct d.*
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Disbursement" d , parameters p
where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate"
and     a."DisbursementId"  = d."DisbursementId";