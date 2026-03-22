backoffice.public.ACC_Account
backoffice.public.ACC_DebitOrder
backoffice.public.ACC_Schedules
backoffice.sqlmig.Address
backoffice.sqlmig.Affordability
backoffice.sqlmig.Application
backoffice.public.Application_AccountMapping
backoffice.sqlmig.Application_Client
backoffice.sqlmig.BankDetail
backoffice.sqlmig.Client
backoffice.sqlmig.CreditScore
backoffice.sqlmig.Disbursement
backoffice.sqlmig.Employer
backoffice.public.PER_Person
backoffice.sqlmig.Quotation
backoffice.public.ACC_PaymentStatusHistory
backoffice.public.XDSCustomerDetailsLog


backoffice.public.ACC_LoanStateReason
backoffice.public.ACC_PaymentStatus
backoffice.public.ACC_PeriodFrequency
backoffice.public.Branch
backoffice.public.PaymentModes
backoffice.public.Bank
backoffice.public.PRD_Products
backoffice.public.ACC_PaymentStatus
backoffice.public.Province
backoffice.public.MaritalStatus
backoffice.public.Languages
backoffice.public.Country


SET enable_nestloop=0;

WITH tables_list(full_table_name) AS (
    VALUES
    ('backoffice.public.ACC_Account'),
    ('backoffice.public.ACC_DebitOrder'),
    ('backoffice.public.ACC_Schedules'),
    ('backoffice.sqlmig.Address'),
    ('backoffice.sqlmig.Affordability'),
    ('backoffice.sqlmig.Application'),
    ('backoffice.public.Application_AccountMapping'),
    ('backoffice.sqlmig.Application_Client'),
    ('backoffice.sqlmig.BankDetail'),
    ('backoffice.sqlmig.Client'),
    ('backoffice.sqlmig.CreditScore'),
    ('backoffice.sqlmig.Disbursement'),
    ('backoffice.sqlmig.Employer'),
    ('backoffice.public.PER_Person'),
    ('backoffice.sqlmig.Quotation'),
    ('backoffice.public.ACC_PaymentStatusHistory'),
    ('backoffice.public.XDSCustomerDetailsLog'),
    ('backoffice.public.ACC_LoanStateReason'),
    ('backoffice.public.ACC_PaymentStatus'),
    ('backoffice.public.ACC_PeriodFrequency'),
    ('backoffice.public.Branch'),
    ('backoffice.public.PaymentModes'),
    ('backoffice.public.Bank'),
    ('backoffice.public.PRD_Products'),
    ('backoffice.public.ACC_PaymentStatus'),
    ('backoffice.public.Province'),
    ('backoffice.public.MaritalStatus'),
    ('backoffice.public.Languages'),
    ('backoffice.public.Country')
),
Table_Attributes as materialized (
	SELECT
	    split_part(full_table_name, '.', 1) AS table_catalog,
	    split_part(full_table_name, '.', 2) AS table_schema,
	    split_part(full_table_name, '.', 3) AS table_name
	FROM tables_list
)
SELECT 'postgresql' AS dbms    
    ,   'Production.'||t.table_catalog table_catelog
    ,   t.table_catalog table_schema
    ,   t.table_schema||'.'||t.table_name table_name
    ,   c.column_name
    ,   c.ordinal_position
    ,   c.data_type
    ,   c.character_maximum_length
    ,   n.constraint_type
    ,   k2.table_schema
    ,   k2.table_name
    ,   k2.column_name 
FROM  Table_Attributes ta ,   information_schema.tables t 
		NATURAL LEFT JOIN information_schema.columns c 
    LEFT JOIN(  information_schema.key_column_usage k 
                    NATURAL JOIN information_schema.table_constraints n 
                    NATURAL LEFT JOIN information_schema.referential_constraints r
            )
        ON  c.table_catalog=k.table_catalog 
        AND c.table_schema=k.table_schema 
        AND c.table_name=k.table_name 
        AND c.column_name=k.column_name 
    LEFT JOIN information_schema.key_column_usage k2 
        ON k.position_in_unique_constraint=k2.ordinal_position 
        AND r.unique_constraint_catalog=k2.constraint_catalog 
        AND r.unique_constraint_schema=k2.constraint_schema 
        AND r.unique_constraint_name=k2.constraint_name
WHERE t.TABLE_TYPE = 'BASE TABLE'
AND   t.table_catalog  = ta.table_catalog 
AND 	t.table_schema 	 = ta.table_schema 
and   t.table_name = ta.table_name 
order by 1 , 2 ,3 ,4 ;