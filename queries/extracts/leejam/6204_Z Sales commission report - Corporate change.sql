-- The extract is extracted from Exerp on 2026-02-08
-- Changes to corporate agreement
SELECT DISTINCT
        t1."Status" 
        ,t1.PersonID
        ,t1."Member Name"
        ,t1."Member ID" AS "External ID"
        ,t1."Product Type"
        ,t1."Product Group"
        ,t1."Old Product Name"
        ,t1."Old Act Date"
        ,t1."Old Exp Date"
        ,t1."Product Name"
        ,t1."Activation Date"
        ,t1."Expiry Date"
        ,t1."Purchase Date"
        ,t1."Bill Owner" AS "Sell on behalf"
        ,t1."Bill Owner StaffID" AS "Sell on behalf StaffID"
        ,t1."Bill Created By"
        ,t1."Bill Created By StaffID"
        ,t1."Billed At"
        ,t1."Billed For"
        ,t1."Base Cost"
        ,t1."Actual Cost"
        ,t1."Bill Amount"
        ,t1."Product ID" AS "Subscription ID"
        ,t1."Person Type"
        ,t1."Campaign Name"
        ,t1."Company Agreement"
        ,t1."Mobile No"
        ,t1."SSN"
        ,t1."National ID"
        ,t1."Resident ID"
        ,CASE
                WHEN t1."Employee Source" IN ('100emp4202','100emp2002') THEN 'On-line'
                WHEN t1."Employee Source" NOT IN ('100emp4202','100emp2002') AND t1."Cash Register Comment" IS NOT NULL AND t1.CRType = 13 THEN 'Payment link'
                WHEN t1."Employee Source" =  '100emp7401' THEN 'Payment link'
                ELSE 'In centre'
        END AS "Source"  
        ,t1."Corporate Sales" 
        ,t1."Subscription Stopped" AS "Subscription Stop Date Changed"
        ,max(t1."Clipcard Adjusted") AS "Clipcard Stop Date Changed"                    
