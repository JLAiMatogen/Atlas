Create materialized view "ACC_Client_IDNumber_Summary" as
Select c."IDNumber" "IDNumber" 
		, min(ac."OpenDate") "First_Opened"
		, max(ac."OpenDate") "Last_Opened"
		, max(ac."CloseDate") "Last_Closed"
		, count(*) Loan_Count 
from   prod."ACC_Account" ac , prod."Client" c
where  ac."ClientId" = c."ClientId"
group by c."IDNumber";


CREATE UNIQUE INDEX ACC_Client_IDNumber_Summary_uq
ON prod."ACC_Client_IDNumber_Summary" ("IDNumber");