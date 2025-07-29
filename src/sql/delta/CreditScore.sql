--Extract Credit Score data for applications for the current month
-- and 7 days prior to the start of the month.
with parameters as (
	select	date_trunc('month', CURRENT_DATE)::date AS "StartDate"
    	,	  (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date AS "EndDate"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '7 days')::date AS "SevenDaysPriorStart"
    	,   (date_trunc('month', CURRENT_DATE) - INTERVAL '1 days')::date AS "SevenDaysPriorEnd"
)
select    c."CreditScoreId" 
        , c."ApplicationId" 
        --, c."CreditScoreResponse"
        , c."NLRScore"
        , c."ApplicationScore"
        , c."BehaviourScore"
        , c."RiskType"
        , c."ServiceProvider"
        , c."ReferenceNumber"
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."CreditScore" c, parameters p
where   a."CreateDate" between p."SevenDaysPriorStart" and p."EndDate"
and     a."ApplicationId" = c."ApplicationId";