FROM
        (                      
        WITH
          params AS
                (
                SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
                FROM
                  centers c
                )
                ,
          notes AS
                (
                SELECT
                    je.person_center,
                    je.person_id ,
                    SUBSTRING((CAST(convert_from(je.big_text, 'UTF-8') AS TEXT)),56,11) AS end_Date,
                    je.creation_time
                FROM
                    journalentries je
                WHERE
                    je.name = 'Clipcard end date changed'
                )
                ,
          clipcard_change AS
                (
                SELECT
                    cc.center,
                    cc.id,
                    cc.subid,
                    notes.creation_time
                FROM
                    clipcards cc
                JOIN
                    notes
                ON
                    notes.end_date = TO_CHAR (longtodate (cc.valid_until),'yyyy-MM-dd')
                AND notes.person_center = cc.owner_center
                AND notes.person_id = cc.owner_id
                )
                ,                 
        ELIGIBLE_SUBSCRIPTIONS AS
                (
                SELECT
                        p.center
                        ,p.id
                        ,s.center as subcenter
                        ,s.id as subid
                        ,s.creator_center
                        ,s.creator_id
                        ,ss.employee_center
                        ,ss.employee_id
                        ,s.creation_time
                        ,s.reassigned_center
                        ,s.reassigned_id
                        ,s.invoiceline_center
                        ,s.invoiceline_id
                        ,prod.globalid
                        ,s.start_date
                        ,s.end_date
                        ,p.fullname
                        ,p.external_id
                        ,pg.name as pgname
                        ,prod.name as prodname
                        ,ss.sales_date
                        ,ssc.shortname as sscshortname
                        ,cs.shortname as csshortname
                        ,prod.price
                        ,CASE p.persontype
                                WHEN 0 THEN 'Private'
                                WHEN 1 THEN 'Student'
                                WHEN 2 THEN 'Staff'
                                WHEN 3 THEN 'Friend'
                                WHEN 4 THEN 'Corporate'
                                WHEN 5 THEN 'One Man Corporate'
                                WHEN 6 THEN 'Family'
                                WHEN 7 THEN 'Senior'
                                WHEN 8 THEN 'Guest'
                                WHEN 9 THEN 'Child'
                                WHEN 10 THEN 'External Staff'
                        END AS PersonType
                        ,peamobile.txtvalue as peamobiletxtvalue
                        ,p.ssn
                        ,p.national_id AS NationalID
                        ,p.resident_id AS ResidentID
                FROM
                        subscription_sales ss
                JOIN
                        subscriptions s
                        ON s.CENTER = ss.SUBSCRIPTION_CENTER
                        AND s.ID = ss.SUBSCRIPTION_ID
                JOIN
                        persons p        
                        ON p.center = s.owner_center
                        AND p.id = s.owner_id
                LEFT JOIN
                        person_ext_attrs peamobile
                        ON peamobile.personcenter = p.center
                        AND peamobile.personid = p.id
                        AND peamobile.name = '_eClub_PhoneSMS'                 
                JOIN
                        subscriptiontypes st
                        ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                        AND st.ID = s.SUBSCRIPTIONTYPE_ID 
                JOIN
                        products prod
                        ON prod.center = st.center
                        AND prod.id = st.id
                JOIN
                        product_group pg
                        ON pg.id = prod.primary_product_group_id                
                JOIN
                        centers ssc
                        ON s.center = ssc.id 
                JOIN
                        centers cs
                        ON cs.id = s.center                                                                                  
                WHERE
                        ss.sales_date BETWEEN :FromDate AND :ToDate
                        AND 
                        s.sub_state != 8
                        AND
                        p.center IN (:Scope)   
                )
                , 
        -----------Sold By--------------
        SOLD_BY AS
                (        
                SELECT
                        es.subcenter
                        ,es.subid
                        ,empps.center 
                        ,empps.fullname as emppsfullname
                        ,empp.fullname as emppfullname
                        ,peas.txtvalue as peastxtvalue
                        ,pea.txtvalue as peatxtvalue
                FROM
                        ELIGIBLE_SUBSCRIPTIONS es
                JOIN
                        employees emp
                        ON emp.center = es.creator_center
                        AND emp.id = es.creator_id
                JOIN
                        persons empp
                        ON empp.center = emp.personcenter
                        AND empp.id = emp.personid
                LEFT JOIN
                        person_ext_attrs pea
                        ON empp.center = pea.personcenter
                        AND empp.id = pea.personid
                        AND pea.name = '_eClub_StaffExternalId'                
                LEFT JOIN
                        employees emps
                        ON emps.center = es.employee_center
                        AND emps.id = es.employee_id
                LEFT JOIN
                        persons empps
                        ON empps.center = emps.personcenter
                        AND empps.id = emps.personid
                LEFT JOIN
                        person_ext_attrs peas
                        ON empps.center = peas.personcenter
                        AND empps.id = peas.personid
                        AND peas.name = '_eClub_StaffExternalId'
                ),
        -----------Previous Subscription-----------
        PREVIOUS_SUB AS
                (        
                SELECT
                        es.subcenter
                        ,es.subid
                        ,oldsub.center
                        ,oldsub.state
                        ,prodoldsub.name
                        ,oldsub.start_date
                        ,oldsub.end_date
                FROM
                        ELIGIBLE_SUBSCRIPTIONS es
                JOIN
                        (
                        SELECT
                                max(s.id) AS LastSub
                                ,s.owner_center
                                ,s.owner_id
                        FROM 
                                subscriptions s
                        JOIN
                                centers c
                                ON c.id = s.center
                        JOIN 
                                params 
                                ON params.CENTER_ID = c.id        
                        WHERE 
                                s.creation_time < params.FromDate
                                AND 
                                s.sub_state != 8
                        GROUP BY 
                                s.owner_center
                                ,s.owner_id 
                        )maxsub
                        ON maxsub.owner_center = es.center
                        AND maxsub.owner_id = es.id 
                JOIN
                        subscriptions oldsub
                        ON oldsub.owner_center = maxsub.owner_center
                        AND oldsub.owner_id = maxsub.owner_id
                        AND oldsub.id = maxsub.LastSub
                JOIN
                        subscriptiontypes stoldsub
                        ON stoldsub.CENTER = oldsub.SUBSCRIPTIONTYPE_CENTER
                        AND stoldsub.ID = oldsub.SUBSCRIPTIONTYPE_ID
                JOIN
                        products prodoldsub
                        ON prodoldsub.center = stoldsub.center
                        AND prodoldsub.id = stoldsub.id 
                ),
        -----------campaigns-----------
        CAMPAIGN AS
                (        
                SELECT
                        es.subcenter
                        ,es.subid
                        ,COALESCE(ps.name,(SELECT substring(je.text from '\(Campaign:(.+)\)'))) AS CampaignName
                FROM
                        ELIGIBLE_SUBSCRIPTIONS es 
                LEFT JOIN
                        (SELECT
                                pu.source_center
                                ,pu.source_id
                                ,su.name
                        FROM
                                privilege_usages pu
                        JOIN
                                privilege_grants pg
                                ON pg.id = pu.grant_id
                        JOIN
                                startup_campaign su
                                ON su.id = pg.granter_id        
                        )ps
                        ON ps.source_center = es.subcenter
                        AND ps.source_id = es.subid                                  
                LEFT JOIN
                        journalentries je
                        ON je.person_center = es.center
                        AND je.person_id = es.id
                        AND je.name = 'Free days added'
                        AND longtodate(je.creation_time) = longtodate(es.creation_time)  
                ),
        ------------reassign and subscription change------------                                                                                                        
        REASSIGNED_AND_CHANGE AS
                (        
                SELECT
                        es.subcenter
                        ,es.subid
                        ,creassigned.shortname
                        ,TO_CHAR(longtodate(schange.change_time),'yyyy-MM-dd') AS SubscriptionStopped
                FROM
                        ELIGIBLE_SUBSCRIPTIONS es 
                JOIN
                        subscriptions reassigned
                        ON reassigned.center = es.reassigned_center
                        AND reassigned.id = es.reassigned_id
                JOIN
                        invoices invreassigned
                        ON invreassigned.center = reassigned.invoiceline_center
                        AND invreassigned.id = reassigned.invoiceline_id
                JOIN
                        cashregistertransactions crtassigned
                        ON crtassigned.paysessionid = invreassigned.paysessionid
                        AND crtassigned.center = invreassigned.cashregister_center
                        AND crtassigned.id = invreassigned.cashregister_id
                JOIN
                        centers creassigned
                        ON creassigned.id = crtassigned.center 
                LEFT JOIN
                        subscription_change schange
                        ON schange.old_subscription_center = es.subcenter
                        AND schange.old_subscription_id = es.subid
                        AND schange.type = 'END_DATE'
                        AND schange.cancel_time IS NULL                   
                ),
        -----------Invoice------------
        INVOICE AS
                (        
                SELECT
                        es.subcenter
                        ,es.subid
                        ,c.shortname as cshortname
                        ,csponsor.shortname as csponsorshortname
                        ,il_sponsor.net_amount as il_sponsornet_amount
                        ,il_mem.net_amount as il_memnet_amount
                        ,il_sponsor.total_amount as il_sponsortotal_amount
                        ,il_mem.total_amount as il_memtotal_amount
                        ,COALESCE(crt_mem.coment,crt_sponsor.coment) AS CashRegisterComment
                        ,COALESCE(cct_mem.transaction_id,cct_sponsor.transaction_id) AS CreditCardTransactionID
                        ,COALESCE(crt_mem.crttype,crt_sponsor.crttype) AS CRType
                        ,sscrt.employeecenter as sscrtemployeecenter
                        ,sscrt.employeeid as sscrtemployeeid
                FROM
                        ELIGIBLE_SUBSCRIPTIONS es
                JOIN 
                        subscriptionperiodparts spp
                        ON es.subcenter = spp.center
                        AND es.subid = spp.id
                        AND spp.spp_type IN (1,8)--SPP_type NORMAL included due to Leejam wanting the new calculated invoice to appear when stop date has changed
                        AND spp.spp_state = 1
                JOIN 
                        spp_invoicelines_link sppinvlnk
                        ON spp.center = sppinvlnk.period_center
                        AND spp.id = sppinvlnk.period_id
                        AND spp.subid = sppinvlnk.period_subid
                JOIN
                        invoice_lines_mt il_mem 
                        ON sppinvlnk.invoiceline_center = il_mem.center
                        AND sppinvlnk.invoiceline_id = il_mem.id
                        AND sppinvlnk.invoiceline_subid = il_mem.subid                
                LEFT JOIN
                        invoices ssinv
                        ON ssinv.center = es.invoiceline_center
                        AND ssinv.id = es.invoiceline_id
                LEFT JOIN
                        cashregistertransactions sscrt 
                        ON sscrt.paysessionid = ssinv.paysessionid
                        AND sscrt.center = ssinv.cashregister_center
                        AND sscrt.id = ssinv.cashregister_id              
                LEFT JOIN
                        centers c
                        ON sscrt.center = c.id
                LEFT JOIN
                        invoices inv_mem
                        ON il_mem.center = inv_mem.center
                        AND il_mem.id = inv_mem.id
                LEFT JOIN                
                        invoices inv_sponsor
                        ON inv_mem.sponsor_invoice_center = inv_sponsor.center
                        AND inv_mem.sponsor_invoice_id = inv_sponsor.id
                LEFT JOIN
                        invoice_lines_mt il_sponsor 
                        ON inv_sponsor.center = il_sponsor.center
                        AND inv_sponsor.id = il_sponsor.id                                                                         
                LEFT JOIN
                        cashregistertransactions crt_mem
                        ON crt_mem.paysessionid = inv_mem.paysessionid
                        AND crt_mem.center = inv_mem.center
                LEFT JOIN
                        creditcardtransactions cct_mem
                        ON cct_mem.gl_trans_center = crt_mem.gltranscenter
                        AND cct_mem.gl_trans_id = crt_mem.gltransid
                        AND cct_mem.gl_trans_subid = crt_mem.gltranssubid               
                LEFT JOIN
                        cashregistertransactions crt_sponsor
                        ON crt_sponsor.paysessionid = inv_sponsor.paysessionid 
                        AND crt_sponsor.center = inv_sponsor.center 
                LEFT JOIN
                        centers csponsor
                        ON crt_sponsor.center = csponsor.id
                LEFT JOIN
                        creditcardtransactions cct_sponsor
                        ON cct_sponsor.gl_trans_center = crt_sponsor.gltranscenter
                        AND cct_sponsor.gl_trans_id = crt_sponsor.gltransid
                        AND cct_sponsor.gl_trans_subid = crt_sponsor.gltranssubid     
                )
                ,
        -----------Corporate-----------
        CORPORATE AS
                (        
                SELECT DISTINCT 
                        es.subcenter
                        ,es.subid
                        ,pg.sponsorship_name
                        ,ca.name as agreementname 
                FROM
                        ELIGIBLE_SUBSCRIPTIONS es 
                JOIN
                        leejam.relatives rel
                                ON rel.center = es.center
                                AND rel.id = es.id
                                AND rel.rtype = 3
                JOIN
                        leejam.companyagreements ca
                                ON ca.center = rel.relativecenter
                                AND ca.id = rel.relativeid
                                AND ca.subid = rel.relativesubid 
                JOIN
                        leejam.privilege_grants pg
                                ON pg.granter_service = 'CompanyAgreement'
                                AND pg.granter_center = ca.center
                                AND pg. granter_id = ca.id
                                AND pg.granter_subid = ca.subid
                JOIN
                        leejam.privilege_usages pu
                                ON pu.person_center = es.center
                                AND pu.person_id = es.id
                                AND pg.id = pu.grant_id                         
                )
                -------------Final Script---------
                SELECT DISTINCT  -----Subscriptions
                        CASE
                                WHEN ps.center IS NULL THEN 'New Sale'
                                WHEN es.start_date - ps.start_date > 90 AND ps.state NOT IN (2,4) THEN 'New Sale'
                                WHEN es.start_date - ps.start_date < 90 AND ps.state NOT IN (2,4) THEN 'Renewal'
                                WHEN ps.state IN (2,4) THEN 'Renewal'
                        END AS "Status" 
                        ,es.center||'p'||es.id as PersonID
                        ,es.fullname AS "Member Name"
                        ,es.external_id AS "Member ID"
                        ,'Subscription' AS "Product Type"
                        ,es.pgname AS "Product Group"
                        ,ps.name AS "Old Product Name"
                        ,TO_CHAR(ps.start_date,'yyyy-MM-dd') AS "Old Act Date"
                        ,TO_CHAR(ps.end_date,'yyyy-MM-dd') AS "Old Exp Date"
                        ,es.prodname AS "Product Name"
                        ,TO_CHAR(es.start_date,'yyyy-MM-dd') AS "Activation Date"
                        ,TO_CHAR(es.end_date,'yyyy-MM-dd') AS "Expiry Date"
                        ,TO_CHAR(es.sales_date,'yyyy-MM-dd') AS "Purchase Date"
                        ,CASE
                                WHEN sb.center IS NOT NULL THEN sb.emppsfullname 
                                ELSE sb.emppfullname
                        END AS "Bill Owner"
                        ,CASE
                                WHEN sb.center IS NOT NULL THEN sb.peastxtvalue
                                ELSE sb.peatxtvalue
                        END AS "Bill Owner StaffID"
                        ,sb.emppfullname AS "Bill Created By"
                        ,sb.peatxtvalue AS "Bill Created By StaffID"
                        ,COALESCE(rac.shortname,inv.cshortname,inv.csponsorshortname,es.sscshortname) AS "Billed At"
                        ,es.csshortname AS "Billed For"
                        ,es.price AS "Base Cost"
                        ,CASE
                                WHEN inv.il_sponsornet_amount IS NOT NULL THEN inv.il_memnet_amount + inv.il_sponsornet_amount
                                ELSE inv.il_memnet_amount
                        END AS "Actual Cost"
                        ,CASE
                                WHEN inv.il_sponsortotal_amount IS NOT NULL THEN inv.il_memtotal_amount + inv.il_sponsortotal_amount 
                                ELSE inv.il_memtotal_amount
                        END AS "Bill Amount"
                        ,es.subcenter||'ss'||es.subid AS "Product ID"
                        ,es.PersonType AS "Person Type"
                        ,cam.CampaignName AS "Campaign Name"
                        ,es.peamobiletxtvalue AS "Mobile No"
                        ,es.ssn AS "SSN"
                        ,es.nationalid AS "National ID"
                        ,es.residentid AS "Resident ID" 
                        ,CASE
                                WHEN es.pgname = 'Corporate' AND cp.SPONSORSHIP_NAME IN ('FIXED', 'FULL', 'PERCENTAGE') THEN 'B2B'
                                WHEN es.pgname = 'Corporate' AND cp.SPONSORSHIP_NAME IS NULL THEN 'B2C'
                                ELSE NULL
                        END AS "Corporate Sales"
                        ,rac.SubscriptionStopped AS "Subscription Stopped"
                        ,NULL AS "Clipcard Adjusted" 
                        ,cp.agreementname AS "Company Agreement"
                        ,inv.CashRegisterComment AS "Cash Register Comment"
                        ,inv.CreditCardTransactionID AS "Credit Card TransactionID"
                        ,CASE
                                WHEN inv.sscrtemployeecenter IS NOT NULL THEN  inv.sscrtemployeecenter||'emp'|| inv.sscrtemployeeid
                                WHEN es.employee_center IS NOT NULL THEN  es.employee_center||'emp'|| es.employee_id 
                                ELSE es.creator_center||'emp'||es.creator_id
                        END AS "Employee Source"
                        ,inv.CRType AS CRType
                FROM
                        ELIGIBLE_SUBSCRIPTIONS es 
                JOIN
                        SOLD_BY sb
                        ON sb.subcenter = es.subcenter
                        AND sb.subid = es.subid
                LEFT JOIN
                        PREVIOUS_SUB ps
                        ON ps.subcenter = es.subcenter
                        AND ps.subid = es.subid
                LEFT JOIN
                        CAMPAIGN cam
                        ON cam.subcenter = es.subcenter
                        AND cam.subid = es.subid
                LEFT JOIN 
                        REASSIGNED_AND_CHANGE rac
                        ON rac.subcenter = es.subcenter
                        AND rac.subid = es.subid
                LEFT JOIN
                        INVOICE inv
                        ON inv.subcenter = es.subcenter
                        AND inv.subid = es.subid  
                LEFT JOIN 
                        CORPORATE cp
                        ON cp.subcenter = es.subcenter
                        AND cp.subid = es.subid  
        UNION ALL
        SELECT DISTINCT --Clipcards
                'New Sale' AS "Status"                              
                ,p.center||'p'||p.id as PersonID
                ,p.fullname AS "Member Name"
                ,p.external_id AS "Member ID"
                ,'Clipcard' AS "Product Type"
                ,pg.name AS "Product Group"
                ,NULL AS "Old Product Name"
                ,NULL AS "Old Act Date"
                ,NULL AS "Old Exp Date"
                ,prod.name AS "Product Name"
                ,TO_CHAR(longtodate(clc.valid_from),'yyyy-MM-dd') AS "Activation Date"
                ,TO_CHAR(longtodate(clc.valid_until),'yyyy-MM-dd') AS "Expiry Date"
                ,TO_CHAR(longtodate(i.trans_time),'yyyy-MM-dd') AS "Purchase Date"
                ,CASE
                        WHEN empps.center IS NOT NULL THEN empps.fullname 
                        ELSE empp.fullname
                END AS "Bill Owner"
                ,CASE
                        WHEN empps.center IS NOT NULL THEN peas.txtvalue 
                        ELSE pea.txtvalue
                END AS "Bill Owner StaffID"
                ,empp.fullname AS "Bill Created By"
                ,pea.txtvalue AS "Bill Created By StaffID"
                ,c.shortname AS "Billed At"
                ,cs.shortname AS "Billed For"
                ,prod.price AS "Base Cost"
                ,inv.net_amount AS "Actual Cost"
                ,inv.total_amount AS "Bill Amount"
                ,clc.center||'cc'||clc.subid AS "Product ID"
                ,CASE p.persontype
                        WHEN 0 THEN 'Private'
                        WHEN 1 THEN 'Student'
                        WHEN 2 THEN 'Staff'
                        WHEN 3 THEN 'Friend'
                        WHEN 4 THEN 'Corporate'
                        WHEN 5 THEN 'One Man Corporate'
                        WHEN 6 THEN 'Family'
                        WHEN 7 THEN 'Senior'
                        WHEN 8 THEN 'Guest'
                        WHEN 9 THEN 'Child'
                        WHEN 10 THEN 'External Staff'
                END AS "Person Type"
                ,'' AS "Campaign Name"
                ,peamobile.txtvalue AS "Mobile No"
                ,p.ssn AS "SSN"
                ,p.national_id AS "National ID"
                ,p.resident_id AS "Resident ID"
                ,NULL AS "Corporate Sales" 
                ,NULL AS "Subscription Stopped"
                ,TO_CHAR(longtodate(cc.creation_time),'dd-MM-yyyy') AS "Clipcard Adjusted"
                ,agreement.name AS "Company Agreement" 
                ,crt.coment AS "Cash Register Comment"
                ,cct.transaction_id AS "Credit Card TransactionID"     
                ,CASE
                        WHEN crt.employeecenter IS NOT NULL THEN crt.employeecenter ||'emp'||crt.employeeid
                        WHEN emps.center IS NOT NULL THEN emps.center||'emp'||emps.id
                        ELSE emp.center||'emp'||emp.id
                END AS "Employee Source" 
                ,crt.crttype AS CRType
        FROM
                clipcards clc
        JOIN
                persons p
                ON p.center = clc.owner_center
                AND p.id = clc.owner_id
        LEFT JOIN
                person_ext_attrs peamobile
                ON peamobile.personcenter = p.center
                AND peamobile.personid = p.id
                AND peamobile.name = '_eClub_PhoneSMS'                
        JOIN
                products prod
                ON prod.center = clc.center
                AND prod.id = clc.id
        JOIN
                product_group pg
                ON pg.id = prod.primary_product_group_id
        LEFT JOIN--current corporate agreement
                (
                SELECT
                        rel.center
                        ,rel.id
                        ,ca.name
                FROM
                        relatives rel
                JOIN
                        companyagreements ca
                        ON ca.center = rel.relativecenter
                        AND ca.id = rel.relativeid
                        AND ca.subid = rel.relativesubid
                WHERE
                        rel.rtype = 3
                        AND 
                        rel.status = 1                        
                )agreement                                                                                         
                ON agreement.center = p.center
                AND agreement.id = p.id                                                          
        JOIN    
                invoice_lines_mt inv
                ON clc.invoiceline_center = inv.center
                AND clc.invoiceline_id = inv.id
                AND clc.invoiceline_subid = inv.subid  
        JOIN 
                invoices i
                ON inv.center = i.center     
                AND inv.id = i.id 
        LEFT JOIN
                cashregistertransactions crt
                ON crt.paysessionid = i.paysessionid
                AND crt.center = i.center
        LEFT JOIN
                creditcardtransactions cct
                ON cct.gl_trans_center = crt.gltranscenter
                AND cct.gl_trans_id = crt.gltransid
                AND cct.gl_trans_subid = crt.gltranssubid                                                    
        JOIN 
                employees emp
                ON emp.CENTER = i.employee_center
                AND emp.ID = i.employee_id 
        JOIN 
                persons empp
                ON empp.CENTER = emp.PERSONCENTER
                AND empp.ID = emp.PERSONID
        LEFT JOIN
                person_ext_attrs pea
                ON empp.center = pea.personcenter
                AND empp.id = pea.personid
                AND pea.name = '_eClub_StaffExternalId'                  
        JOIN
                centers c
                ON c.id = clc.invoiceline_center
        JOIN
                centers cs
                ON cs.id = clc.center 
        LEFT JOIN                                                 
                invoice_sales_employee ins
                ON ins.invoice_center = i.center
                AND ins.invoice_id = i.id  
        LEFT JOIN
                employees emps
                ON emps.center = ins.sales_employee_center
                AND emps.id = ins.sales_employee_id
        LEFT JOIN
                persons empps
                ON empps.center = emps.personcenter
                AND empps.id = emps.personid    
        LEFT JOIN
                person_ext_attrs peas
                ON empps.center = peas.personcenter
                AND empps.id = peas.personid
                AND peas.name = '_eClub_StaffExternalId'                  
        JOIN 
                params 
                ON params.CENTER_ID = c.id           
        LEFT JOIN
                (
                SELECT
                        max(clc.subid) AS Lastcc
                        ,clc.owner_center
                        ,clc.owner_id
                FROM 
                        clipcards clc
                JOIN
                        centers c
                        ON c.id = clc.center
                JOIN 
                        params 
                        ON params.CENTER_ID = c.id        
                WHERE 
                        clc.valid_from < params.FromDate
                        AND
                        clc.cancelled != 'true'
                        AND
                        clc.blocked != 'true'
                GROUP BY 
                        clc.owner_center
                        ,clc.owner_id 
                )maxcc
                ON maxcc.owner_center = clc.owner_center
                AND maxcc.owner_id = clc.owner_id
        LEFT JOIN
                clipcards oldclc
                ON oldclc.owner_center = maxcc.owner_center
                AND oldclc.owner_id = maxcc.owner_id
                AND oldclc.subid = maxcc.Lastcc
        LEFT JOIN
                products oldprod
                ON oldprod.center = oldclc.center
                AND oldprod.id = oldclc.id
        LEFT JOIN
                clipcard_change cc
                ON cc.center = clc.center
                AND cc.id = clc.id
                AND cc.subid = clc.subid                                                          
        WHERE 
                clc.cancelled != 'true'
                AND
                clc.blocked != 'true'
                AND 
                i.trans_time BETWEEN params.FromDate AND params.ToDate
                AND
                p.center IN (:Scope)
        UNION ALL
        SELECT DISTINCT --Comissionable Goods
                'New Sale' AS "Status"                              
                ,p.center||'p'||p.id as PersonID
                ,p.fullname AS "Member Name"
                ,p.external_id AS "Member ID"
                ,'Goods' AS "Product Type"
                ,pg.name AS "Product Group"
                ,'' AS "Old Product Name"
                ,NULL AS "Old Act Date"
                ,NULL AS "Old Exp Date"
                ,prod.name AS "Product Name"
                ,NULL AS "Activation Date"
                ,NULL AS "Expiry Date"
                ,TO_CHAR(longtodate(crt.transtime),'yyyy-MM-dd') AS "Purchase Date"
                ,CASE
                        WHEN pemps.center IS NOT NULL THEN pemps.fullname 
                        ELSE pemp.fullname
                END AS "Bill Owner"
                ,CASE
                        WHEN pemps.center IS NOT NULL THEN peas.txtvalue 
                        ELSE pea.txtvalue
                END AS "Bill Owner StaffID"
                ,pemp.fullname AS "Bill Created By"
                ,pea.txtvalue AS "Bill Created By StaffID"
                ,c.shortname AS "Billed At"
                ,cs.shortname AS "Billed For"
                ,prod.price AS "Base Cost"
                ,inl.net_amount AS "Actual Cost"
                ,inl.total_amount AS "Bill Amount"
                ,prod.center||'prod'||prod.id AS "Product ID"
                ,CASE p.persontype
                        WHEN 0 THEN 'Private'
                        WHEN 1 THEN 'Student'
                        WHEN 2 THEN 'Staff'
                        WHEN 3 THEN 'Friend'
                        WHEN 4 THEN 'Corporate'
                        WHEN 5 THEN 'One Man Corporate'
                        WHEN 6 THEN 'Family'
                        WHEN 7 THEN 'Senior'
                        WHEN 8 THEN 'Guest'
                        WHEN 9 THEN 'Child'
                        WHEN 10 THEN 'External Staff'
                END AS "Person Type"
                ,'' AS "Campaign Name"
                ,peamobile.txtvalue AS "Mobile No"
                ,p.ssn AS "SSN"
                ,p.national_id AS "National ID"
                ,p.resident_id AS "Resident ID" 
                ,NULL AS "Corporate Sales"  
                ,NULL AS "Subscription Stopped"
                ,NULL AS "Clipcard Adjusted" 
                ,agreement.name AS "Company Agreement" 
                ,crt.coment AS "Cash Register Comment"
                ,cct.transaction_id AS "Credit Card TransactionID"
                ,CASE
                        WHEN emps.center IS NOT NULL THEN emps.center||'emp'||emps.id
                        ELSE emp.center||'emp'||emp.id
                END AS "Employee Source"
                ,crt.crttype AS CRType                                                                          
        FROM 
                cashregistertransactions crt
        JOIN
                invoices inv
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id         
        JOIN
                invoice_lines_mt inl 
                ON inv.center = inl.center 
                AND inv.id = inl.id
        JOIN 
                products prod
                ON prod.center = inl.productcenter
                AND prod.id = inl.productid
        JOIN 
                product_and_product_group_link pgl
                ON prod.center = pgl.product_center
                AND prod.id = pgl.product_id
                AND pgl.product_group_id = 2601
        JOIN
                product_group pg
                ON pg.id = prod.primary_product_group_id        
        JOIN
                persons p
                ON p.center = crt.customercenter
                AND p.id = crt.customerid
        LEFT JOIN
                person_ext_attrs peamobile
                ON peamobile.personcenter = p.center
                AND peamobile.personid = p.id
                AND peamobile.name = '_eClub_PhoneSMS' 
        LEFT JOIN--currrent corporate agreement
                (
                SELECT
                        rel.center
                        ,rel.id
                        ,ca.name
                FROM
                        relatives rel
                JOIN
                        companyagreements ca
                        ON ca.center = rel.relativecenter
                        AND ca.id = rel.relativeid
                        AND ca.subid = rel.relativesubid
                WHERE
                        rel.rtype = 3
                        AND 
                        rel.status = 1                        
                )agreement                                                                                         
                ON agreement.center = p.center
                AND agreement.id = p.id                                       
        JOIN 
                employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
        JOIN 
                persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid
        LEFT JOIN
                person_ext_attrs pea
                ON pemp.center = pea.personcenter
                AND pemp.id = pea.personid
                AND pea.name = '_eClub_StaffExternalId'                                            
        LEFT JOIN
                invoice_sales_employee ins
                ON ins.invoice_center = inv.center
                AND ins.invoice_id = inv.id
        LEFT JOIN
                employees emps
                ON emps.center = ins.sales_employee_center
                AND emps.id = ins.sales_employee_id
        LEFT JOIN
                persons pemps
                ON pemps.center = emps.personcenter
                AND pemps.id = emps.personid 
        LEFT JOIN
                person_ext_attrs peas
                ON pemps.center = peas.personcenter
                AND pemps.id = peas.personid
                AND peas.name = '_eClub_StaffExternalId'                         
        JOIN
                centers c
                ON c.id = crt.center
        JOIN
                centers cs
                ON cs.id = inv.center 
        LEFT JOIN -- Product sale cancelled
                credit_note_lines_mt cnl
                ON cnl.invoiceline_center = inl.center
                AND cnl.invoiceline_id = inl.id
                AND cnl.invoiceline_subid = inl.subid
        LEFT JOIN
                creditcardtransactions cct
                ON cct.gl_trans_center = crt.gltranscenter
                AND cct.gl_trans_id = crt.gltransid
                AND cct.gl_trans_subid = crt.gltranssubid                                       
        JOIN 
                params 
                ON params.CENTER_ID = c.id              
        WHERE 
                crt.transtime BETWEEN params.FromDate AND params.ToDate
                AND
                cnl.center IS NULL
                AND
                p.center IN (:Scope)                  
        )t1
GROUP BY
        t1."Status" 
        ,t1.PersonID
        ,t1."Member Name"
        ,t1."Member ID"
        ,t1."Product Type"
        ,t1."Product Group"
        ,t1."Old Product Name"
        ,t1."Old Act Date"
        ,t1."Old Exp Date"
        ,t1."Product Name"
        ,t1."Activation Date"
        ,t1."Expiry Date"
        ,t1."Purchase Date"
        ,t1."Bill Owner"
        ,t1."Bill Owner StaffID" 
        ,t1."Bill Created By"
        ,t1."Bill Created By StaffID"
        ,t1."Billed At"
        ,t1."Billed For"
        ,t1."Base Cost"
        ,t1."Actual Cost"
        ,t1."Bill Amount"
        ,t1."Product ID" 
        ,t1."Person Type"
        ,t1."Campaign Name"
        ,t1."Company Agreement"
        ,t1."Mobile No"
        ,t1."SSN"
        ,t1."National ID"
        ,t1."Resident ID"
        ,t1."Employee Source" 
        ,t1."Corporate Sales" 
        ,t1."Subscription Stopped"  
        ,t1."Cash Register Comment" 
        ,t1.CRType