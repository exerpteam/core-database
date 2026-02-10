-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1."Centre"
        ,t1."Centre name"
        ,t1."Member id"
        ,t1."Member name"
        ,t1."Product"
        ,t1."Product group" 
        ,t1."Sales date"  
        ,t1."Start date"
        ,t1."End date"
        ,t1."Total price paid"
        ,t1."Total net amount"
        ,t1."Revenue account id"
        ,t1."Invoice id"
        ,t1."Aggregated transaction id"
        ,t1."VAT amount"              
        --,t1."VAT rate"
        ,t1."VAT global account" 
        ,t1."Sponsorship type"
FROM
        (--act.trans_type = 4
        SELECT
                c.id AS "Centre"
                ,c.shortname AS "Centre name"
                ,invl.person_center||'p'||invl.person_id AS "Member id"
                ,p.fullname AS "Member name"
                ,prod.name AS "Product"
                ,pg.name AS "Product group" 
                ,TO_CHAR(longtodateC(act.entry_time,act.center),'YYYY-MM-dd')AS "Sales date"  
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
                ,invl.center||'inv'||invl.id AS "Invoice id"
                ,agt.center||'agt'||agt.id AS "Aggregated transaction id"
                ,invl.total_amount - invl.net_amount  AS "VAT amount"              
                ,ROUND((100*agt.vat_rate),2) AS "VAT rate"
                ,agt.credit_vat_account_external_id AS "VAT global account"             
                ,act.trans_type
                ,sub.SPONSORSHIP_NAME AS "Sponsorship type"
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
                       ,priv.SPONSORSHIP_NAME  
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
                LEFT JOIN
                    (
                        SELECT
                            t2.center,
                            t2.id,
                            t2.SPONSORSHIP_NAME,
                            t2.REF_GLOBALID,
                            t2.SPONSORSHIP_AMOUNT
                        FROM
                            (
                                SELECT
                                    car.center,
                                    car.id,
                                    pp.REF_GLOBALID,
                                    pg.SPONSORSHIP_NAME,
                                    pg.sponsorship_amount,
                                    pg.valid_from,
                                    RANK() OVER (PARTITION BY car.center,car.id,pg.GRANTER_CENTER, pg.granter_id,
                                    ref_globalid ORDER BY pg.valid_from DESC) AS Latest,
                                    pg.GRANTER_CENTER,
                                    pg.granter_id,
                                    pg.GRANTER_SUBID
                                FROM
                                    relatives car
                                JOIN
                                    COMPANYAGREEMENTS ca
                                        ON ca.center = car.RELATIVECENTER
                                        AND ca.id = car.RELATIVEID
                                        AND ca.SUBID = car.RELATIVESUBID
                                JOIN
                                    PRIVILEGE_GRANTS pg
                                        ON pg.GRANTER_SERVICE='CompanyAgreement'
                                        AND pg.GRANTER_CENTER=ca.center
                                        AND pg.granter_id=ca.id
                                        AND pg.GRANTER_SUBID = ca.SUBID
                                        AND pg.SPONSORSHIP_NAME!= 'NONE'
                                        AND (
                                                pg.VALID_TO IS NULL
                                            OR  pg.VALID_TO > datetolong(TO_CHAR(CAST(now() AS DATE), 'YYYY-MM-DD HH24:MM')
                                                ) )
                                JOIN
                                    PRODUCT_PRIVILEGES pp
                                        ON pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
                                WHERE
                                    car.RTYPE = 3
                                AND car.STATUS < 3
                                )t2 -- SCOPE
                        WHERE
                            t2.latest = 1 ) priv
                        ON priv.center=s.owner_center
                        AND priv.id = s.owner_id
                        AND priv.REF_GLOBALID = pd.GLOBALID                                           
                )sub
                ON sub.invoiceline_center = invl.center
                AND sub.invoiceline_id = invl.id
                AND sub.invoiceline_subid = invl.subid
                AND prod.ptype = 10
        LEFT JOIN
                clipcards cc
                ON cc.invoiceline_center = invl.center 
                AND cc.invoiceline_id = invl.id 
                AND cc.invoiceline_subid = invl.subid
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
                agt.book_date BETWEEN :From AND :To
                AND
                agt.center IN (:Scope) 
                AND act.AMOUNT != 0  
        UNION ALL                                                                     
        --act.trans_type = 5
        SELECT
                c.id AS "Centre"
                ,c.shortname AS "Centre name"
                ,cnl.person_center||'p'||cnl.person_id AS "Member id"
                ,p.fullname AS "Member name"
                ,prod.name AS "Product"
                ,pg.name AS "Product group" 
                ,TO_CHAR(longtodateC(act.entry_time,act.center),'YYYY-MM-dd')AS "Sales date"  
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
                ,cnl.center||'cred'||cnl.id AS "Invoice id"
                ,agt.center||'agt'||agt.id AS "Aggregated transaction id"
                ,-cnl.total_amount + cnl.net_amount  AS "VAT amount"              
                ,ROUND((100*agt.vat_rate),2) AS "VAT rate"
                ,agt.debit_vat_account_external_id AS "VAT global account" 
                ,act.trans_type
                ,sub.SPONSORSHIP_NAME AS "Sponsorship type"            
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
                       ,priv.SPONSORSHIP_NAME  
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
                LEFT JOIN
                    (
                        SELECT
                            t2.center,
                            t2.id,
                            t2.SPONSORSHIP_NAME,
                            t2.REF_GLOBALID,
                            t2.SPONSORSHIP_AMOUNT
                        FROM
                            (
                                SELECT
                                    car.center,
                                    car.id,
                                    pp.REF_GLOBALID,
                                    pg.SPONSORSHIP_NAME,
                                    pg.sponsorship_amount,
                                    pg.valid_from,
                                    RANK() OVER (PARTITION BY car.center,car.id,pg.GRANTER_CENTER, pg.granter_id,
                                    ref_globalid ORDER BY pg.valid_from DESC) AS Latest,
                                    pg.GRANTER_CENTER,
                                    pg.granter_id,
                                    pg.GRANTER_SUBID
                                FROM
                                    relatives car
                                JOIN
                                    COMPANYAGREEMENTS ca
                                        ON ca.center = car.RELATIVECENTER
                                        AND ca.id = car.RELATIVEID
                                        AND ca.SUBID = car.RELATIVESUBID
                                JOIN
                                    PRIVILEGE_GRANTS pg
                                        ON pg.GRANTER_SERVICE='CompanyAgreement'
                                        AND pg.GRANTER_CENTER=ca.center
                                        AND pg.granter_id=ca.id
                                        AND pg.GRANTER_SUBID = ca.SUBID
                                        AND pg.SPONSORSHIP_NAME!= 'NONE'
                                        AND (
                                                pg.VALID_TO IS NULL
                                            OR  pg.VALID_TO > datetolong(TO_CHAR(CAST(now() AS DATE), 'YYYY-MM-DD HH24:MM')
                                                ) )
                                JOIN
                                    PRODUCT_PRIVILEGES pp
                                        ON pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
                                WHERE
                                    car.RTYPE = 3
                                AND car.STATUS < 3
                                )t2 -- SCOPE
                        WHERE
                            t2.latest = 1 ) priv
                        ON priv.center=s.owner_center
                        AND priv.id = s.owner_id
                        AND priv.REF_GLOBALID = pd.GLOBALID                          
                )sub
                ON sub.invoiceline_center = cnl.center
                AND sub.invoiceline_id = cnl.id
                AND sub.invoiceline_subid = cnl.subid
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
                ON subadd.invoiceline_center = cnl.center
                AND subadd.invoiceline_id = cnl.id
                AND subadd.invoiceline_subid = cnl.subid
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
                agt.book_date BETWEEN :From AND :To
                AND
                agt.center IN (:Scope)
                AND act.AMOUNT != 0
        )t1                