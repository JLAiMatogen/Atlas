Select openMonth , count(*)
from   STG_ACCOUNTINFO
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
  --, T.BUREAU                        = coalesce(T.BUREAU,'Experian') --Wait for the results from Bureau extract.
  , T.BUREAUSCORE                   = S.BUREAUSCORE
  , T.APPLICATIONSCORE              = S.APPLICATIONSCORE
  , T.ROLLD_LOAN                    = S.ROLLD_LOAN
  , T.Product                       = S.Product                     
  , T.Credit_Score_OR_CAT           = S.Credit_Score_OR_CAT
  , T.CDE_Override                  = s.CDE_Override;
  

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


Select  openmonth,count(*) 
from    STG_ACCOUNTINFO a ,  STG_BureauResponse b
where   a.applicationid = b.applicationid (+)
group by openmonth
order by 1;

Select openMonth , count(*)
from   Loan_Detail
group by openmonth
order by 1;

truncate table STG_ACCOUNTINFO drop storage;
truncate table STG_BUREAURESPONSE drop storage;
