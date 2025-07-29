-- prod."Loan_Detail" definition

-- Drop table

DROP TABLE prod."Loan_Detail";

CREATE TABLE prod."Loan_Detail" (
	"OpenMonth" int4 NULL,
	"AccountId" int8 NULL,
	"ApplicationId" int8 NULL,
	"OpenDate" timestamp NULL,
	"IdNum" varchar(40) NULL,
	"Consultant" varchar(128) NULL,
	"AgeInMonths" numeric NULL,
	"NumOfInstalments" int8 NULL,
	"AccountType" varchar(32) NULL,
	"PaymentFrequency" varchar(32) NULL,
	"Loan_Size" varchar(32) NULL,
	"Loan_Term" varchar(32) NULL,
	"HandedOver" int4 NULL,
	"FirstArrearDate" timestamp NULL,
	"MonthsFirstArrear" int4 null,
	"FirstDueDate_Missed_Flag" int4 NULL,
	"FirstInstalment_Default_Flag" int4 NULL,
	"One_ever_3_Flag" int4 NULL,
	"Two_ever_6_Flag" int4 NULL,
	"BureauScore" int8 NULL,
	"ApplicationScore" int8 NULL,
	"BranchName" varchar(64) NULL,
	"Debtors_Bank" varchar(64) NULL,
	"Product" varchar(64) NULL,
	"ROLLd_Loan" varchar(10) NULL,
	"CDE_Override" varchar(10) NULL ,
	"Bureau" varchar(64) NULL , 
	"ClientCategory" varchar(128) NULL,
	"ServiceProvider" varchar (128) NULL,
	"OverdueStatus" varchar (128) NULL
);