alter table BSP_APPLICATION add NRE_Status varchar2(40);
alter table BSP_ACCOUNT add NRE_Status varchar2(40);
alter table BSP_APPLICATION add previous_application_date date;
alter table BSP_ACCOUNT add Previous_Loan_Date date;
alter table BSP_AFFORDABILITY modify (NLRCOMMENT varchar2(4000));

alter table BSP_DISBURSEMENT modify ( STATUSMESSAGE varchar2(512) );
alter table BSP_EMPLOYER modify ( HRADDRESS varchar2(600));

alter table BSP_AFFORDABILITY drop column NLRCOMMENT;

alter table BSP_AFFORDABILITY add NLRCOMMENT clob;

truncate table BSP_AFFORDABILITY drop storage;


Create index BSP_BRANCH_IDX on BSP_BRANCH (BRANCHID);
Create index BSP_CLIENT_IDX on BSP_CLIENT (CLIENTID);
Create index BSP_CANCELREASON_IDX on BSP_CANCELREASON (CANCELREASONID);
Create index BSP_ACCOUNT_IDX on BSP_ACCOUNT (ACCOUNTID);
Create index BSP_REGION_IDX on BSP_REGION (REGIONID);
Create index BSP_AFFORDABILITY_IDX on BSP_AFFORDABILITY (APPLICATIONID);
Create index BSP_APPLICATION_ACCOUNTMAPPING_IDX1 on BSP_APPLICATION_ACCOUNTMAPPING (APPLICATIONID);
Create index BSP_APPLICATION_ACCOUNTMAPPING_IDX2 on BSP_APPLICATION_ACCOUNTMAPPING (ACCOUNTID);
Create index BSP_APPLICATION_CLIENT_IDX on BSP_APPLICATION_CLIENT (APPLICATIONCLIENTID);



alter index BSP_BRANCH_IDX rebuild;
alter index BSP_CLIENT_IDX rebuild;
alter index BSP_CANCELREASON_IDX rebuild;
alter index BSP_ACCOUNT_IDX rebuild;
alter index BSP_REGION_IDX rebuild;

Create materialized view BSP_FIRST_ACCOUNT as
select c.ClientId , c.idNumber , min(opendate) First_AccountDate
from   BSP_Account ac , BSP_client c
where  ac.ClientId = c.Clientid
and    ac.LoanType = 'L'
group by c.ClientId , c.idNumber ;

create index BSP_FIRST_ACCOUNT_IDX1 on BSP_FIRST_ACCOUNT ( IDNUMBER );

Select  idnumber , count(*) from BSP_FIRST_ACCOUNT
group by idnumber
having count(*) >= 2;

