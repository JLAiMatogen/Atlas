truncate table STG_ACCOUNTINFO drop storage;
truncate table STG_BUREAURESPONSE drop storage;

Select openMonth , count(*)
from   STG_ACCOUNTINFO
--where  NRE_STATUS is not null 
group by openmonth
order by 1;

merge into loan_detail T
using (Select * from STG_ACCOUNTINFO ) S
on    (T.AccountId    = S.AccountId
  and  T.ApplicationId= S.ApplicationId  )
when not matched then
insert ( 
  T.OpenMonth                   
, T.AccountId                   
, T.IdNum                       
, T.ApplicationId               
, T.AccountType                 
, T.OpenDate                    
, T.AgeInMonths                 
, T.NumOfInstalments            
, T.Branch                  
, T.Consultant                  
, T.PaymentFrequency            
, T.Loan_Term                   
, T.Debtors_Bank                
, T.Loan_Size                   
, T.ROLLd_loan                  
, T.Product                     
, T.Credit_Score_OR_CAT         
, T.CDE_Override                
, T.HandedOver                  
, T.FirstDueDate_Missed_Flag    
, T.FirstInstalment_Default_Flag
, T.One_ever_3_Flag             
, T.two_ever_6_Flag             
, T.BureauScore                 
, T.ApplicationScore    
, T.NRE_Status
, T.ServiceProvider
, T.Overdue_Status
)
values (
  S.OpenMonth                   
, S.AccountId                   
, S.IdNum                       
, S.ApplicationId               
, S.AccountType                 
, S.OpenDate                    
, S.AgeInMonths                 
, S.NumOfInstalments            
, S.Branchname                  
, S.Consultant                  
, S.PaymentFrequency            
, S.Loan_Term                   
, S.Debtors_Bank                
, S.Loan_Size                   
, S.ROLLd_loan                  
, S.Product                     
, S.Credit_Score_OR_CAT         
, S.CDE_Override                
, S.HandedOver                  
, S.FirstDueDate_Missed_Flag    
, S.FirstInstalment_Default_Flag
, S.One_ever_3_Flag             
, S.two_ever_6_Flag             
, S.BureauScore                 
, S.ApplicationScore 
, S.NRE_Status
, S.ServiceProvider
, S.Overdue_Status
)
when matched then update
set T.IDNUM                         = S.IDNUM
  , T.AGEINMONTHS                   = S.AGEINMONTHS
  , T.CONSULTANT                    = S.CONSULTANT
  , T.HANDEDOVER                    = S.HANDEDOVER
  , T.FIRSTDUEDATE_MISSED_FLAG      = S.FIRSTDUEDATE_MISSED_FLAG
  , T.FIRSTINSTALMENT_DEFAULT_FLAG  = S.FIRSTINSTALMENT_DEFAULT_FLAG
  , T.ONE_EVER_3_FLAG               = S.ONE_EVER_3_FLAG
  , T.TWO_EVER_6_FLAG               = S.TWO_EVER_6_FLAG
  , T.BUREAU                        = coalesce(T.BUREAU,'Experian') --Wait for the results from Bureau extract.
  , T.BUREAUSCORE                   = S.BUREAUSCORE
  , T.APPLICATIONSCORE              = S.APPLICATIONSCORE
  , T.ROLLD_LOAN                    = S.ROLLD_LOAN
  , T.Product                       = S.Product                     
  , T.Credit_Score_OR_CAT           = S.Credit_Score_OR_CAT
  , T.CDE_Override                  = s.CDE_Override
  , T.NRE_Status                    = S.NRE_Status
  , T.ServiceProvider               = S.ServiceProvider
  , T.Overdue_Status                = S.Overdue_Status;
  

Select  openmonth,count(a.applicationid),count(distinct b.applicationid) 
from    STG_ACCOUNTINFO a ,  STG_BureauResponse b
where   a.applicationid = b.applicationid (+)
group by openmonth
order by 1;

merge into loan_detail T
USING (
  Select  distinct applicationid,  case when ( bureau_returned is null ) then 'Experian' else bureau_returned end bureau_returned
  FROM    STG_BureauResponse 
  where   bureau_score is not null and bureau_score != 0) S
ON  ( T.APPLICATIONID = S.APPLICATIONID )
when matched then update 
set   T.BUREAU = S.BUREAU_RETURNED;

Update loan_detail
set bureau = 'Experian'
where  bureau is null;



BEGIN 
  DBMS_SNAPSHOT.REFRESH( '"ATLAS"."LOAN_DETAIL_MV"','C'); 
end;
/


Select  openMonth,count(*)
from    Loan_Detail
--where   Openmonth >= 202401
group by OpenMonth
order by 1;

Select  * 
from    loan_detail
where   openmonth = 202501;

