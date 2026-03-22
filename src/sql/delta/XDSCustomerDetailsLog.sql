--Only collect Reponse records for the last 10 days.
with Application as materialized (
    select  ap.*
		    ,  	ap."ApplicationId"::TEXT "ApplicationId_TEXT"
    from    backoffice.sqlmig."Application" ap
    where   ap."CreateDate" >= CURRENT_DATE - INTERVAL '10 days'
),
Response as materialized (
    Select  a."CreateDate"
		      ,	a."ApplicationId"  
		      , xds."IdNumber"
		      ,	xds."Type" 
          --, 	CASE
          --    WHEN xds."Response" IS NOT NULL AND xds."Response" ~ '<.+>' THEN
          --        ((xpath('//string/text()', xds."Response"::xml))[1])::TEXT::jsonb
          --    ELSE NULL
          --  END AS "Obj"
          , regexp_replace (
		      	regexp_replace(
			         xds."Response",
			         ',?"(bureau_response|encoded_xds_bureau_string|Base64StringJpeg2000Image)": "[^"]*",?',
			         '',
			         'g'
			       )
			      ,	'&#x[0-9A-Fa-f]+;|&#\d+;',  -- matches &#xHEX; and &#DECIMAL;
		         '',
		         'g'
		        )::xml "XmlResponse"
          , dense_rank() over ( partition by xds."ApplicationId", xds."Type" order by "InsertTime" desc ) ranking
    from    Application a , backoffice.public."XDSCustomerDetailsLog" xds
    where   a."ApplicationId_TEXT" = xds."ApplicationId"
    and     xds."Type" in ( 'PreVet' , 'AtlasProductMatrix')
    and     ( xds."Response" LIKE '%max_principal%' or xds."Response" LIKE '%rule_selected_bureau%' )
)
select * from Response;
select  r."CreateDate"	 			
		  , r."ApplicationId" 	
		  , r."IdNumber" 				
		  , r."Type" 	
      --, r."XmlResponse"
      , ((xpath('//string/text()', r."XmlResponse"::xml))[1])::TEXT	"JsonText"
      --, r."Obj"->>'bureau_returned' as "bureau_returned"
      --, r."Obj"->>'score' as "bureau_score"
      --, case when r."Type" = 'AtlasProductMatrix' 
      --	then (r."Obj" -> 'product_matrix' -> 0 ->> 'max_principal')::numeric 
      --	else null
      --	end  AS max_principal
      --, r.ranking
from    Response r
where   r.ranking = 1