
Drop table TESTWRITETABLE;

Create table TESTWRITETABLE (
  BANKID      NUMBER
, CODE	      VARCHAR2(20)
, DESCRIPTION	VARCHAR2(256)

)
/

Select count(*) from TESTWRITETABLE;

Select count(*) from "TestBureauResponse";

drop table STG_BureauResponse;

CREATE TABLE "STG_BUREAURESPONSE" (
  "APPLICATIONDATE"   NUMBER
, "ACCOUNTID"         NUMBER
, "APPLICATIONID"     NUMBER    
, "IDNUMBER"          VARCHAR2(128)
, "TYPE"              VARCHAR2(40)
, "BUREAU_RETURNED"   VARCHAR2(40)
, "BUREAU_SCORE"      NUMBER
);

truncate table STG_BUREAURESPONSE;

Select * from STG_BureauResponse;

Select Applicationdate , count(*)
from   STG_BureauResponse
group by Applicationdate
order by 1;

Select applicationid , accountid,type,BUREAU_RETURNED,IDNUMBER,count(*)
from STG_BureauResponse
group by applicationid , accountid,type,BUREAU_RETURNED,IDNUMBER
having count(*) >= 2;


DROP TABLE STG_ACCOUNTINFO;

CREATE TABLE "STG_ACCOUNTINFO" (
  "OPENMONTH"                     VARCHAR2(6)
, "ACCOUNTID"                     VARCHAR2(40)
, "IDNUM"                         VARCHAR2(40)
, "APPLICATIONID"                 VARCHAR2(40)
, "ACCOUNTTYPE"                   VARCHAR2(5)
, "OPENDATE"                      TIMESTAMP
, "AGEINMONTHS"                   NUMBER  
, "NUMOFINSTALMENTS"              NUMBER
, "BRANCHNAME"                    VARCHAR2(128)
, "CONSULTANT"                    VARCHAR2(128)
, "PAYMENTFREQUENCY"              VARCHAR2(40)
, "LOAN_TERM"                     VARCHAR2(40)
, "DEBTORS_BANK"                  VARCHAR2(128)
, "LOAN_SIZE"                     VARCHAR2(40)
, "ROLLD_LOAN"                    VARCHAR2(10)
, "PRODUCT"                       VARCHAR2(64)
, "CREDIT_SCORE_OR_CAT"           VARCHAR2(128)
, "CDE_OVERRIDE"                  VARCHAR2(10)
, "HANDEDOVER"                    NUMBER
, "FIRSTDUEDATE_MISSED_FLAG"      NUMBER 
, "FIRSTINSTALMENT_DEFAULT_FLAG"  NUMBER 
, "ONE_EVER_3_FLAG"               NUMBER
, "TWO_EVER_6_FLAG"               NUMBER
, "BUREAUSCORE"                   NUMBER
, "APPLICATIONSCORE"              NUMBER
);






