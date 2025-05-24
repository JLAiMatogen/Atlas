merge into loan_detail T
using (Select * from STG_ACCOUNTINFO ) S
on    (T.AccountId    = S.AccountId
  and  T.ApplicationId= S.ApplicationId  )
when not matched then
insert ( 
  OPENMONTH
, ACCOUNTID
, IDNUM
, APPLICATIONID
, OPENDATE
, CONSULTANT
, AGEINMONTHS
, NUMOFINSTALMENTS
, ACCOUNTTYPE
, PAYMENTFREQUENCY
, LOAN_SIZE
, LOAN_TERM
, HANDEDOVER
, FIRSTDUEDATE_MISSED_FLAG
, FIRSTINSTALMENT_DEFAULT_FLAG
, ONE_EVER_3_FLAG
, TWO_EVER_6_FLAG
, BUREAU
, BUREAUSCORE
, APPLICATIONSCORE
)
values (
  S.OPENMONTH
, S.ACCOUNTID
, S.IDNUM
, S.APPLICATIONID
, S.OPENDATE
, S.CONSULTANT
, S.AGEINMONTHS
, S.NUMOFINSTALMENTS
, S.ACCOUNTTYPE
, S.PAYMENTFREQUENCY
, S.LOAN_SIZE
, S.LOAN_TERM
, S.HANDEDOVER
, S.FIRSTDUEDATE_MISSED_FLAG
, S.FIRSTINSTALMENT_DEFAULT_FLAG
, S.ONE_EVER_3_FLAG
, S.TWO_EVER_6_FLAG
, 'Experian'
, S.BUREAUSCORE
, S.APPLICATIONSCORE
)
when matched then update
set IDNUM         = S.IDNUM
  , AGEINMONTHS   = S.AGEINMONTHS
  , CONSULTANT    = S.CONSULTANT
  , HANDEDOVER    = S.HANDEDOVER
  , FIRSTDUEDATE_MISSED_FLAG = S.FIRSTDUEDATE_MISSED_FLAG
  , FIRSTINSTALMENT_DEFAULT_FLAG = S.FIRSTINSTALMENT_DEFAULT_FLAG
  , ONE_EVER_3_FLAG   = S.ONE_EVER_3_FLAG
  , TWO_EVER_6_FLAG   = S.TWO_EVER_6_FLAG
  , BUREAU            = coalesce(T.BUREAU,'Experian')
  , BUREAUSCORE       = S.BUREAUSCORE
  , APPLICATIONSCORE  = S.APPLICATIONSCORE;
  

merge into loan_detail T
USING (
  Select  applicationid,  case when ( bureau_returned is null ) then 'Experian' else bureau_returned end bureau_returned
  FROM    STG_BureauResponse 
  where   bureau_score is not null and bureau_score != 0) S
ON  ( T.APPLICATIONID = S.APPLICATIONID )
when matched then update 
set   T.BUREAU = S.BUREAU_RETURNED;


Select * from loan_detail
where  openmonth >= 202501
and    bureau != 'Experian';;

Select openmonth , count(*) 
from   loan_detail l , STG_BureauResponse r
where  l.applicationid = r.applicationid
group by openmonth;
