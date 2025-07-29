--This query returns all Accounts opened between two dates
Select distinct a.* from (
  select 	adr.*
  from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Address" adr
  where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
  and     a."ResidentialAddressId" = adr."AddressId"
  union all
  select 	adr.*
  from 	  backoffice.sqlmig."Application" a, backoffice.sqlmig."Employer" e, backoffice.sqlmig."Address" adr
  where   a."CreateDate" between '{STARTDATE}' and '{ENDDATE}'
  and     a."EmployerId" = e."EmployerId"
  and     e."AddressId" = adr."AddressId"
) a;