--Application Data

-_Filters to be build
--OpenMonth 
--Branch
--Consultant 
--PaymentFrequency, Loan_Term , Debtors_Bank
--Loan_Size, ROLLd_loan, Product, Credit_Score_OR_CAT, CDE_Override

Select * from backoffice.dbo.BankDetail bd ;
Select * from backoffice.dbo.Bank b ;
Select * from backoffice.dbo.Bank;
Select * from backoffice.dbo.Quotation q ;
Select * from backoffice.dbo.Quotation q ;
Select * from backoffice.dbo.LoanReason lr ;
Select * from backoffice.dbo.PRD_Products_PGDUP ppp2;

select * from backoffice.sqlmig."Application";

-- Previously only exported data where the AccountId  is null
-- Now export all data to get the enquiries as well.
-- These are the application data with out any account associated.
with LoanData as (
	Select 	a."ApplicationId"
		,	a."AccountId"
		,   b."BranchName" 
		,	b2."Description" Debtors_Bank
		,   ppp2."Description"  "Product"
		,	case when ( q."IsRollOver") then 'Yes' else 'No' end "ROLLd_Loan"
		,   case when ( a."IsGetOfferOverride") then 'Yes' ELSE 'No' end "CDE_Override"
	from 	backoffice.sqlmig."Application" a 
					left outer join backoffice.sqlmig."Branch" b
						on	a."BranchId" = b."BranchId" 
					left outer join backoffice.Sqlmig."BankDetail" bd 
						on  a."BankDetailId"   = bd."BankDetailId"
					left outer join backoffice.sqlmig."Bank" b2 
						on  bd."BankId"  		 = b2."BankId"
					left outer join backoffice.Sqlmig."Quotation" q 
						on	a."QuotationId"    = q."QuotationId"
					left outer join backoffice.public."PRD_Products" ppp2 
						on	a."ProductId"      = ppp2."ProductId"
	where   a."CreateDate"  between	
			Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '24 months') and
			Date_Trunc('MONTH',CURRENT_DATE - INTERVAL '00 months')
)
Select * from LoanData;