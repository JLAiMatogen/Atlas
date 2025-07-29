--This query returns all Accounts opened in the current month and all accounts that has changed in the last 7 days
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select 	q.*
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Quotation" q, parameters p
where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate"
and			a."QuotationId" = q."QuotationId";
