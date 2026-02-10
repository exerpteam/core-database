-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                                                 AS center
        , datetolongc(date_trunc('month',CURRENT_DATE):: DATE::VARCHAR,c.id) AS from_date_long
        , datetolongc(add_months(date_trunc('month',CURRENT_DATE)::DATE,1):: DATE::VARCHAR,c.id) 
        AS to_date_long
    FROM
        centers c
    )
    , valid_subs AS
    (SELECT
        s.*
        , MIN(s.start_date) over (
                              PARTITION BY
                                  s.owner_center
                                  ,s.owner_id) AS min_start_date
        ,ROW_NUMBER() over (
                        PARTITION BY
                            p.transfers_current_prs_center
                            ,p.transfers_current_prs_id
                        ORDER BY
                            (s.state IN (2,4))::INTEGER DESC
                            ,s.creation_time DESC
                            , (ppgl.product_center IS NOT NULL)::INTEGER DESC) AS rnk
    FROM
        subscriptions s
    JOIN
        persons p
    ON
        p.center = s.owner_center
    AND p.id = s.owner_id
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    LEFT JOIN
        product_and_product_group_link ppgl
    ON
        ppgl.product_center = s.subscriptiontype_center
    AND ppgl.product_id = s.subscriptiontype_id
    AND ppgl.product_group_id= 203
    )
SELECT
    p.center||'p'||p.id AS "Member ID"
    , p.external_id     AS "External ID"
    ,CASE
        WHEN pag.STATE = 1
        THEN 'CREATED'
        WHEN pag.STATE = 2
        THEN 'SENT'
        WHEN pag.STATE = 3
        THEN 'FAILED'
        WHEN pag.STATE = 4
        THEN 'OK'
        WHEN pag.STATE = 5
        THEN 'ENDED, BANK'
        WHEN pag.STATE = 6
        THEN 'ENDED, CLEARING HOUSE'
        WHEN pag.STATE = 7
        THEN 'ENDED, DEBTOR'
        WHEN pag.STATE = 8
        THEN 'CANCELLED, NOT SENT'
        WHEN pag.STATE = 9
        THEN 'CANCELLED, SENT'
        WHEN pag.STATE = 10
        THEN 'ENDED, CREDITOR'
        WHEN pag.STATE = 11
        THEN 'NO AGREEMENT'
        WHEN pag.STATE = 12
        THEN 'CASH PAYMENT'
        WHEN pag.STATE = 13
        THEN 'AGREEMENT NOT NEEDED'
        WHEN pag.STATE = 14
        THEN 'AGREEMENT INFORMATION INCOMPLETE'
        WHEN pag.STATE = 15
        THEN 'TRANSFER'
        WHEN pag.STATE = 16
        THEN 'AGREEMENT RECREATED'
        WHEN pag.STATE = 17
        THEN 'SIGNATURE MISSING'
        ELSE 'UNDEFINED'
    END AS "PaymentAgreementStatus"
    , CASE
        WHEN p.STATUS = 0
        THEN 'LEAD'
        WHEN p.STATUS = 1
        THEN 'ACTIVE'
        WHEN p.STATUS = 2
        THEN 'INACTIVE'
        WHEN p.STATUS = 3
        THEN 'TEMPORARYINACTIVE'
        WHEN p.STATUS = 4
        THEN 'TRANSFERED'
        WHEN p.STATUS = 5
        THEN 'DUPLICATE'
        WHEN p.STATUS = 6
        THEN 'PROSPECT'
        WHEN p.STATUS = 7
        THEN 'DELETED'
        WHEN p.STATUS = 8
        THEN 'ANONYMIZED'
        WHEN p.STATUS = 9
        THEN 'CONTACT'
        ELSE p.STATUS::TEXT
    END AS "PersonStatus"
    , CASE
        WHEN s.STATE = 2
        THEN 'ACTIVE'
        WHEN s.STATE = 3
        THEN 'ENDED'
        WHEN s.STATE = 4
        THEN 'FROZEN'
        WHEN s.STATE = 7
        THEN 'WINDOW'
        WHEN s.STATE = 8
        THEN 'CREATED'
        ELSE s.STATE::TEXT
    END               AS "SubscriptionStatus"
    , ar.balance      AS "AccountBalance"
    , SUM(art.amount) AS "PaymentMadeThisMonth"
    , CASE
        WHEN NOT(
                SUM(art.amount) >0)
        THEN NULL
        ELSE
            CASE
                    -- 1. Frozen → close account
                WHEN s.state = 4
                THEN 'close account'
                    -- 2. Inactive payment agreement + negative balance → continue to chase
                WHEN pag.STATE NOT IN (1,2,4)
                AND ar.balance < 0
                THEN 'continue to chase'
                    -- 3. Account balance 0 → monitor
                WHEN ar.balance = 0
                THEN 'monitor'
                    -- 4. Payment done this month → monitor
                WHEN SUM(art.amount) > 0
                THEN 'monitor'
                    -- 5. Active payment agreement + negative balance → monitor
                WHEN pag.STATE IN (1,2,4)
                AND ar.balance < 0
                THEN 'monitor'
                    -- Else: default
                ELSE 'monitor'
            END
    END AS Label
FROM
    params
JOIN
    persons p
ON
    p.center = params.center
JOIN
    account_receivables ar
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND ar.ar_type = 4
LEFT JOIN
    ar_trans art
ON
    ar.center = art.center
AND ar.id = art.id
AND art.amount > 0
AND art.entry_time BETWEEN params.from_Date_long AND params.to_Date_long
LEFT JOIN
    payment_requests pr
ON
    pr.center||'ar'||pr.id||'req'||pr.subid = art.match_info
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
AND pac.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pag
ON
    pac.ACTIVE_AGR_CENTER = pag.center
AND pac.ACTIVE_AGR_ID = pag.id
AND pac.ACTIVE_AGR_SUBID = pag.subid
LEFT JOIN
    valid_subs s
ON
    s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
AND s.rnk = 1
WHERE
   P.EXTERNAL_ID IN ($$EXTERNALD_IDS$$)
GROUP BY
    p.center
    ,p.id
    , p.external_id
    , pag.STATE
    , p.STATUS
    , s.STATE
    , ar.balance