--Vintages
Create table Loan_Detail2 (
  OpenMonth                     varchar2(6)
, AccountId                     varchar2(40)
, IdNum                         varchar2(40)
, ApplicationId                 varchar2(40)
, AccountType                   varchar2(5)
, OpenDate                      timestamp
, AgeInMonths                   number  
, NumOfInstalments              number
, Branch                        Varchar2(128)
, Consultant                    Varchar2(128)
, PaymentFrequency              varchar2(40)
, Loan_Term                     varchar2(40)
, Debtors_Bank                  Varchar2(128)
, Loan_Size                     varchar2(40)
, ROLLd_loan                    varchar2(10)
, Product                       varchar2(64)
, Credit_Score_OR_CAT           varchar2(128)
, CDE_Override                  varchar2(10)
, HandedOver                    number
, FirstArrearDate               timestamp
, MonthsFirstArrear             number
, FirstDueDate_Missed_Flag      number 
, FirstInstalment_Default_Flag  number 
, One_ever_3_Flag               number
, two_ever_6_Flag               number
, BureauScore                   NUMBER
, ApplicationScore              NUMBER
);

alter table Loan_Detail2 add  Bureau varchar(128);

merge into loan_detail2 T
using ( Select  a.* 
            ,   ceil(MONTHS_BETWEEN(a.FirstArrearDate,a.OpenDate)) MONTHSFIRSTARREAR
        from    STG_ACCOUNTINFO a) S
on    (T.AccountId    = S.AccountId
  and  T.ApplicationId= S.ApplicationId  )
when not matched then
insert ( 
  T.OpenMonth                   
, T.AccountId                   
, T.IdNum                       
, T.ApplicationId               
, T.AccountType                 
, T.OpenDate                    
, T.AgeInMonths                 
, T.NumOfInstalments            
, T.Branch                  
, T.Consultant                  
, T.PaymentFrequency            
, T.Loan_Term                   
, T.Debtors_Bank                
, T.Loan_Size                   
, T.ROLLd_loan                  
, T.Product                     
, T.Credit_Score_OR_CAT         
, T.CDE_Override                
, T.HandedOver  
, T.FirstArrearDate
, T.MonthsFirstArrear
, T.FirstDueDate_Missed_Flag    
, T.FirstInstalment_Default_Flag
, T.One_ever_3_Flag             
, T.two_ever_6_Flag             
, T.BureauScore                 
, T.ApplicationScore            
)
values (
  S.OpenMonth                   
, S.AccountId                   
, S.IdNum                       
, S.ApplicationId               
, S.AccountType                 
, S.OpenDate                    
, S.AgeInMonths                 
, S.NumOfInstalments            
, S.Branchname                  
, S.Consultant                  
, S.PaymentFrequency            
, S.Loan_Term                   
, S.Debtors_Bank                
, S.Loan_Size                   
, S.ROLLd_loan                  
, S.Product                     
, S.Credit_Score_OR_CAT         
, S.CDE_Override                
, S.HandedOver    
, S.FirstArrearDate
, S.MONTHSFIRSTARREAR
, S.FirstDueDate_Missed_Flag    
, S.FirstInstalment_Default_Flag
, S.One_ever_3_Flag             
, S.two_ever_6_Flag             
, S.BureauScore                 
, S.ApplicationScore 
)
when matched then update
set T.IDNUM                         = S.IDNUM
  , T.AGEINMONTHS                   = S.AGEINMONTHS
  , T.CONSULTANT                    = S.CONSULTANT
  , T.HANDEDOVER                    = S.HANDEDOVER
  , T.FIRSTARREARDATE               = S.FIRSTARREARDATE
  , T.MONTHSFIRSTARREAR             = S.MONTHSFIRSTARREAR
  , T.FIRSTDUEDATE_MISSED_FLAG      = S.FIRSTDUEDATE_MISSED_FLAG
  , T.FIRSTINSTALMENT_DEFAULT_FLAG  = S.FIRSTINSTALMENT_DEFAULT_FLAG
  , T.ONE_EVER_3_FLAG               = S.ONE_EVER_3_FLAG
  , T.TWO_EVER_6_FLAG               = S.TWO_EVER_6_FLAG
  --, T.BUREAU                        = coalesce(T.BUREAU,'Experian') --Wait for the results from Bureau extract.
  , T.BUREAUSCORE                   = S.BUREAUSCORE
  , T.APPLICATIONSCORE              = S.APPLICATIONSCORE
  , T.ROLLD_LOAN                    = S.ROLLD_LOAN
  , T.Product                       = S.Product                     
  , T.Credit_Score_OR_CAT           = S.Credit_Score_OR_CAT
  , T.CDE_Override                  = s.CDE_Override;


merge into loan_detail2 T
using ( Select applicationid , accountid , bureau from loan_detail
        where openmonth >= 202401
        ) S
on   (  T.Applicationid = S.Applicationid
  and   T.Accountid = S.accountid)
