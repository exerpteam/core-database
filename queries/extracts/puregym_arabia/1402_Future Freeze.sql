-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    t.shortname             AS "Center Name",
    t.center || 'p' || t.id AS "PersonId",
    t.external_id           AS "External Id",
    t.Freeze_Start_Date     AS "Freeze Start Date",
    t.Freeze_End_Date       AS "Freeze End Date",
    t.Freeze_Creation_Date  AS "Freeze Creation Date",
    CASE
        WHEN t.Freeze_type = 'UNRESTRICTED'
        THEN '0'
        ELSE t.Freeze_price
    END                 AS "Freeze Price",
    t.Freeze_Reason     AS "Freeze Reason",
    t.Deduction_Day     AS "Deduction Day",
    t.Subscription_Name AS "Subscription Name"
FROM
    (
        SELECT
            c.shortname,
            p.center,
            p.id,
            p.external_id,
            TO_CHAR(sfp.start_date, 'YYYY-MM-DD')                                                                                                                            AS Freeze_Start_Date,
            TO_CHAR(sfp.end_date, 'YYYY-MM-DD')                                                                                                                              AS Freeze_End_Date,
            TO_CHAR(longtodatec(sfp.entry_time, sfp.subscription_center), 'YYYY-MM-DD HH24:MI')                                                                              AS Freeze_Creation_Date,
            unnest(xpath('/subscriptionType/freeze/period/product[@type = "freezePeriod"]/prices/price/normalPrice/text()',CAST(convert_from(mpr.product, 'UTF-8') AS XML))) AS Freeze_price,
            sfp.type                                                                                                                                                         AS Freeze_type,
            sfp.text                                                                                                                                                         AS Freeze_Reason,
            pag.individual_deduction_day                                                                                                                                     AS Deduction_Day,
            prod.name                                                                                                                                                        AS Subscription_Name
        FROM
            persons p
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
            AND s.owner_id = p.id
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
            AND st.id = s.subscriptiontype_id
        JOIN
            products prod
        ON
            prod.center = st.center
            AND prod.id = st.id
        JOIN
            SUBSCRIPTION_FREEZE_PERIOD sfp
        ON
            sfp.subscription_center = s.center
            AND sfp.subscription_id = s.id
            AND sfp.state = 'ACTIVE'
        LEFT JOIN
            account_receivables ar
        ON
            ar.customercenter = p.center
            AND ar.customerid = p.id
            AND ar.ar_type = 4
        LEFT JOIN
            PAYMENT_ACCOUNTS pa
        ON
            pa.center = ar.center
            AND pa.id = ar.id
        LEFT JOIN
            PAYMENT_AGREEMENTS pag
        ON
            pag.CENTER = pa.ACTIVE_AGR_center
            AND pag.ID = pa.ACTIVE_AGR_id
            AND pag.SUBID = pa.ACTIVE_AGR_SUBID
        LEFT JOIN
            masterproductregister mpr
        ON
            mpr.globalid = prod.globalid
            AND mpr.id = mpr.definition_key
        WHERE
            p.center IN ($$Scope$$)
            AND sfp.start_date BETWEEN $$From_Date$$ AND $$To_Date$$ ) t