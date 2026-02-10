-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2396
WITH
params AS
        (
        SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:StartDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:EndDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate         
        FROM
          centers c
        )
SELECT DISTINCT
        cen.Name AS "Center",
        t1.CampaignName AS "Campaign Name",
        t1.Code AS "Code",
        t1.PrivilegeSetName AS "Privilege set name",
        t1.ProductName AS "Product Purchased",
        t1.PayerCenter || 'p' || t1.PayerId AS "Person ID",
        t1.MemberName AS "Member Name",
        COUNT(t1.Code) AS "Uses",
        CAST(longtodatec(t1.USE_TIME,t1.PayerCenter) as date) AS "Used Time",
        t1.CreatedBy AS "Staff Member"       
FROM
        (
        SELECT
                *
        FROM
                (                
                SELECT
                        COALESCE(s.owner_center, inv.payer_center) AS CENTER,
                        COALESCE(prg.name,sc.name) AS CampaignName,
                        cc.code AS Code,
                        priset.name AS PrivilegeSetName,
                        COALESCE(pu.person_center,inv.payer_center) AS PayerCenter,
                        COALESCE(pu.person_id,inv.payer_id) AS PayerId,
                        pu.use_time AS USE_TIME,
                        COALESCE(prod.name,subprod.name) AS ProductName,
                        COALESCE(invp.fullname,subp.fullname) AS MemberName,
                        COALESCE(prod.center,subprod.center) AS Productcenter,
                        COALESCE(prod.id,subprod.id) AS Productid,
                        COALESCE(empp.fullname,iempp.fullname) AS CreatedBy
                FROM 
                        campaign_codes cc
                JOIN 
                        privilege_usages pu 
                        ON pu.campaign_code_id = cc.id 
                        AND pu.target_service in ('InvoiceLine','SubscriptionPrice') 
                        AND pu.privilege_type = 'PRODUCT'
                JOIN 
                        privilege_grants pgra 
                        ON pgra.id = pu.grant_id
                JOIN 
                        privilege_sets priset 
                        ON priset.id = pgra.privilege_set
                LEFT JOIN 
                        startup_campaign sc 
                        ON sc.id = cc.campaign_id 
                        AND cc.campaign_type ='STARTUP'
                LEFT JOIN 
                        privilege_receiver_groups prg 
                        ON prg.id = cc.campaign_id 
                        AND cc.campaign_type = 'RECEIVER_GROUP'
                LEFT JOIN 
                        invoice_lines_mt invl 
                        ON invl.center = pu.target_center
                        AND invl.id = pu.target_id
                        AND invl.subid = pu.target_subid
                LEFT JOIN 
                        invoices inv 
                        ON inv.center = invl.center 
                        AND inv.id = invl.id                                
                LEFT JOIN                         
                        subscription_price sp 
                        ON sp.id = pu.target_id
                        AND pu.target_service = 'SubscriptionPrice'
                LEFT JOIN 
                        subscriptions s 
                        ON s.center = sp.subscription_center 
                        AND s.id = sp.subscription_id
                LEFT JOIN
                        subscriptiontypes st
                        ON st.center = s.subscriptiontype_center
                        AND st.id = s.subscriptiontype_id                
                LEFT JOIN
                        products subprod
                        ON subprod.center = st.center
                        AND subprod.id = st.id
                LEFT JOIN
                        products prod
                        ON prod.center = invl.productcenter
                        AND prod.id = invl.productid               
                LEFT JOIN
                        persons subp
                        ON subp.center = s.owner_center
                        AND subp.id = s.owner_id
                LEFT JOIN
                        persons invp
                        ON invp.center = inv.payer_center
                        AND invp.id = inv.payer_id
                LEFT JOIN
                        employees emp
                        ON emp.CENTER = s.CREATOR_CENTER
                        AND emp.ID = s.CREATOR_ID
                LEFT JOIN
                        persons empp
                        ON empp.center = emp.personcenter
                        AND empp.id = emp.personid
                LEFT JOIN
                        employees iemp
                        ON iemp.center = inv.employee_center
                        AND iemp.id = inv.employee_id
                LEFT JOIN
                        persons iempp
                        ON iempp.center = iemp.personcenter
                        AND iempp.id = iemp.personid                                                                                                                                                 
                JOIN
                        params
                        ON params.CENTER_ID = pu.person_center
                WHERE
                        pu.USE_TIME BETWEEN params.FromDate AND params.ToDate 
                            		AND (
                		prg.PLUGIN_CODES_NAME = :pluginCodeName
                		OR sc.PLUGIN_CODES_NAME = :pluginCodeName)        
		) t2
        LEFT JOIN
                product_and_product_group_link pgl
                ON pgl.product_center = t2.ProductCenter
                AND pgl.product_id = t2.Productid
                AND pgl.product_group_id IN (3,207,208,209,210,211,2401,3804,3805,3806,4007)              		
        )t1
LEFT JOIN CENTERS cen ON cen.ID = t1.CENTER
WHERE 
        t1.CENTER IN (:scope)
        AND
        t1.product_group_id IS NULL
GROUP BY
        cen.Name,
        t1.CampaignName,
        t1.code,
        t1.PrivilegeSetName,
        t1.PayerCenter,
        t1.PayerId,
        t1.USE_TIME,
        t1.ProductName,
        t1.MemberName,
        t1.CreatedBy
        