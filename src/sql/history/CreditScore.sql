--This query returns all Account Credit scores for accounts opened between two dates.
select    c."CreditScoreId" 
        , c."ApplicationId" 
        --, c."CreditScoreResponse"
        , c."NLRScore"
        , c."ApplicationScore"
        , c."BehaviourScore"
        , c."RiskType"
        , c."ServiceProvider"
        , c."ReferenceNumber"
from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."CreditScore" c
where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
and     a."ApplicationId" = c."ApplicationId";;
