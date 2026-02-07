WITH
    recursive subs_trans AS
    (
        SELECT
            s.center,
            s.id,
            s.transferred_center,
            s.transferred_id,
            s.invoiceline_center,
            s.invoiceline_id,
            s.invoiceline_subid
        FROM
            subscriptions s
        JOIN
            subscriptions ts
        ON
            ts.transferred_center = s.center
        AND ts.transferred_id = s.id
        WHERE
            s.transferred_center IS NULL
        UNION ALL
        SELECT
            s.center,
            s.id,
            s.transferred_center,
            s.transferred_id,
            subs_trans.invoiceline_center,
            subs_trans.invoiceline_id,
            subs_trans.invoiceline_subid
        FROM
            subscriptions s
        JOIN
            subs_trans
        ON
            subs_trans.center = s.transferred_center
        AND subs_trans.id = s.transferred_id
    )
SELECT
    ss.ID                                                AS "ID",
    ss.SUBSCRIPTION_CENTER || 'ss' || ss.SUBSCRIPTION_ID             AS "SUBSCRIPTION_ID",
    ss.SUBSCRIPTION_CENTER                                           AS "SUBSCRIPTION_CENTER",
    ss.SUBSCRIPTION_TYPE_CENTER || 'prod' || ss.SUBSCRIPTION_TYPE_ID AS "PRODUCT_ID",
    CASE
        WHEN ss.TYPE = 1
        THEN 'NEW'
        WHEN ss.TYPE = 2
        THEN 'EXTENSION'
        WHEN ss.TYPE = 3
        THEN 'CHANGE'
        WHEN ss.TYPE = 4
        THEN 'REACTIVATE'
        ELSE 'UNKNOWN'
    END             AS "TYPE",
    s.CREATION_TIME AS "SALE_DATETIME",
    ss.START_DATE   AS "START_DATE",
    ss.END_DATE     AS "END_DATE",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    persons
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END AS "SALE_PERSON_ID",
    -- JOINING FEE
    ss.PRICE_NEW + ss.PRICE_NEW_DISCOUNT  AS "JF_NORMAL_PRICE",
    ss.PRICE_NEW_DISCOUNT                 AS "JF_DISCOUNT",
    ss.PRICE_NEW                          AS "JF_PRICE",
    ss.PRICE_NEW_SPONSORED                AS "JF_SPONSORED",
    ss.PRICE_NEW - ss.PRICE_NEW_SPONSORED AS "JF_MEMBER",
    -- PRO RATA PERIOD
    ss.PRICE_PRORATA + ss.PRICE_PRORATA_DISCOUNT  AS "PRORATA_PERIOD_NORMAL_PRICE",
    ss.PRICE_PRORATA_DISCOUNT                     AS "PRORATA_PERIOD_DISCOUNT",
    ss.PRICE_PRORATA                              AS "PRORATA_PERIOD_PRICE",
    ss.PRICE_PRORATA_SPONSORED                    AS "PRORATA_PERIOD_SPONSORED",
    ss.PRICE_PRORATA - ss.PRICE_PRORATA_SPONSORED AS "PRORATA_PERIOD_MEMBER",
    -- INITIAL PERIOD
    ss.PRICE_INITIAL + ss.PRICE_INITIAL_DISCOUNT  AS "INIT_PERIOD_NORMAL_PRICE",
    ss.PRICE_INITIAL_DISCOUNT                     AS "INIT_PERIOD_DISCOUNT",
    ss.PRICE_INITIAL                              AS "INIT_PERIOD_PRICE",
    ss.PRICE_INITIAL_SPONSORED                    AS "INIT_PERIOD_SPONSORED",
    ss.PRICE_INITIAL - ss.PRICE_INITIAL_SPONSORED AS "INIT_PERIOD_MEMBER",
    -- ADMIN FEE
    ss.PRICE_ADMIN_FEE + ss.PRICE_ADMIN_FEE_DISCOUNT  AS "ADMIN_FEE_NORMAL_PRICE",
    ss.PRICE_ADMIN_FEE_DISCOUNT                       AS "ADMIN_FEE_DISCOUNT",
    ss.PRICE_ADMIN_FEE                                AS "ADMIN_FEE_PRICE",
    ss.PRICE_ADMIN_FEE_SPONSORED                      AS "ADMIN_FEE_SPONSORED",
    ss.PRICE_ADMIN_FEE - ss.PRICE_ADMIN_FEE_SPONSORED AS "ADMIN_FEE_MEMBER",
    ss.BINDING_DAYS                                   AS "BINDING_DAYS",
    CASE
        WHEN s.INVOICELINE_CENTER IS NOT NULL
        THEN s.INVOICELINE_CENTER||'inv'||s.INVOICELINE_ID
        WHEN subs_trans.INVOICELINE_CENTER IS NOT NULL
        THEN subs_trans.INVOICELINE_CENTER||'inv'||subs_trans.INVOICELINE_ID
        ELSE NULL
    END                           AS "SALE_ID",
    ss.CONTRACT_INCLUDING_SPONSOR AS "INIT_CONTRACT_VALUE",
    CASE
        WHEN ss.CANCELLATION_DATE IS NULL
        THEN 'ACTIVE'
        ELSE 'CANCELLED'
    END AS "STATE",
    CASE
        WHEN s.INVOICELINE_CENTER IS NOT NULL
        THEN s.INVOICELINE_CENTER||'inv'||s.INVOICELINE_ID||'ln'||s.INVOICELINE_SUBID
        WHEN subs_trans.INVOICELINE_CENTER IS NOT NULL
        THEN subs_trans.INVOICELINE_CENTER||'inv'||subs_trans.INVOICELINE_ID||'ln'||
            subs_trans.INVOICELINE_SUBID
        ELSE NULL
    END AS "JF_SALE_LOG_ID",
    CASE
        WHEN sc.OLD_SUBSCRIPTION_CENTER IS NOT NULL
        THEN sc.OLD_SUBSCRIPTION_CENTER||'ss'||sc.OLD_SUBSCRIPTION_ID
        ELSE NULL
    END                    AS "PREVIOUS_SUBSCRIPTION_ID",
    ss.SUBSCRIPTION_CENTER AS "CENTER_ID",
    ss.LAST_MODIFIED          "ETS",
    ss.sales_date   AS "SALE_DATE"
FROM
    SUBSCRIPTION_SALES ss
JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ss.EMPLOYEE_CENTER
AND emp.ID = ss.EMPLOYEE_ID
JOIN
    PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
AND p.ID = emp.PERSONID
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = ss.SUBSCRIPTION_CENTER
AND s.ID = ss.SUBSCRIPTION_ID
LEFT JOIN
    SUBSCRIPTION_CHANGE sc
ON
    sc.NEW_SUBSCRIPTION_CENTER = ss.SUBSCRIPTION_CENTER
AND sc.NEW_SUBSCRIPTION_ID = ss.SUBSCRIPTION_ID
AND sc.TYPE = 'TYPE'
LEFT JOIN
    subs_trans
ON
    subs_trans.center = s.center
AND subs_trans.id = s.id

 