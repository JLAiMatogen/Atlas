--This query returns all Accounts opened between two dates
With LoanData as (
  select 	a.*
        , lag(a."CreateDate") over (partition by c."IDNumber" order by a."CreateDate") Previous_Loan_Date
  from 	  backoffice.public."ACC_Account" a , backoffice.sqlmig."Client" c
  where   a."LoanType" = 'L'
  and     a."ClientId" = c."ClientId"
)
Select  ld.* 
from    LoanData ld
where   ld."OpenDate" between '{STARTDATE}' and '{ENDDATE}';