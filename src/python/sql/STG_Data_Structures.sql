-- prod."Loan_Detail" definition
-- Drop table
-- DROP TABLE staging."Loan_Detail";

CREATE TABLE prod."Loan_Detail" (
	"OpenMonth"                     text NULL,
	"AccountId"                     int8 NULL,
	"ApplicationId"                 int8 NULL,
	"OpenDate"                      timestamp NULL,
	"IdNum"                         text NULL,
	"Consultant"                    text NULL,
	"AgeInMonths"                   float8 NULL,
	"NumOfInstalments"              int8 NULL,
	"AccountType"                   text NULL,
	"PaymentFrequency"              text NULL,
	"Loan_Size"                     text NULL,
	"Loan_Term"                     text NULL,
	"HandedOver"                    int8 NULL,
	"FirstDueDate_Missed_Flag"      int8 NULL,
	"FirstInstalment_Default_Flag"  int8 NULL,
	"One_ever_3_Flag"               int8 NULL,
	"Two_ever_6_Flag"               int8 NULL,
	"BureauScore"                   int8 NULL,
	"ApplicationScore"              float8 NULL,
	"BranchName"                    text NULL,
	"Debtors_Bank"                  text NULL,
	"Product"                       text NULL,
	"ROLLd_Loan"                    text NULL,
	"CDE_Override"                  text NULL,
  "Bureau"                        text NULL
);

