-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-7811
WITH
    debt_mem AS
    (
        SELECT
            cc.*
        FROM
            cashcollectioncases cc
        WHERE
            cc.personcenter IN (:Scope)
        AND cc.closed = 0
        AND cc.missingpayment = 1
    )
    ,
    debt_amount AS
    (
        SELECT
            t.customercenter,
            t.customerid,
            t.person_center,
            t.person_id,
            t.productcenter,
            t.productid,
            t.total_debt,
            COUNT(*)    AS number_debt,
            SUM(t.debt) AS debt
        FROM
            (
                SELECT
                    ar.customercenter,
                    ar.customerid,
                    CASE
                        WHEN il.person_center IS NOT NULL
                        THEN il.person_center
                        ELSE ar.customercenter
                    END AS person_center ,
                    CASE
                        WHEN il.person_id IS NOT NULL
                        THEN il.person_id
                        ELSE ar.customerid
                    END AS person_id ,
                    LEAST(ABS(COALESCE(il.total_amount, art.unsettled_amount)), ABS
                    (art.unsettled_amount)) AS debt,
                    mem.amount              AS total_debt,
                    il.productcenter,
                    il.productid
                FROM
                    debt_mem mem
                JOIN
                    ACCOUNT_RECEIVABLES ar
                ON
                    ar.customercenter = mem.personcenter
                AND ar.customerid = mem.personid
                JOIN
                    ar_trans art
                ON
                    ar.CENTER = art.CENTER
                AND ar.ID = art.ID
                LEFT JOIN
                    invoices inv
                ON
                    art.ref_center = inv.center
                AND art.ref_id = inv.id
                AND art.ref_type = 'INVOICE'
                LEFT JOIN
                    invoice_lines_mt il
                ON
                    inv.center = il.center
                AND inv.id = il.id
                AND il.total_amount <> 0
                WHERE
                    ar.AR_TYPE =4
                AND art.AMOUNT <> 0
                AND art.DUE_DATE < CURRENT_TIMESTAMP
                AND ART.STATUS != 'CLOSED'
                AND il.product_cost IS NOT NULL ) t
        GROUP BY
            t.customercenter,
            t.customerid,
            t.person_center,
            t.productcenter,
            t.productid,
            t.person_id,
            t.total_debt
   )
       ,
    debt_sub AS
    (
        SELECT
            da.*,
            s.center                                                                  AS sub_center,
            s.id                                                                      AS sub_id
        FROM
            debt_amount da
        JOIN
            products pr
        ON
            pr.center = da.productcenter
        AND pr.id = da.productid
        
        JOIN
            subscriptiontypes st
        ON
            st.center = pr.center
        AND st.id = pr.id
        JOIN
            subscriptions s
        ON
            s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id
        AND s.owner_center = da.person_center
        AND s.owner_id = da.person_id
        AND s.sub_state NOT IN (7,8)
    )
SELECT
    c.shortname AS "Club",
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END                     AS "Member Status",
    p.center || 'p' || p.id AS "Member Id",
    p.fullname              AS "Member FullName",
    da.number_debt          AS "Number Of Open Trans",
    da.debt                 AS "Member Debt Case Amount",
    da.total_debt           AS "Debt Case Amount",
    CASE
        WHEN da.customercenter = da.person_center
        AND da.customerid = da.person_id
        THEN NULL
        ELSE op.center || 'p' || op.id
    END AS "Other Payer Id",
    CASE
        WHEN da.customercenter = da.person_center
        AND da.customerid = da.person_id
        THEN NULL
        ELSE op.fullname
    END                                       AS "Other Payer Name",
    prod.name                                 AS "Member Subscription",
    s.subscription_price                      AS "Member Subscription Price",
    TO_CHAR(s.start_date, 'DD.MM.YYYY')       AS "Member Sub Start Date",
    TO_CHAR(s.end_date, 'DD.MM.YYYY')         AS "Member Sub Stop Date",
    TO_CHAR(s.binding_end_date, 'DD.MM.YYYY') AS "Member Sub Binding Date",
    s.center || 'ss' ||s.id                   AS "Member Sub ID",
    CASE s.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS "Member Sub Status",
    CASE s.SUB_STATE
        WHEN 1
        THEN 'NONE'
        WHEN 2
        THEN 'AWAITING_ACTIVATION'
        WHEN 3
        THEN 'UPGRADED'
        WHEN 4
        THEN 'DOWNGRADED'
        WHEN 5
        THEN 'EXTENDED'
        WHEN 6
        THEN 'TRANSFERRED'
        WHEN 7
        THEN 'REGRETTED'
        WHEN 8
        THEN 'CANCELLED'
        WHEN 9
        THEN 'BLOCKED'
        WHEN 10
        THEN 'CHANGED'
        ELSE 'UNKNOWN'
    END                                 AS "Member Sub Sub State",
    payeremail.txtvalue                 AS "Email",
    payermobile.txtvalue                AS "Mobile",
    op.ssn                              AS "Payer SSN",
    p.ssn                               AS "Member SSN",
    op.address1                         AS "Address",
    op.zipcode                          AS "Zip code",
    op.city                             AS "City",
    TO_CHAR(op.birthdate, 'DD.MM.YYYY') AS "Birthday"
FROM
    debt_sub da
JOIN
    persons p
ON
    p.center = da.person_center
AND p.id = da.person_id
JOIN
    centers c
ON
    c.id = p.center
JOIN
    subscriptions s
ON
    s.center = da.sub_center
AND s.id = da.sub_id
JOIN
    products prod
ON
    prod.center = s.subscriptiontype_center
AND prod.id = s.subscriptiontype_id
LEFT JOIN
    PERSONS op
ON
    op.center = da.customercenter
AND op.id = da.customerid
LEFT JOIN
    PERSON_EXT_ATTRS payeremail
ON
    op.center=payeremail.PERSONCENTER
AND op.id=payeremail.PERSONID
AND payeremail.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS payermobile
ON
    op.center=payermobile.PERSONCENTER
AND op.id=payermobile.PERSONID
AND payermobile.name='_eClub_PhoneSMS'