Drop snapshot BSP_NTU_Application;
--Create materialized view BSP_NTU_Application as
With applicationData as (
  Select  a.createdate,to_char(a.createdate,'YYYYMM') Application_Month , a.applicationid 
      ,   a.AccountId, a.clientId, a.applicationclientid, a.branchid 
      --, a.period Application_Period
      ,   a.disbursementid
      ,   a.amount Application_Amount 
      ,   acl.idnumber Application_Idnumber
      ,   LEAD(a.CreateDate) OVER (partition by acl.idnumber ORDER BY a.Createdate) Next_Application_date
      ,   LEAD(acl.idnumber) OVER (partition by acl.idnumber ORDER BY a.CreateDate) Next_IDNumber
      ,   coalesce(ac.period,q.period,a.period) Period
      ,   b.company, b.Branchname , b.region , r.Description
      ,   ac.LoanAmount Loan_Amount
      ,   af.NLRScore BureauScore
      ,   cs.ApplicationScore
      ,   af.grossSalary, af.deductions, af.netSalary, af.TotalLivingExpense , af.ActualLivingExpense 
      ,   fac.First_AccountDate
      ,   case
          when ( fac.First_AccountDate is null or fac.First_AccountDate > a.CreateDate ) then 'New'  
          --when ( ac.previous_loan_date is null) then 'New' 
          else 'Existing' end NRE_STATUS
      ,   q.QuotationId
      ,   a.CancelReasonId
      ,   d.disbursementamt
      ,   case when (q.QuotationId is null) then
            case  when ( a.CancelReasonId is not null) then
              'Declined' 
              else  
                'NoOffer' 
              end
            else 
              case when ( d.disbursementamt > 0 ) then 
                'TakenUp'
              else
                'NotTakenUp'
              end
            end NTU_STATUS
      --,   CASE 
      --    WHEN acl.idnumber = LEAD(acl.idnumber) OVER ( partition by acl.idnumber ORDER BY a.CreateDate)
      --    THEN LEAD(a.CreateDate) OVER (partition by acl.idnumber ORDER BY a.Createdate)
      --    ELSE NULL
      --    END AS next_Application_Date
  from    BSP_Application a inner join BSP_Application_client acl
                              on   a.applicationclientid = acl.applicationclientid 
                            left outer join BSP_Application_AccountMapping aam
                                on   a.ApplicationId = aam.ApplicationId
                                and  a.AccountId     = aam.AccountId
                            left outer join Bsp_CreditScore cs
                                on   a.ApplicationId = cs.ApplicationId
                            left outer join BSP_Affordability af
                                on  a.ApplicationId = af.ApplicationId
                            left outer join BSP_Quotation q 
                                on   a.QuotationId = q.QuotationId
                            left outer join BSP_Disbursement d
                                on  a.DisbursementId = d.Disbursementid
                            left outer join BSP_Account ac 
                                on   aam.AccountId = ac.AccountId 
                            left outer join BSP_FIRST_ACCOUNT fac
                                on   acl.IdNumber = fac.IdNumber
        , Bsp_Branch b
        , Bsp_Region r  
  where   a.branchid = b.branchid
  and     b.region = r.RegionId
  )
Select  a.*
      , case 
        when ( a.Period ) between 0   and 30  then '1'
        when ( a.Period ) between 31  and 60  then '2'
        when ( a.Period ) between 61  and 90  then '3'
        when ( a.Period ) between 91  and 120 then '4'
        when ( a.Period ) between 121 and 150 then '5'
        when ( a.Period ) between 151 and 180 then '6'
        when ( a.Period ) between 181 and 210 then '7'
        when ( a.Period ) between 211 and 240 then '8'
        when ( a.Period ) between 241 and 270 then '9'
        when ( a.Period ) between 271 and 300 then '10'
        when ( a.Period ) between 301 and 330 then '11'
        when ( a.Period ) between 331 and 360 then '12'
        else	'12+' 
        end  Loan_Term
    --  Application_Month, count(*) TotalAccounts
    --,   case 
    --    when ( ( Next_Application_Date - CreateDate)   <  1 ) 
    --    then 0 else 1 
    --    end ValidApplication
from    applicationData a;


Select  Application_month, NTU_status
      , count(*)
from    BSP_NTU_Application
where   NRE_STATUS = 'Existing'
group by Application_month, NTU_status;

Select      
          NRE_STATUS , NTU_STATUS 
    ,     sum(Application_Amount) Application_Value , sum(Loan_Amount) Loan_Value
    ,     count(*) Total
    ,     sum(count(*)) over () Total_Applications
    ,     sum(count(*)) over (  partition by --Application_Month , 
                                Nre_Status) Total_Applications_NRE
from      BSP_NTU_Application
where     application_month >= 202501
group by --Application_Month , 
          NRE_STATUS , NTU_STATUS
order by --Application_Month , 
1,2
;


Select *
from   BSP_NTU_Application
where NRE_STATUS = 'Existing'
and   NTU_STATUS = 'NotTakenUp'
and   application_month = 202401;


where   a.createdate between '01-Jan-2024' and '31-Jan-2024'
and     ( Next_Application_Date is null or Next_Application_Date - CreateDate > 1 )
--and     Application_Idnumber = '0001016858084'
order by Application_Idnumber
;

Select  count(*)
from    BSP_Application a , BSP_Quotation q
where   a.QuotationId = q.QuotationId (+)
and     a.createdate between '01-Jan-2024' and '31-Jan-2024';

