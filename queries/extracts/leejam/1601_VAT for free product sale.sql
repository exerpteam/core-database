SELECT DISTINCT
         t1."Transaction Date"
	,t1."Person Key"
        ,t1."Member Name"
        ,t1."Invoice reference"
        ,t1."Product"
        ,t1."Product Price"
        ,t1."VAT rate"
        ,t1."Amount"
        ,t1.start_date AS "Start Date"
        ,t1.end_date AS "End Date" 
        --,t1.REASON        
FROM
        (        
        WITH
          params AS
          (
              SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
              FROM
                  centers c
          )
        SELECT
                inl.person_center||'p'||inl.person_id AS "Person Key"
                ,p.fullname AS "Member Name"
                ,inv.center||'inv'||inv.id AS "Invoice reference"
                ,pro.name AS "Product"
                ,pro.price AS "Product Price"
                ,ROUND(vat.rate,2)*100 AS "VAT rate"
                ,ROUND((pro.price * vat.rate),2) AS "Amount"
                ,TO_CHAR(longtodate(inv.entry_time), 'DD-MM-YYYY') AS "Transaction Date"
                ,sub.start_date
                ,sub.end_date
                ,CASE 
                        WHEN inl.reason = 0 THEN 'Unknown' 
                        WHEN inl.reason = 1 THEN 'Default' 
                        WHEN inl.reason = 2 THEN 'Freeze' 
                        WHEN inl.reason = 3 THEN 'PersonTypeChange' 
                        WHEN inl.reason = 4 THEN 'Upgrade' 
                        WHEN inl.reason = 5 THEN 'Downgrade' 
                        WHEN inl.reason = 6 THEN 'Transfer' 
                        WHEN inl.reason = 7 THEN 'Regret' 
                        WHEN inl.reason = 8 THEN 'StopMembership' 
                        WHEN inl.reason = 9 THEN 'Autorenew' 
                        WHEN inl.reason = 10 THEN 'SavedFreeDays' 
                        WHEN inl.reason = 11 THEN 'PayoutMembership' 
                        WHEN inl.reason = 12 THEN 'ChangeMembership' 
                        WHEN inl.reason = 13 THEN 'DcStopMembership' 
                        WHEN inl.reason = 14 THEN 'WrongSale' 
                        WHEN inl.reason = 15 THEN 'ProductReturned' 
                        WHEN inl.reason = 16 THEN 'FreeCreditline' 
                        WHEN inl.reason = 17 THEN 'ManualPriceAdjust' 
                        WHEN inl.reason = 18 THEN 'Sanction' 
                        WHEN inl.reason = 19 THEN 'ChargedMessageUndeliverable' 
                        WHEN inl.reason = 20 THEN 'DcSendAgency' 
                        WHEN inl.reason = 21 THEN 'ManualRenew' 
                        WHEN inl.reason = 22 THEN 'PrivilegeUsageCancelled' 
                        WHEN inl.reason = 23 THEN 'Documentation' 
                        WHEN inl.reason = 24 THEN 'WriteOff' 
                        WHEN inl.reason = 25 THEN 'PaymentCollectionFeeReversed' 
                        WHEN inl.reason = 26 THEN 'ApplyStep' 
                        WHEN inl.reason = 27 THEN 'SaleOnAccount' 
                        WHEN inl.reason = 28 THEN 'ReminderFee' 
                        WHEN inl.reason = 29 THEN 'MemberCardReturned' 
                        WHEN inl.reason = 30 THEN 'MemberShipSale' 
                        WHEN inl.reason = 31 THEN 'ShopSale' 
                        WHEN inl.reason = 32 THEN 'ChangeStartDate' 
                        WHEN inl.reason = 33 THEN 'BuyoutClipcard' 
                        WHEN inl.reason = 34 THEN 'FamilyPersonTypeChange' 
                        WHEN inl.reason = 35 THEN 'FamilySubscriptionChange' 
                        WHEN inl.reason = 36 THEN 'Reassign' 
                        WHEN inl.reason = 37 THEN 'RegretClipcard' 
                        ELSE 'Undefined' 
        END AS REASON
        FROM
                leejam.invoice_lines_mt inl
        JOIN
                leejam.invoices inv 
                        ON inv.center = inl.center 
                        AND inv.id = inl.id 
                        AND inv.employee_center||'emp'||inv.employee_id != '100emp1'       
        JOIN 
                leejam.products pro
                        ON pro.center = inl.productcenter
                        AND pro.id = inl.productid
        LEFT JOIN 
                leejam.product_and_product_group_link ppg
                        ON ppg.product_center = pro.center
                        AND ppg.product_id = pro.id
                        AND ppg.product_group_id = 2204 -- This id may change when moved to production 
        JOIN 
                leejam.product_account_configurations pac
                        ON pac.id = pro.product_account_config_id                                                           
        JOIN
                leejam.accounts act
                        ON act.globalid = pac.sales_account_globalid
                        AND act.center = pro.center 
        JOIN 
                leejam.account_vat_type_group vatg
                        ON vatg.account_center = act.center
                        AND vatg.account_id = act.id
        JOIN
                leejam.account_vat_type_link vatl
                        ON vatl.account_vat_type_group_id = vatg.id
        JOIN
                leejam.vat_types vat
                        ON vat.center = vatl.vat_type_center
                        AND vat.id = vatl.vat_type_id
        JOIN 
                params 
                        ON params.CENTER_ID = inl.center
        JOIN
                leejam.persons p
                        ON p.center = inl.person_center
                        AND p.id = inl.person_id
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
                       ,s.sub_state  
                FROM 
                        leejam.subscriptions s
        
                JOIN
                        leejam.subscriptionperiodparts spp
                        ON s.center = spp.center
                        AND s.id = spp.id
                JOIN            
                        leejam.spp_invoicelines_link spplink
                        ON spp.center = spplink.period_center
                        AND spp.id = spplink.period_id
                        AND spp.subid = spplink.period_subid
                )sub
                ON sub.invoiceline_center = inl.center
                AND sub.invoiceline_id = inl.id
                AND sub.invoiceline_subid = inl.subid                                                                                                                              
        WHERE
                inl.total_amount = 0
                AND
                pro.price != 0
                AND
                ppg.product_group_id IS NULL
                AND
                inl.sponsor_invoice_subid IS NULL
                AND
                inv.entry_time BETWEEN params.FromDate AND params.ToDate
                AND
                (sub.sub_state != 8 OR sub.sub_state IS NULL)
                AND
                inl.center in (:Scope) 
                AND
                inl.reason NOT IN (6,7,8,13,36,37)
        )t1
ORDER BY 6 DESC, 2