when matched then 
  Update set T.BUREAU = S.Bureau;
  
merge into loan_detail2 T
USING (
  Select  distinct applicationid,  case when ( bureau_returned is null ) then 'Experian' else bureau_returned end bureau_returned
  FROM    STG_BureauResponse 
  where   bureau_score is not null and bureau_score != 0) S
ON  ( T.APPLICATIONID = S.APPLICATIONID )
when matched then update 
set   T.BUREAU = S.BUREAU_RETURNED;

Update loan_detail
set bureau = 'Experian'
where  bureau is null;


Select openmonth , count(*)
from   loan_detail2
where openmonth >= 202401
group by openmonth;

Create or replace view Cumulative_Bad_rate as
With RollingMonths as(
  select level AgeInMonths
  from dual 
  CONNECT BY LEVEL<= 8
  ),
VintageIndicators as (
  Select  OpenMonth 
        , Loan_Term
        , OpenDate 
        , AccountId
        , FirstArrearDate
        , MONTHSFIRSTARREAR
        , rm.AgeInMonths
        , Branch
        , Consultant 
        , PaymentFrequency
        , Debtors_Bank
        , Loan_Size
        , ROLLd_loan
        , Product
        --, Credit_Score_OR_CAT
        , CDE_Override
        , case 
          when BureauScore < 560 then '  0 - 560'
          when BureauScore >= 750 then '750 +'
          else to_char(TRUNC(BureauScore / 5) * 5 + 1)||' - '||to_char(TRUNC(BureauScore / 5) * 5 + 5) 
          end  BureauScore_Band
        , case 
          when ApplicationScore < 560 then '  0 - 560'
          when ApplicationScore >= 750 then '750 +'
          else to_char(TRUNC(ApplicationScore / 5) * 5 + 1)||' - '||to_char(TRUNC(ApplicationScore / 5) * 5 + 5) 
          end  ApplicationScore_Band
        , case when ( bureau is null ) then 'Experian' else bureau end bureau_returned
        , case when (rm.AgeInmonths >= ld.MONTHSFIRSTARREAR ) then 1 else 0 end Vintage_Indicator
  from   RollingMonths rm, loan_detail2 ld
  --where  openMonth =202401 --AccountId = 3341967
  ),
VintageSummary as (
  Select  to_char(OpenMonth) OpenMonth
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
        , count(*) Total_Accounts
        , sum(Vintage_Indicator) Total_In_Arrears
        --, round(sum(Vintage_Indicator)/count(*),2) Vintage_Perc
  from    VintageIndicators
  group by OpenMonth 
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
  union all
  Select  'General' OpenMonth
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
        , count(*) Total_Accounts
        , sum(Vintage_Indicator) Total_In_Arrears
        --, round(sum(Vintage_Indicator)/count(*),2) Vintage_Perc
  from    VintageIndicators
  group by 'General' 
        --, Bureau_Returned
        --, BureauScore_Band
        --, Branch
        --, Consultant
        --, PaymentFrequency
        , Loan_Term
        --, Debtors_Bank
        , Loan_Size
        --, ROLLd_loan
        --, Product
        --, CDE_Override
        , AgeInMonths
)
Select * from VintageSummary;

drop snapshot Cumulative_Bad_rate_mv;
Create materialized view Cumulative_Bad_rate_mv as 
select * from Cumulative_Bad_rate;

Select * from Cumulative_Bad_rate_mv
order by 1 , 2 , 3 , 4;

--Done to here.

Select openmonth,count(*) from Cumulative_Bad_rate_mv
group by openmonth;

;
Select * 
from    ( Select  Openmonth 
                , loan_term
                , Total_Accounts
                , AgeInMonths 
                , Vintage_perc
          from    VintageSummary
        )
pivot (
        max(Vintage_perc)
        for AgeInMonths in (1,2,3,4,5,6,7,8,9,10,11,12)
      )
order by 1;





Select openMonth , count(*)
from   Loan_Detail
group by openmonth
order by 1;




Select accountId , applicationid, count(*)
from   STG_ACCOUNTINFO
group by accountId , applicationid
having count(*) >= 2;


Select  ld.idnum , ld.accountid, ld.opendate, ld.applicationscore
      , dense_rank() over (partition by IDNum order by openDate)
from    Loan_Detail ld
order by idnum,opendate;


Select OpenMonth , count(*)
from   loan_detail
where openmonth >= 202401
group by openmonth;

Select count(distinct accountid) from loan_detail where openmonth = 202401;


Select to_number(Accountid)
from   loan_detail
where openMonth = 202401
minus
select accountId
from   BSP_Account
where  opendate between '01-Jan-2024 00:00:00' and '31-Jan-2024 23:59:59';

Select count(*) from Loan_detail_mv
where  openmonth >= 202401
and    CREDIT_SCORE_OR_CAT is null;