--Create materialized view BSP_NTU_Application as
With ApplicationData as (
  Select  a.createdate,to_char(a.createdate,'YYYYMM') Application_Month , a.applicationid ,a.AccountId, a.clientId, a.branchid , a.period 
      ,   a.CancelReasonId , a.disbursementid
      ,   a.amount Application_Amount 
      ,   a.previous_loan_date
      ,   c.IdNumber , c.dateofbirth , c.gender , TRUNC(MONTHS_BETWEEN(a.createdate, c.dateofbirth) / 12) age
  from    bsp_application a , Bsp_Application_client c
  where   a.clientid = c.clientid
  and     a.createdate between '01-Jan-2024' and '31-Jan-2024'
)
Select  a.applicationid,a.accountid,a.disbursementid
      , a.CancelReasonId,cr.Description
      , d.DisbursementAmt,d.DISBURSEMENTDATE,aa.disbursementmodeid
      , case 
        when ( a.Accountid is not null and a.disbursementid is not null and d.DisbursementAmt > 0 ) then 'TakenUp' 
        when ( a.CancelReasonId is not null) then 'Declined'
        when ( a.AccountId is not null and a.disbursementid is null) then 'NotTakenUp'
        when ( a.AccountId is null ) then 'NoOffer'
        else 'Undetermined' end NTU_STATUS   
      , a.*
      , b.company, b.Branchname , b.region , r.Description
      , aa.LoanAmount Loan_Amount
      , case 
        when ( a.Period ) between 0   and 30  then '1'
        when ( a.Period ) between 31  and 60  then '2'
        when ( a.Period ) between 61  and 90  then '3'
        when ( a.Period ) between 91  and 120 then '4'
        when ( a.Period ) between 121 and 150 then '5'
        when ( a.Period ) between 151 and 180 then '6'
        when ( a.Period ) between 181 and 210 then '7'
        when ( a.Period ) between 211 and 240 then '8'
        when ( a.Period ) between 241 and 270 then '9'
        when ( a.Period ) between 271 and 300 then '10'
        when ( a.Period ) between 301 and 330 then '11'
        when ( a.Period ) between 331 and 360 then '12'
        else	'12+' 
        end  Loan_Term
      , af.NLRScore BureauScore
      , cs.ApplicationScore
      , case 
        when ( a.Accountid is not null and a.disbursementid is not null and d.DisbursementAmt > 0 ) then 'TakenUp' 
        when ( a.CancelReasonId is not null) then 'Declined'
        when ( a.AccountId is not null and a.disbursementid is null) then 'NotTakenUp'
        when ( a.AccountId is null ) then 'NoOffer'
        else 'Undetermined' end NTU_STATUS   
      , af.grossSalary, af.deductions, af.netSalary, af.TotalLivingExpense , af.ActualLivingExpense 
      , aa.nre_status Account_nre_status
from    ApplicationData a left outer join BSP_CancelReason cr
                                              on  cr.object = 'application'
                                              and a.CancelReasonId = cr.CancelReasonid
                          left outer join BSP_Account aa
                                              on  a.AccountId = aa.AccountId
                          left outer join BSP_Affordability af
                                              on  a.ApplicationId = af.ApplicationId
                          left outer join BSP_Disbursement d
                                              on  a.DisbursementId = d.Disbursementid
      , Bsp_Branch b
      , Bsp_Region r
      , Bsp_CreditScore cs
where   ( a.AccountId is null or aa.AccountId is not null) 
and     a.branchid = b.branchid
and     b.region = r.RegionId
and     a.ApplicationId = cs.ApplicationId
order by a.createdate
;

Select * from BSP_NTU_Application;

With NREData as (
  Select  ap.ApplicationId , ap.AccountId , ap.clientid
        , ap.CreateDate , ac.OpenDate
        , lag(ac.Opendate) over (partition by ac.IdNumber order by opendate) Last_Loan_Date
        , ceil(ap.Createdate - lag(ac.Opendate) over (partition by ac.clientId order by opendate))  Days_Since_Last_Loan
        --, ap.*
  from    bsp_application ap  left outer join bsp_Account ac 
                    on   ap.AccountId = ac.AccountId 
  where   ap.CreateDate between '01-Mar-2024' and '01-Apr-2024'
)
Select  nre.*
      , case 
        when ( Last_loan_date is null ) then 'New'
        when ( days_since_last_loan < 90) then 'Returning'
        when ( AccountId is not null) then 'Existing'
        else null end nre_status
