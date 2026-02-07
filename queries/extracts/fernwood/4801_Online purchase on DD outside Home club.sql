WITH
          params AS MATERIALIZED
          (
              SELECT
                datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1 AS ToDate
              FROM
                  centers c
         )   
SELECT
        p.center||'p'||p.id AS "ExerpId"
        ,p.fullname AS "Member Name"
        ,cpr.name AS "Payment Request club"
        ,longtodatec(pr.entry_time,pr.center) AS "Payment Request date and Time" 
        ,prs.ref AS "Payment request Reference"        
        ,pr.req_amount AS "Payment Request Amount"
        ,cinv.name AS "Invoice club"
        ,invl.total_amount AS "Invoice Amount" 
        ,invl.center||'inv'||invl.id AS "Invoice Number"   
        ,invl.text AS "Invoice Description"
        ,CASE invl.reason 
                WHEN 0 THEN 'Unknown' 
                WHEN 1 THEN 'Default' 
                WHEN 2 THEN 'Freeze' 
                WHEN 3 THEN 'PersonTypeChange' 
                WHEN 4 THEN 'Upgrade' 
                WHEN 5 THEN 'Downgrade' 
                WHEN 6 THEN 'Transfer' 
                WHEN 7 THEN 'Regret' 
                WHEN 8 THEN 'StopMembership' 
                WHEN 9 THEN 'Autorenew' 
                WHEN 10 THEN 'SavedFreeDays' 
                WHEN 11 THEN 'PayoutMembership' 
                WHEN 12 THEN 'ChangeMembership' 
                WHEN 13 THEN 'DcStopMembership' 
                WHEN 14 THEN 'WrongSale' 
                WHEN 15 THEN 'ProductReturned' 
                WHEN 16 THEN 'FreeCreditline' 
                WHEN 17 THEN 'ManualPriceAdjust' 
                WHEN 18 THEN 'Sanction' 
                WHEN 19 THEN 'ChargedMessageUndeliverable' 
                WHEN 20 THEN 'DcSendAgency' 
                WHEN 21 THEN 'ManualRenew' 
                WHEN 22 THEN 'PrivilegeUsageCancelled' 
                WHEN 23 THEN 'Documentation' 
                WHEN 24 THEN 'WriteOff' 
                WHEN 25 THEN 'PaymentCollectionFeeReversed' 
                WHEN 26 THEN 'ApplyStep' 
                WHEN 27 THEN 'SaleOnAccount' 
                WHEN 28 THEN 'ReminderFee' 
                WHEN 29 THEN 'MemberCardReturned' 
                WHEN 30 THEN 'MemberShipSale' 
                WHEN 31 THEN 'ShopSale' 
                WHEN 32 THEN 'ChangeStartDate' 
                WHEN 33 THEN 'BuyoutClipcard' 
                WHEN 34 THEN 'FamilyPersonTypeChange' 
                WHEN 35 THEN 'FamilySubscriptionChange' 
                WHEN 36 THEN 'Reassign' 
                WHEN 37 THEN 'RegretClipcard' 
                ELSE 'Undefined' 
        END AS Reason
FROM
        fernwood.ar_trans art
JOIN 
        fernwood.payment_request_specifications prs        
        ON art.payreq_spec_center = prs.center
        AND art.payreq_spec_id = prs.id
        AND art.payreq_spec_subid = prs.subid        
JOIN        
        fernwood.payment_requests pr
        ON prs.center = pr.inv_coll_center
        AND prs.id = pr.inv_coll_id
        AND prs.subid = pr.inv_coll_subid  
JOIN
        params 
        ON params.center_id = pr.center 
JOIN
        fernwood.invoice_lines_mt invl
        ON invl.center = art.ref_center
        AND invl.id = art.ref_id
        AND invl.installment_plan_id IS NULL
        AND invl.reason NOT IN (6,30)   
JOIN 
        fernwood.persons p 
        ON p.center = invl.person_center
        AND p.id = invl.person_id 
JOIN
        fernwood.centers cpr
        ON cpr.id = pr.center
JOIN
        fernwood.centers cinv
        ON cinv.id = invl.center                                                                                       
WHERE
        art.collected = 1
        AND 
        art.ref_type IN ('INVOICE') 
        AND
        pr.state in (3,4,18)
        AND
        pr.center IN (:Scope)
        AND
        pr.entry_time BETWEEN params.FromDate AND params.ToDate
        AND
        art.ref_center != pr.center
        AND
        art.amount != 0
        AND
        art.employeecenter ||'emp'||art.employeeid IN ('100emp409','100emp2202','100emp20601','100emp19603','100emp2605')
                
