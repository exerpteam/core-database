-- The extract is extracted from Exerp on 2026-02-08
--  
-- Ineligible - People who bought eligibile subscription on given day but were exlcuded by other reasons

WITH params AS(        
    

    SELECT
    
        /*+ materialize */
        datetolongTZ(TO_CHAR(current_date - :Offset,'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateFrom,
        datetolongTZ(TO_CHAR(current_date - (:Offset - 1),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateTo,

 datetolongTZ(TO_CHAR(DATE '2020-02-01','YYYY-MM-DD HH24:MI:SS'), c.time_zone)	AS cutDateAbsolute,
        c.id AS centerid
    
    FROM
    
        goodlife.centers c
    
    WHERE
    
        c.time_zone IS NOT NULL
    
),Subscriptions_Eligible AS (

    SELECT DISTINCT

        s.owner_center
        ,s.owner_id
        ,prod.name
        ,(CASE
        WHEN pu.target_center IS NOT NULL
            THEN 'Campaign Used'
            ELSE ''
        END) AS Campaign_Used           
         ,(CASE
            WHEN s.state NOT IN (2,4)
            THEN 'Subscription Not in State Active or Frozen'
            ELSE ''
        END) AS State
        ,(CASE
            WHEN ccc.missingpayment = 1
            THEN CASE
            WHEN ccc.personcenter IS NOT NULL AND r.center IS NOT NULL
                    THEN 'Debt Case - Other Payor'
                    WHEN ccc.personcenter IS NOT NULL
                    THEN 'Debt Case - Member'
                END
        WHEN ccc.missingpayment = 0
            THEN CASE WHEN ccc.personcenter IS NOT NULL AND r.center IS NOT NULL
                    THEN 'Missing Agreement Case - Other Payor'
                    WHEN ccc.personcenter IS NOT NULL
                    THEN 'Missing Agreement Case - Member'
                END
          ELSE ''
        END) AS Debt
        ,CASE
            WHEN ss.type != 1
            THEN 'Subscription Change'
            ELSE ''
        END AS Chng
      
    FROM
    
        subscription_sales ss
    
        JOIN subscriptions s_sales
        ON ss.subscription_center = s_sales.center
        AND ss.subscription_id = s_sales.id
		AND ss.sales_date <= '2020-01-31'

        JOIN subscriptions s
        ON
            (
                (
                    -- subscription not changed (the subscription at the time of the sale is not ended)
                    s_sales.state IN (2,4) 
                    AND s.center = s_sales.center
                    AND s.id = s_sales.id
                )
                OR (
                    -- the s_sales subscroiption has been changed to another one, we JOIN to this one
                    s_sales.changed_to_center IS NOT NULL 
                    AND s.center = s_sales.changed_to_center 
                    AND s.id = s_sales.changed_to_id
                )
            )
        -- AND s.state NOT IN (2,4)
        AND s_sales.start_date = CURRENT_DATE - :Offset

        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON ppgl.product_center = s.subscriptiontype_center
        AND ppgl.product_id = s.subscriptiontype_id
        AND ppgl.product_group_id IN (:EligibilityProductGroup)

        JOIN products prod
        ON prod.center = s.subscriptiontype_center
        AND prod.id = s.subscriptiontype_id

        LEFT JOIN relatives r
        ON s.owner_center = r.relativecenter
        AND s.owner_id = r.relativeid
        AND r.status = 1
        AND r.rtype = 12 

        LEFT JOIN goodlife.cashcollectioncases ccc
        ON  
            CASE
                WHEN r.center IS NOT NULL
                THEN r.center = ccc.personcenter AND r.id = ccc.personid
                ELSE s.owner_center = ccc.personcenter AND s.owner_id = ccc.personid
            END 
        AND ccc.missingpayment IN (0,1)
        AND ccc.closed = 0  

        JOIN spp_invoicelines_link spl
        ON spl.period_center = s.center
        AND spl.period_id = s.id

        LEFT JOIN privilege_usages pu
        ON pu.target_center = spl.invoiceline_center
        AND pu.target_id = spl.invoiceline_id
        AND pu.target_subid = spl.invoiceline_subid
        AND pu.target_service = 'InvoiceLine'

        WHERE

            s.state NOT IN (2,4)
            OR ccc.personid IS NOT NULL
            OR pu.target_center IS NOT NULL

    UNION ALL
    
    SELECT
    
        c.owner_center
        ,c.owner_id
        ,prod.name
        ,CASE
            WHEN pu.target_center IS NOT NULL
            THEN 'Campaign Used'
            ELSE ''
        END AS campaign_used
        ,CASE
            WHEN c.cancelled = TRUE
            THEN 'Clipcard Cancelled'
            ELSE ''
        END as state
        ,TEXT '' AS Debt
        ,TEXT '' AS chng
    
    FROM
    
        invoice_lines_mt inv

        JOIN clipcards c
        ON c.invoiceline_center = inv.center
        AND c.invoiceline_id = inv.id
        AND c.invoiceline_subid = inv.subid

        JOIN params ON params.centerid = inv.center   

        JOIN invoices i
        ON i.center = inv.center
        AND i.id = inv.id
        AND i.entry_time BETWEEN params.cutdatefrom AND params.cutdateto
		AND i.entry_time < params.cutdateabsolute

        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON ppgl.product_center = c.center
        AND ppgl.product_id = c.id
        AND ppgl.product_group_id IN (:EligibilityProductGroup)

        JOIN products prod
        ON prod.center = c.center
        AND prod.id = c.id

        LEFT JOIN privilege_usages pu
        ON pu.target_center = c.invoiceline_center
        AND pu.target_id = c.invoiceline_id
        AND pu.target_subid = c.invoiceline_subid
        AND pu.target_service = 'InvoiceLine'

    WHERE
            
        c.cancelled = TRUE
        OR C.blocked = TRUE
        OR pu.target_center IS NOT NULL
            
)

SELECT

    p.external_id AS "Person ID"
    ,p.center||'p'||p.id AS "Exerp Person ID"
    ,s.name AS Product
    
    ,(CASE
        WHEN s.Campaign_Used != ''
        THEN s.Campaign_Used||', '
        ELSE ''
    END)||(CASE
        WHEN s.debt != ''
        THEN s.Debt||', '
        ELSE ''
    END)||(CASE
        WHEN s.chng != ''
        THEN s.chng||', '
        ELSE ''
    END)||(CASE
        WHEN s.state != ''
        THEN s.state
        ELSE ''
    END) AS "Ineligibility Reason(s)"
    ,CURRENT_DATE AS "Date Extract Was Run"
    ,NULL AS "Code"
     ,NULL AS "Date Code Sent"


FROM

    Subscriptions_Eligible s

    JOIN persons p
    ON p.center = s.owner_center
    AND p.id = s.owner_id