from    NREData nre;
;


Select count(*) from BSP_Account
where  opendate between '01-Jan-2024' and '01-Feb-2024';

Select * from BSP_Application;

With data as (
  Select  ac.accountid, c.idnumber , OpenDate
        , lag(ac.Opendate) over (partition by c.IdNumber order by ac.opendate) Last_Loan_Date
  from    BSP_Account ac , BSP_Client c
  where   ac.clientid = c.clientid
)
Select  d.* 
      , case 
        when ( Last_loan_date is null ) then 'New'
        when ( opendate - Last_Loan_Date < 90) then 'Returning'
        when ( AccountId is not null) then 'Existing'
        else null end nre_status
from    data d
where   opendate between '01-Jan-2024' and '01-Feb-2024'
order by 1;

Select * from loan_detail where accountid = 3353923;

Select * from BSP_NTU_Application
where  Application_amount = 0
and accountid is not null;

Select  to_char(OpenDate,'YYYYMM') OpenMonth, count(*) 
from    BSP_Account 
group by to_char(OpenDate,'YYYYMM');


Select * from BSP_Application;


Select  count(*) 
from    BSP_Account ac , BSP_Application ap
where   opendate between to_date('2024-01-01','YYYY-MM-DD') and to_date('2024-01-31','YYYY-MM-DD')
and     ac.AccountId = ap.AccountId (+);


--Drop snapshot NTU_Application_Summary;
--Create materialized view NTU_Application_Summary as




Select * from BSP_NTU_Application;


Select  openMonth , count(*) 
from    loan_detail
where   openmonth >= 202401
group by openmonth;

Select    Application_Month , NRE_STATUS , NTU_STATUS 
    ,     sum(Application_Amount) Application_Value , sum(Loan_Amount) Loan_Value
    ,     count(*) Total
    ,     sum(count(*)) over ( partition by Application_Month , Ntu_Status) Total_Applications
from      Data
where    Application_Month >= 202401
group by Application_Month , NRE_STATUS , NTU_STATUS
order by Application_Month;


Select  to_char(OpenDate,'YYYYMM'),count(*)
from    bsp_account
where opendate > '01-Jan-2024'
group by to_char(OpenDate,'YYYYMM')
order by 1;

Select * from user_snapshots;
begin 
  for t in (  Select TABLE_NAME from user_tables
              where table_name like 'BSP%' 
              and   table_name in ('BSP_ACCOUNT','BSP_APPLICATION','BSP_APPLICATION_ACCOUNTMAPPING','BSP_APPLICATION_CLIENT')
              minus
              Select NAME from user_snapshots
              )
  Loop
    --execute immediate 'truncate table '||t.table_name||' drop storage';
    execute immediate 'truncate table '||t.table_name||' drop storage';
  end loop;
end;
/


Select count(*) from bsp_account;
Select count(distinct accountid) from bsp_account;

Select count(*) from bsp_address;
Select count(distinct addressid) from bsp_address;

Select count(*) from bsp_application;
Select count(Distinct ApplicationId) from bsp_Application; 

Select count(*) from bsp_affordability;
Select count(Distinct affordabilityId) from bsp_affordability; 

Select count(*) from bsp_application;
Select count(Distinct applicationId) from bsp_application; 

Select count(*) from bsp_client;
Select count(Distinct clientId) from bsp_client; 

Select count(*) from bsp_creditScore;
Select count(Distinct CreditScoreId) from bsp_CreditScore;

Select count(*) from bsp_Employer;
Select count(Distinct EmployerId) from bsp_Employer;

Select count(*) from bsp_Quotation;
Select count(Distinct QuotationId) from bsp_Quotation;

Select count(*) from bsp_client;
Create table bsp_client_uq
as select distinct * from bsp_client;
Select count(*) from bsp_client_uq;
drop table bsp_client;
rename bsp_client_uq to bsp_client;

select count(distinct clientid) from bsp_client;

create table bsp_address_uq
as select distinct * from bsp_address;



drop table  bsp_address_uq;

rename  bsp_client_uq to  bsp_client;;


Select count(*) from (Select distinct * from bsp_affordability);
Select count(*) from bsp_affordability;
3475707



