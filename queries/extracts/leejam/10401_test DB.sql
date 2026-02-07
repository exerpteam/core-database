SELECT
       
        t1."Member id" as member_id
,t1.subscription_id
        
        ,t1."Product"
        
        ,t1."Total net amount" as net_amount
          
FROM
        (--act.trans_type = 4
        SELECT
                c.id AS "Centre"
                ,c.shortname AS "Centre name"
                ,invl.person_center||'p'||invl.person_id AS "Member id"
                ,p.fullname AS "Member name"
                ,CASE   prod.ptype
                        
                        WHEN 10 THEN sub.center||'ss'||sub.id
                        WHEN 13 THEN subadd.center||'ss'||subadd.id
                        ELSE NULL
                END as subscription_id
                ,prod.name AS "Product"
                ,pg.name AS "Product group" 
                ,TO_CHAR(longtodateC(act.entry_time,act.center),'YYYY-MM-dd')AS "Sales date"  
                ,CASE   prod.ptype
                        WHEN 4 THEN 'CLIPCARD'
                        WHEN 10 THEN 'SUBSCRIPTION'
                        WHEN 13 THEN 'SUBSCRIPTION'
                        ELSE 'OTHER'
                END AS "Product type"
				,CASE   prod.ptype
                        WHEN 4 THEN TO_CHAR(longtodateC(cc.valid_from,cc.center),'YYYY-MM-dd')
                        WHEN 10 THEN TO_CHAR(sub.start_date,'YYYY-MM-dd')
                        WHEN 13 THEN TO_CHAR(subadd.start_date,'YYYY-MM-dd') 
                        ELSE NULL
                END AS "Start date"
                ,CASE   prod.ptype
                        WHEN 4 THEN TO_CHAR(longtodateC(cc.valid_until,cc.center),'YYYY-MM-dd')
                        WHEN 10 THEN TO_CHAR(sub.end_date,'YYYY-MM-dd')
                        WHEN 13 THEN TO_CHAR(subadd.end_date,'YYYY-MM-dd')
                        ELSE NULL
                END AS "End date"
                ,invl.total_amount AS "Total price paid"
                ,invl.net_amount AS "Total net amount"
                ,agt.credit_account_external_id AS "Revenue account id"
				, 'CREDIT' as "GL Type" 
                ,invl.center||'inv'||invl.id AS "Invoice id"
                ,agt.center||'agt'||agt.id AS "Aggregated transaction id"
                ,invl.total_amount - invl.net_amount  AS "VAT amount"              
                ,ROUND((100*agt.vat_rate),2) AS "VAT rate"
                ,agt.credit_vat_account_external_id AS "VAT global account"             
                ,act.trans_type
                ,'TODO' AS "Sponsorship type"                
        FROM        
                aggregated_transactions agt
        JOIN
                account_trans act
                ON act.aggregated_transaction_center = agt.center
                AND act.aggregated_transaction_id = agt.id
                AND act.main_transcenter IS NULL
        JOIN
                invoice_lines_mt invl
                ON invl.account_trans_center = act.center
                AND invl.account_trans_id = act.id
                AND invl.account_trans_subid  = act.subid
        JOIN
                centers c 
                ON c.id = act.center
        LEFT JOIN
                persons p 
                ON p.center = invl.person_center
                AND p.id = invl.person_id
        JOIN
                products prod
                ON prod.center = invl.productcenter
                AND prod.id = invl.productid
        LEFT JOIN
                product_group pg
                ON pg.id = prod.primary_product_group_id
        LEFT JOIN
                (SELECT 
                       s.center
                       ,s.id
                       ,spplink.invoiceline_center
                       ,spplink.invoiceline_id
                       ,spplink.invoiceline_subid
                       ,s.creation_time
                       ,s.start_date
                       ,s.end_date
                       ,'TODO' 
                FROM 
                        subscriptions s       
                JOIN
                        subscriptionperiodparts spp
                        ON s.center = spp.center
                        AND s.id = spp.id
                JOIN            
                        spp_invoicelines_link spplink
                        ON spp.center = spplink.period_center
                        AND spp.id = spplink.period_id
                        AND spp.subid = spplink.period_subid
                JOIN
                        SUBSCRIPTIONTYPES st
                        ON s.SUBSCRIPTIONTYPE_CENTER=st.center
                        AND s.SUBSCRIPTIONTYPE_ID=st.id                        
                JOIN                        
                        PRODUCTS pd
                        ON st.center=pd.center
                        AND st.id=pd.id                                                                 
                )sub
                ON sub.invoiceline_center = invl.center
                AND sub.invoiceline_id = invl.id
                AND sub.invoiceline_subid = invl.subid
                AND prod.ptype = 10
        LEFT JOIN
                (SELECT
                    center,
                    invoiceline_center,
                    invoiceline_id,
                    invoiceline_subid,
                    valid_from,
                    valid_until,
                    ROW_NUMBER() over 
					(partition BY invoiceline_center, 					invoiceline_id,
                    invoiceline_subid 
					ORDER BY valid_from DESC) AS rn
                FROM
                    clipcards) cc
        		ON cc.invoiceline_center = invl.center
        		AND cc.invoiceline_id = invl.id
        		AND cc.invoiceline_subid = invl.subid
        		AND cc.rn = 1
        		AND prod.ptype = 4
        LEFT JOIN
                (SELECT 
                       s.center
                       ,s.id
                       ,spplink.invoiceline_center
                       ,spplink.invoiceline_id
                       ,spplink.invoiceline_subid
                       ,sa.creation_time
                       ,sa.start_date
                       ,sa.end_date  
                FROM 
                        subscriptions s        
                JOIN
                        subscriptionperiodparts spp
                        ON s.center = spp.center
                        AND s.id = spp.id
                JOIN            
                        spp_invoicelines_link spplink
                        ON spp.center = spplink.period_center
                        AND spp.id = spplink.period_id
                        AND spp.subid = spplink.period_subid
                JOIN 
                        subscription_addon sa
                        ON sa.subscription_center = s.center 
                        AND sa.subscription_id = s.id       
                )subadd
                ON subadd.invoiceline_center = invl.center
                AND subadd.invoiceline_id = invl.id
                AND subadd.invoiceline_subid = invl.subid
                AND prod.ptype = 13                                             
        WHERE 
                act.trans_type = 4
                AND
                agt.credit_account_external_id != 'NO_FUSION' 
                AND 
                agt.debit_account_external_id != 'NO_FUSION'
                AND
                agt.credit_account_external_id != agt.debit_account_external_id
                AND
                agt.book_date BETWEEN $$fromdate$$ AND $$todate$$
                AND
                agt.center IN ($$scope$$) 
                AND 
                act.AMOUNT != 0  
        UNION ALL                                                                     
        --act.trans_type = 5
        SELECT
                c.id AS "Centre"
                ,c.shortname AS "Centre name"
                ,cnl.person_center||'p'||cnl.person_id AS "Member id"
                
                ,p.fullname AS "Member name"
                ,CASE   prod.ptype
                        WHEN 10 THEN sub.center||'ss'||sub.id
                        WHEN 13 THEN subadd.center||'ss'||subadd.id
                        ELSE 'x'
                END as subscription_id
                ,prod.name AS "Product"
                ,pg.name AS "Product group" 
                ,TO_CHAR(longtodateC(act.entry_time,act.center),'YYYY-MM-dd')AS "Sales date"  
                ,CASE   prod.ptype
                        WHEN 4 THEN 'CLIPCARD'
                        WHEN 10 THEN 'SUBSCRIPTION'
                        WHEN 13 THEN 'SUBSCRIPTION'
                        ELSE 'OTHER'
                END AS "Product type"
				,CASE   prod.ptype
                        WHEN 4 THEN TO_CHAR(longtodateC(cc.valid_from,cc.center),'YYYY-MM-dd')
                        WHEN 10 THEN TO_CHAR(sub.start_date,'YYYY-MM-dd')
                        WHEN 13 THEN TO_CHAR(subadd.start_date,'YYYY-MM-dd') 
                        ELSE NULL
                END AS "Start date"
                ,CASE   prod.ptype
                        WHEN 4 THEN TO_CHAR(longtodateC(cc.valid_until,cc.center),'YYYY-MM-dd')
                        WHEN 10 THEN TO_CHAR(sub.end_date,'YYYY-MM-dd')
                        WHEN 13 THEN TO_CHAR(subadd.end_date,'YYYY-MM-dd')
                        ELSE NULL
                END AS "End date"
                ,-cnl.total_amount AS "Total price paid"
                ,-cnl.net_amount AS "Total net amount"
                ,agt.debit_account_external_id AS "Revenue account id"
				, 'DEBIT' as "Type"
                ,cnl.center||'cred'||cnl.id AS "Invoice id"
                ,agt.center||'agt'||agt.id AS "Aggregated transaction id"
                ,-cnl.total_amount + cnl.net_amount  AS "VAT amount"              
                ,ROUND((100*agt.vat_rate),2) AS "VAT rate"
                ,agt.debit_vat_account_external_id AS "VAT global account" 
                ,act.trans_type 
                ,'TODO' AS "Sponsorship type"                           
        FROM        
                aggregated_transactions agt
        JOIN
                account_trans act
                ON act.aggregated_transaction_center = agt.center
                AND act.aggregated_transaction_id = agt.id
                AND act.main_transcenter IS NULL
        JOIN
                credit_note_lines_mt cnl
                ON cnl.account_trans_center = act.center
                AND cnl.account_trans_id = act.id
                AND cnl.account_trans_subid  = act.subid
        JOIN
                centers c 
                ON c.id = act.center
        LEFT JOIN
                persons p 
                ON p.center = cnl.person_center
                AND p.id = cnl.person_id
        JOIN
                products prod
                ON prod.center = cnl.productcenter
                AND prod.id = cnl.productid
        LEFT JOIN
                product_group pg
                ON pg.id = prod.primary_product_group_id
        LEFT JOIN
                (SELECT 
                       s.center
                       ,s.id
                       ,spplink.invoiceline_center
                       ,spplink.invoiceline_id
                       ,spplink.invoiceline_subid
                       ,s.creation_time
                       ,s.start_date
                       ,s.end_date
                       ,'TODO' 
                FROM 
                        subscriptions s
        
                JOIN
                        subscriptionperiodparts spp
                        ON s.center = spp.center
                        AND s.id = spp.id
                JOIN            
                        spp_invoicelines_link spplink
                        ON spp.center = spplink.period_center
                        AND spp.id = spplink.period_id
                        AND spp.subid = spplink.period_subid
                        AND spp.subid = spplink.period_subid
                JOIN
                        SUBSCRIPTIONTYPES st
                        ON s.SUBSCRIPTIONTYPE_CENTER=st.center
                        AND s.SUBSCRIPTIONTYPE_ID=st.id                        
                JOIN                        
                        PRODUCTS pd
                        ON st.center=pd.center
                        AND st.id=pd.id    
                        join leejam.invoice_lines_mt il on il.center = spplink.invoiceline_center
                        and  il.id = spplink.invoiceline_id
                       and il.subid = spplink.invoiceline_subid
                                         
                )sub
                ON sub.invoiceline_center = cnl.invoiceline_center
                AND sub.invoiceline_id = cnl.invoiceline_id
                AND sub.invoiceline_subid = cnl.invoiceline_subid
                AND prod.ptype = 10
        LEFT JOIN
                clipcards cc
                ON cc.invoiceline_center = cnl.center 
                AND cc.invoiceline_id = cnl.id 
                AND cc.invoiceline_subid = cnl.subid
                AND prod.ptype = 4 
        LEFT JOIN
                (SELECT 
                       s.center
                       ,s.id
                       ,spplink.invoiceline_center
                       ,spplink.invoiceline_id
                       ,spplink.invoiceline_subid
                       ,sa.creation_time
                       ,sa.start_date
                       ,sa.end_date  
                FROM 
                        subscriptions s
        
                JOIN
                        subscriptionperiodparts spp
                        ON s.center = spp.center
                        AND s.id = spp.id
                JOIN            
                        spp_invoicelines_link spplink
                        ON spp.center = spplink.period_center
                        AND spp.id = spplink.period_id
                        AND spp.subid = spplink.period_subid
                JOIN 
                        subscription_addon sa
                        ON sa.subscription_center = s.center 
                        AND sa.subscription_id = s.id       
                )subadd
                ON subadd.invoiceline_center = cnl.invoiceline_center
                AND subadd.invoiceline_id = cnl.invoiceline_id
                AND subadd.invoiceline_subid = cnl.invoiceline_subid
                AND prod.ptype = 13                                             
        WHERE 
                act.trans_type = 5
                AND
                agt.credit_account_external_id != 'NO_FUSION' 
                AND 
                agt.debit_account_external_id != 'NO_FUSION'
                AND
                agt.credit_account_external_id != agt.debit_account_external_id
                AND
                agt.book_date BETWEEN $$fromdate$$ AND $$todate$$
                AND
                agt.center IN ($$scope$$) 
                AND 
                act.AMOUNT != 0
                        
        )t1   
    where t1."Product type" = 'SUBSCRIPTION'