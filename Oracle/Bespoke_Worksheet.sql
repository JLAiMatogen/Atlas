Select count(*) from BSP_Application;

truncate table BSP_Application;


Select * from user_snapshots;
begin
  for t in (
            Select  table_name 
            from    user_tables where table_name like 'BSP_%'
            minus
            select  name from user_snapshots
            )
  Loop
    execute immediate 'truncate table '||t.table_name||' drop storage';  
  end loop;
end;
/

Select count(*) from BSP_Application;
--435038


Select clientid , count(*)
from   BSP_client
group  by clientid
having count(*) >= 2;

SelecT * from BSP_Client
where ClientId = 179071;

Create index BSP_Application_Idx1 on BSP_Application ( ApplicationId );
Create index BSP_Affordability_Idx1 on BSP_Affordability ( AffordabilityId );
Create index BSP_Branch_Idx1 on BSP_Branch (BranchId);
Create index BSP_CreditScore_Idx1 on BSP_CreditScore (ApplicationId);

Select count(*) from BSP_Branch ;
Select count(*) from BSP_CreditScore ;

Select * from BSP_Province;

Select * from BSP_Address;

truncate table BSP_Branch drop storage;
truncate table BSP_Province drop storage;
truncate table BSP_MaritalStatus drop storage;

Select count(*) from BSP_CLIENT;
Select count( Distinct ClientId) from BSP_CLIENT;

Delete from BSP_CLIENT where rowid in (
  Select row_id from (
    Select  c.*
        ,   rowid row_id
        ,   dense_rank() over (partition by clientid order by rowid desc ) ranking
    from    BSP_Client c
  )
  where ranking >= 2
);

Select * from BSP_ALL_TABLE_VIEW;
Select  count(*)
from    BSP_Application a
          left outer join Loan_Detail ld
              on  a.Accountid = ld.AccountId
          left outer join BSP_CreditScore cs
              on  a.ApplicationId = cs.ApplicationId
      , BSP_Affordability aff 
      , BSP_CreditScore cs
      --, BSP_Branch b
      --, BSP_client c
      --    left outer join BSP_MaritalStatus ms
      --      on c.MaritalStatusId = ms.MaritalStatusId
      --, BSP_Address adr
      --    left outer join  BSP_Province p
      --      on  adr.province = p.ProvinceId  
where   a.AffordabilityId = aff.AffordabilityId 

--and     a.BranchID = b.BranchId
--and     a.ClientId = c.ClientId
--and     a.ResidentialAddressId = adr.AddressId
and     a.createdate between '01-Jan-2024' and '31-Jan-2024';



Select distinct maritalstatusid from bsp_client;


EXEC DBMS_STATS.gather_schema_stats(ownname=>'ATLAS');

Select count(distinct clientid) from BSP_client;


select idnum , count(*)
from    loan_detail
group by idnum
having count(*) >= 2;

drop snapshot BSP_Client_Loan_Summary;
Create materialized view BSP_Client_Loan_Summary as
  Select idNum IDNumber ,  min(cast(Opendate as date)) First_Loan_Date , max(cast(Opendate as date)) Last_Loan_date,  count(*) Loan_Count 
  from   Loan_Detail
  group by idnum;
Create index BSP_Client_Loan_Summary
  
  
  Select count(*) from BSP_Client_Loan_Summary;
  
  
  Select * 
  from  BSP_APPLICATION a
          left outer join Loan_Detail ld
              on  a.Accountid = ld.AccountId
        , BSP_AFFORDABILITY aff 
        , BSP_CREDITSCORE cs
        , BSP_BRANCH b
        , BSP_CLIENT c
            left outer join BSP_CLIENT_LOAN_SUMMARY cls
                    on c.IdNumber = cls.IdNumber
        , BSP_ADDRESS adr
            left outer join  BSP_PROVINCE p
              on  adr.province = p.PROVINCEID
where   a.AffordabilityId = aff.AffordabilityId 
and     a.ApplicationId = cs.ApplicationId
and     a.BranchID = b.BranchId
and     a.ClientId = c.ClientId
and     a.ResidentialAddressId = adr.AddressId;



Select ', '||Table_name||'.'||Column_Name||' as '||Table_Name||'_'||Column_Name Column_Select
from   user_tab_cols
where table_name in ( 'BSP_APPLICATION','LOAN_DETAIL','BSP_AFFORDABILITY','BSP_CREDITSCORE','BSP_BRANCH','BSP_CLIENT','BSP_CLIENT_LOAN_SUMMARY'
                  ,   'BSP_ADDRESS','BSP_PROVINCE');




Select a.*
  ,   ld.*
from    "ATLAS"."BSP_APPLICATION" a
          left outer join Loan_Detail ld
              on  a.Accountid = ld.AccountId
      , "ATLAS"."BSP_AFFORDABILITY" aff 
      , "ATLAS"."BSP_CREDITSCORE" cs
      , "ATLAS"."BSP_BRANCH" b
      , "ATLAS"."BSP_CLIENT" c
          left outer join "ATLAS"."BSP_CLIENT_LOAN_SUMMARY" cls
                  on c.IdNumber = cls.IdNumber
      , "ATLAS"."BSP_ADDRESS" adr
          left outer join  "ATLAS"."BSP_PROVINCE" p
            on  adr.province = p."PROVINCEID"
where   a.AffordabilityId = aff.AffordabilityId 
and     a.ApplicationId = cs.ApplicationId
and     a.BranchID = b.BranchId
and     a.ClientId = c.ClientId
and     a.ResidentialAddressId = adr.AddressId;


Select count(*) from bsp_application;