Select table_name , column_name , data_type
from   user_tab_cols
where  column_name not like 'SYS_%'
and table_name like 'BSP_%'
order by table_name , column_id
;


Select  count(*) 
from    BSP_Account;
  
  
     
EXECUTE DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'ATLAS');  



--Brad SQL

WITH latest_account_per_client AS  (
  SELECT
     a .ClientId,
    MAX ( a .OpenDate) AS latest_account_date
  FROM BSP_Account a
  WHERE a .LoanType = 'L'
               and a .OpenDate > '1 Feb 2025'
  GROUP BY a .ClientId
),
recent_apps_without_account AS (
  SELECT
    ap. ApplicationId ,
    ap. ApplicationClientId ,
    ap. CreateDate ,
    ap. ClientId ,
    a. AccountId ,
    a. StatusId ,
    ap. BranchId ,
    ROW_NUMBER () OVER ( PARTITION BY ap. ClientId ORDER BY ap. CreateDate DESC ) AS rn
FROM BSP_Application ap INNER JOIN
          latest_account_per_client lac ON ap. ClientId = lac. ClientId and ap. CreateDate > lac.latest_account_date and ap. CreateDate > '1 Apr 2025' LEFT JOIN
          BSP_Application_AccountMapping m ON ap. ApplicationId = m. ApplicationId LEFT JOIN
          BSP_Account a ON m. ApplicationId = ap. ApplicationId AND a. LoanType = 'L'

)
Select * from recent_apps_without_account;


With ApplicationData as (
  Select  a.*
        , acl.idnumber
      --,   ac.statusId
      
      --,   CASE 
      --    WHEN acl.idnumber = LEAD(acl.idnumber) OVER ( partition by acl.idnumber ORDER BY a.CreateDate)
      --    THEN LEAD(a.CreateDate) OVER (partition by acl.idnumber ORDER BY a.Createdate)
      --    ELSE NULL
      --    END AS next_Application_Date
      ,   LEAD(a.CreateDate) OVER (partition by acl.idnumber ORDER BY a.Createdate) Next_Application_date
  from    BSP_Application a inner join BSP_Application_client acl
                                on   a.applicationclientid = acl.applicationclientid 
  where   createdate between '01-Jan-2024 00:00:00' and '31-Jan-2024 23:59:59'
  )
Select  a.* 
      , case when (q.QuotationId is null) then
          case  when ( a.CancelReasonId is not null) then
            'Declined' 
          else  
            'NoOffer' 
          end
        else 
          case when ( d.disbursementamt > 0 ) then 
            'TakenUp'
          else
            'NotTakenUp'
          end
        end NTU_STATUS
from    ApplicationData a left outer join BSP_Application_AccountMapping aam
                                on   a.ApplicationId = aam.ApplicationId
                                and  a.AccountId     = aam.AccountId
                            left outer join BSP_Quotation q 
                                on   a.QuotationId = q.QuotationId
                            left outer join BSP_Disbursement d
                                on  a.DisbursementId = d.Disbursementid
                            left outer join BSP_Account ac 
                                on   aam.AccountId = ac.AccountId 
                            left outer join BSP_Account ac 
                                on   aam.AccountId = ac.AccountId;     
--where   createdate between '01-Jan-2024 00:00:00' and '31-Jan-2024 23:59:59';
  
  
  
                                        
  --and     q.QuotationId is null
  --and     a.CancelReasonId is not null
)
Select  * 
from    ApplicationData
--where   createdate between '01-Jan-2024 00:00:00' and '31-Jan-2024 23:59:59'

;

Select count(*)
from   BSP_Account
where  opendate between '01-Jan-2024 00:00:00' and '31-Jan-2024 23:59:59';
select 36230-36118 from dual;



Select count(*) 
from    BSP_Application_AccountMapping aam 
                  left outer join BSP_Account a
                      on aam.AccountId = a.AccountId
where   a.AccountId is null;


Select  distinct to_char(a.createdate,'YYYYMM') , count(a.applicationid),count(aff.applicationid)
from    bsp_application a left outer join BSP_Affordability aff
                              on a.ApplicationId = aff.ApplicationId
where   aff.applicationid is null     
group by to_char(a.createdate,'YYYYMM');
;