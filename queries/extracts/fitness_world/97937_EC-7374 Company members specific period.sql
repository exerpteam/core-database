-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(TO_DATE(:from_date, 'YYYY-MM-DD')+ interval '1 day',
            'YYYY-MM-DD'), c.id ) AS bigint)    AS longdate,
            TO_DATE((:from_date), 'YYYY-MM-DD') AS prev_day,
            c.id                                AS centerid
        FROM
            centers c
    )
SELECT DISTINCT
    TO_CHAR(t2.rundate, 'DD-MM-YYYY') AS DATE,
    t2.center ||'p'|| t2.id           AS memberid,
    t2.external_id,
    t2.fullname,
    t2.persontype,
    t2.person_status,
    t2.subscription_name,
    t2.subscription_price,
    t2.start_date,
    t2.end_date,
    CASE
            /*WHEN (t2.type = 'New Sale'
            AND t2.old_sub_end < t2.start_date - interval '3 day')
            THEN 'New Joiner'*/
        WHEN (t2.type = 'New Sale'
            AND t2.old_sub_end IS NULL)
        THEN 'New Joiner'
        WHEN (t2.type = 'New Sale'
            AND t2.old_sub_end IS NOT NULL)
        THEN 'Migrator'
    END AS JOIN_TYPE,
    /*CASE
    WHEN (t2.type = 'New Sale'
    AND t2.old_sub_end >= t2.start_date - interval '3 day')
    THEN t2.old_sub_name
    ELSE NULL
    END*/
    t2.old_sub_name AS old_sub_name,
    /*CASE
    WHEN (t2.type = 'New Sale'
    AND t2.old_sub_end >= t2.start_date - interval '3 day')
    THEN t2.old_sub_price
    ELSE NULL
    END */
    t2.old_sub_price AS old_sub_price,
    t2.promocode,
    t2.company,
    t2.company_id,
    t2.company_agreement
    --t2.sqlgroup
FROM
    (
        SELECT DISTINCT
            t1.*,
            old_sub.end_date AS old_sub_end,
            old_sp.price     AS old_sub_price,
            old_pr.name      AS old_sub_name,
            prod.name        AS subscription_name,
            sp.price         AS subscription_price
        FROM
            (
                SELECT DISTINCT
                    params.prev_day AS rundate,
                    p.center,
                    p.id,
                    p_curr.external_id,
                    p.fullname,
                    CASE p_curr.PERSONTYPE
                        WHEN 0
                        THEN 'PRIVATE'
                        WHEN 1
                        THEN 'STUDENT'
                        WHEN 2
                        THEN 'STAFF'
                        WHEN 3
                        THEN 'FRIEND'
                        WHEN 4
                        THEN 'CORPORATE'
                        WHEN 5
                        THEN 'ONEMANCORPORATE'
                        WHEN 6
                        THEN 'FAMILY'
                        WHEN 7
                        THEN 'SENIOR'
                        WHEN 8
                        THEN 'GUEST'
                        WHEN 9
                        THEN 'CHILD'
                        WHEN 10
                        THEN 'EXTERNAL_STAFF'
                        ELSE 'Undefined'
                    END AS PERSONTYPE,
                    CASE p_curr.STATUS
                        WHEN 0
                        THEN 'LEAD'
                        WHEN 1
                        THEN 'ACTIVE'
                        WHEN 2
                        THEN 'INACTIVE'
                        WHEN 3
                        THEN 'TEMPORARYINACTIVE'
                        WHEN 4
                        THEN 'TRANSFERRED'
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
                        ELSE 'Undefined'
                    END                       AS PERSON_STATUS,
                    s.center                  AS sub_center,
                    s.id                      AS sub_id,
                    s.subscriptiontype_center AS sub_type_center,
                    s.subscriptiontype_id     AS sub_type_id,
                    s.start_date,
                    s.end_date,
                    CASE
                        WHEN s.start_date = params.prev_day
                        THEN 'New Sale'
                        WHEN s.end_date = params.prev_day
                        THEN 'Leaver'
                        ELSE 'Existing'
                    END                         AS Type,
                    NULL                        AS promocode,
                    comp.fullname               AS company,
                    comp.center ||'p'|| comp.id AS company_id,
                    cag.name                    AS company_agreement
                    --1 AS SQLGROUP
                FROM
                    persons p
                JOIN
                    params
                ON
                    params.centerid = p.center
                JOIN
                    state_change_log scl
                ON
                    scl.center = p.center
                AND scl.id = p.id
                AND scl.entry_type = 3
                AND scl.stateid = 4
                JOIN
                    subscriptions s
                ON
                    s.owner_center = p.center
                AND s.owner_id = p.id
                AND (
                        s.end_date >= params.prev_day
                    OR  s.end_date IS NULL)
                AND s.start_date <= params.prev_day
                JOIN
                    persons p_curr
                ON
                    p_curr.center = p.current_person_center
                AND p_curr.id = p.current_person_id
                JOIN
                    relatives ca
                ON
                    ca.center = p.center
                AND ca.id = p.id
                AND ca.rtype = 3
                AND ca.status < 3
                JOIN
                    companyagreements cag
                ON
                    cag.center = ca.relativecenter
                AND cag.id = ca.relativeid
                AND cag.subid = ca.relativesubid
                JOIN
                    persons comp
                ON
                    comp.center = cag.center
                AND comp.id = cag.id
                WHERE
                    (
                        scl.entry_end_time IS NULL
                    OR  scl.entry_end_time > params.longdate)
                AND p.status NOT IN (5,7,8)
                AND p.center IN (:scope)
                UNION ALL
                SELECT DISTINCT
                    params.prev_day AS rundate,
                    p.center,
                    p.id,
                    p_curr.external_id,
                    p.fullname,
                    CASE p_curr.PERSONTYPE
                        WHEN 0
                        THEN 'PRIVATE'
                        WHEN 1
                        THEN 'STUDENT'
                        WHEN 2
                        THEN 'STAFF'
                        WHEN 3
                        THEN 'FRIEND'
                        WHEN 4
                        THEN 'CORPORATE'
                        WHEN 5
                        THEN 'ONEMANCORPORATE'
                        WHEN 6
                        THEN 'FAMILY'
                        WHEN 7
                        THEN 'SENIOR'
                        WHEN 8
                        THEN 'GUEST'
                        WHEN 9
                        THEN 'CHILD'
                        WHEN 10
                        THEN 'EXTERNAL_STAFF'
                        ELSE 'Undefined'
                    END AS PERSONTYPE,
                    CASE p_curr.STATUS
                        WHEN 0
                        THEN 'LEAD'
                        WHEN 1
                        THEN 'ACTIVE'
                        WHEN 2
                        THEN 'INACTIVE'
                        WHEN 3
                        THEN 'TEMPORARYINACTIVE'
                        WHEN 4
                        THEN 'TRANSFERRED'
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
                        ELSE 'Undefined'
                    END                       AS PERSON_STATUS,
                    s.center                  AS sub_center,
                    s.id                      AS sub_id,
                    s.subscriptiontype_center AS sub_type_center,
                    s.subscriptiontype_id     AS sub_type_id,
                    s.start_date,
                    s.end_date,
                    CASE
                        WHEN s.start_date = params.prev_day
                        THEN 'New Sale'
                        WHEN s.end_date = params.prev_day
                        THEN 'Leaver'
                        ELSE 'Existing'
                    END      AS Type,
                    cc.code  AS promocode,
                    NULL     AS company,
                    NULL     AS company_id,
                    prg.name AS company_agreement
                    --2 AS SQLGROUP
                FROM
                    fw.privilege_receiver_groups prg
                JOIN
                    fw.privilege_grants pg
                ON
                    pg.granter_id = prg.id
                AND pg.granter_service = 'ReceiverGroup'
                JOIN
                    fw.privilege_usages pu
                ON
                    pu.grant_id = pg.id
                AND pu.target_service = 'SubscriptionPrice'
                JOIN
                    persons p
                ON
                    p.center = pu.person_center
                AND p.id = pu.person_id
                JOIN
                    params
                ON
                    params.centerid = p.center
                JOIN
                    fw.subscription_price sp_sub
                ON
                    sp_sub.id = pu.target_id
                JOIN
                    subscriptions s
                ON
                    s.center = sp_sub.subscription_center
                AND s.id = sp_sub.subscription_id
                AND (
                        s.end_date >= params.prev_day
                    OR  s.end_date IS NULL)
                AND s.start_date <= params.prev_day
                JOIN
                    persons p_curr
                ON
                    p_curr.center = p.current_person_center
                AND p_curr.id = p.current_person_id
                LEFT JOIN
                    campaign_codes cc
                ON
                    cc.id = pu.campaign_code_id
                WHERE
                    prg.name LIKE 'Firma%'
                AND prg.plugin_codes_name != 'NO_CODES'
                AND prg.rgtype = 'UNLIMITED'
                AND pu.cancel_time IS NULL
                AND p.center IN (:scope)
                UNION ALL
                SELECT DISTINCT
                    params.prev_day AS rundate,
                    p.center,
                    p.id,
                    p_curr.external_id,
                    p.fullname,
                    CASE p_curr.PERSONTYPE
                        WHEN 0
                        THEN 'PRIVATE'
                        WHEN 1
                        THEN 'STUDENT'
                        WHEN 2
                        THEN 'STAFF'
                        WHEN 3
                        THEN 'FRIEND'
                        WHEN 4
                        THEN 'CORPORATE'
                        WHEN 5
                        THEN 'ONEMANCORPORATE'
                        WHEN 6
                        THEN 'FAMILY'
                        WHEN 7
                        THEN 'SENIOR'
                        WHEN 8
                        THEN 'GUEST'
                        WHEN 9
                        THEN 'CHILD'
                        WHEN 10
                        THEN 'EXTERNAL_STAFF'
                        ELSE 'Undefined'
                    END AS PERSONTYPE,
                    CASE p_curr.STATUS
                        WHEN 0
                        THEN 'LEAD'
                        WHEN 1
                        THEN 'ACTIVE'
                        WHEN 2
                        THEN 'INACTIVE'
                        WHEN 3
                        THEN 'TEMPORARYINACTIVE'
                        WHEN 4
                        THEN 'TRANSFERRED'
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
                        ELSE 'Undefined'
                    END                       AS PERSON_STATUS,
                    s.center                  AS sub_center,
                    s.id                      AS sub_id,
                    s.subscriptiontype_center AS sub_type_center,
                    s.subscriptiontype_id     AS sub_type_id,
                    s.start_date,
                    s.end_date,
                    CASE
                        WHEN s.start_date = params.prev_day
                        THEN 'New Sale'
                        WHEN s.end_date = params.prev_day
                        THEN 'Leaver'
                        ELSE 'Existing'
                    END      AS Type,
                    cc.code  AS promocode,
                    NULL     AS company,
                    NULL     AS company_id,
                    prg.name AS company_agreement
                    --3 AS SQLGROUP
                FROM
                    privilege_usages pu
                JOIN
                    privilege_grants pg
                ON
                    pg.id = pu.grant_id
                AND pg.granter_service = 'ReceiverGroup'
                AND pu.target_service = 'InvoiceLine'
                AND pu.cancel_time IS NULL
                JOIN
                    privilege_receiver_groups prg
                ON
                    prg.id = pg.granter_id
                AND prg.name LIKE 'Firma%'
                AND prg.plugin_codes_name != 'NO_CODES'
                AND prg.rgtype = 'UNLIMITED'
                JOIN
                    invoice_lines_mt invl
                ON
                    pu.target_center = invl.center
                AND pu.target_id = invl.id
                AND pu.target_subid = invl.subid
                JOIN
                    spp_invoicelines_link invll
                ON
                    invll.invoiceline_center = invl.center
                AND invll.invoiceline_id = invl.id
                AND invll.invoiceline_subid = invl.subid
                JOIN
                    subscriptionperiodparts spp
                ON
                    spp.center = invll.period_center
                AND spp.id = invll.period_id
                AND spp.subid = invll.period_subid
                JOIN
                    params
                ON
                    params.centerid = spp.center
                JOIN
                    subscriptions s
                ON
                    s.center = spp.center
                AND s.id = spp.id
                AND (
                        s.end_date >= params.prev_day
                    OR  s.end_date IS NULL)
                AND s.start_date <= params.prev_day
                JOIN
                    persons p
                ON
                    p.center = s.owner_center
                AND p.id = s.owner_id
                JOIN
                    persons p_curr
                ON
                    p_curr.center = p.current_person_center
                AND p_curr.id = p.current_person_id
                LEFT JOIN
                    campaign_codes cc
                ON
                    cc.id = pu.campaign_code_id
                WHERE
                    p.center IN (:scope)
                UNION ALL
                SELECT DISTINCT
                    params.prev_day AS rundate,
                    p.center,
                    p.id,
                    p_curr.external_id,
                    p.fullname,
                    CASE p_curr.PERSONTYPE
                        WHEN 0
                        THEN 'PRIVATE'
                        WHEN 1
                        THEN 'STUDENT'
                        WHEN 2
                        THEN 'STAFF'
                        WHEN 3
                        THEN 'FRIEND'
                        WHEN 4
                        THEN 'CORPORATE'
                        WHEN 5
                        THEN 'ONEMANCORPORATE'
                        WHEN 6
                        THEN 'FAMILY'
                        WHEN 7
                        THEN 'SENIOR'
                        WHEN 8
                        THEN 'GUEST'
                        WHEN 9
                        THEN 'CHILD'
                        WHEN 10
                        THEN 'EXTERNAL_STAFF'
                        ELSE 'Undefined'
                    END AS PERSONTYPE,
                    CASE p_curr.STATUS
                        WHEN 0
                        THEN 'LEAD'
                        WHEN 1
                        THEN 'ACTIVE'
                        WHEN 2
                        THEN 'INACTIVE'
                        WHEN 3
                        THEN 'TEMPORARYINACTIVE'
                        WHEN 4
                        THEN 'TRANSFERRED'
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
                        ELSE 'Undefined'
                    END                       AS PERSON_STATUS,
                    s.center                  AS sub_center,
                    s.id                      AS sub_id,
                    s.subscriptiontype_center AS sub_type_center,
                    s.subscriptiontype_id     AS sub_type_id,
                    s.start_date,
                    s.end_date,
                    CASE
                        WHEN s.start_date = params.prev_day
                        THEN 'New Sale'
                        WHEN s.end_date = params.prev_day
                        THEN 'Leaver'
                        ELSE 'Existing'
                    END      AS Type,
                    cc.code  AS promocode,
                    NULL     AS company,
                    NULL     AS company_id,
                    prg.name AS company_agreement
                    --4 AS SQLGROUP
                FROM
                    fw.privilege_receiver_groups prg
                JOIN
                    fw.privilege_grants pg
                ON
                    pg.granter_id = prg.id
                AND pg.granter_service = 'ReceiverGroup'
                JOIN
                    fw.privilege_usages pu
                ON
                    pu.grant_id = pg.id
                AND pu.target_service = 'SubscriptionPrice'
                JOIN
                    persons p
                ON
                    p.center = pu.person_center
                AND p.id = pu.person_id
                JOIN
                    params
                ON
                    params.centerid = p.center
                JOIN
                    fw.subscription_price sp_sub
                ON
                    sp_sub.id = pu.target_id
                JOIN
                    subscriptions s
                ON
                    s.center = sp_sub.subscription_center
                AND s.id = sp_sub.subscription_id
                AND (
                        s.end_date >= params.prev_day
                    OR  s.end_date IS NULL)
                AND s.start_date <= params.prev_day
                JOIN
                    persons p_curr
                ON
                    p_curr.center = p.current_person_center
                AND p_curr.id = p.current_person_id
                LEFT JOIN
                    campaign_codes cc
                ON
                    cc.id = pu.campaign_code_id
                WHERE
                    prg.name = 'Ældresagen'
                AND prg.plugin_codes_name != 'NO_CODES'
                AND prg.rgtype = 'UNLIMITED'
                AND pu.cancel_time IS NULL
                AND p.center IN (:scope)
                UNION ALL
                SELECT DISTINCT
                    params.prev_day AS rundate,
                    p.center,
                    p.id,
                    p_curr.external_id,
                    p.fullname,
                    CASE p_curr.PERSONTYPE
                        WHEN 0
                        THEN 'PRIVATE'
                        WHEN 1
                        THEN 'STUDENT'
                        WHEN 2
                        THEN 'STAFF'
                        WHEN 3
                        THEN 'FRIEND'
                        WHEN 4
                        THEN 'CORPORATE'
                        WHEN 5
                        THEN 'ONEMANCORPORATE'
                        WHEN 6
                        THEN 'FAMILY'
                        WHEN 7
                        THEN 'SENIOR'
                        WHEN 8
                        THEN 'GUEST'
                        WHEN 9
                        THEN 'CHILD'
                        WHEN 10
                        THEN 'EXTERNAL_STAFF'
                        ELSE 'Undefined'
                    END AS PERSONTYPE,
                    CASE p_curr.STATUS
                        WHEN 0
                        THEN 'LEAD'
                        WHEN 1
                        THEN 'ACTIVE'
                        WHEN 2
                        THEN 'INACTIVE'
                        WHEN 3
                        THEN 'TEMPORARYINACTIVE'
                        WHEN 4
                        THEN 'TRANSFERRED'
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
                        ELSE 'Undefined'
                    END                       AS PERSON_STATUS,
                    s.center                  AS sub_center,
                    s.id                      AS sub_id,
                    s.subscriptiontype_center AS sub_type_center,
                    s.subscriptiontype_id     AS sub_type_id,
                    s.start_date,
                    s.end_date,
                    CASE
                        WHEN s.start_date = params.prev_day
                        THEN 'New Sale'
                        WHEN s.end_date = params.prev_day
                        THEN 'Leaver'
                        ELSE 'Existing'
                    END      AS Type,
                    cc.code  AS promocode,
                    NULL     AS company,
                    NULL     AS company_id,
                    prg.name AS company_agreement
                    --5 AS SQLGROUP
                FROM
                    privilege_usages pu
                JOIN
                    privilege_grants pg
                ON
                    pg.id = pu.grant_id
                AND pg.granter_service = 'ReceiverGroup'
                AND pu.target_service = 'InvoiceLine'
                AND pu.cancel_time IS NULL
                JOIN
                    privilege_receiver_groups prg
                ON
                    prg.id = pg.granter_id
                AND prg.name = 'Ældresagen'
                AND prg.plugin_codes_name != 'NO_CODES'
                AND prg.rgtype = 'UNLIMITED'
                JOIN
                    invoice_lines_mt invl
                ON
                    pu.target_center = invl.center
                AND pu.target_id = invl.id
                AND pu.target_subid = invl.subid
                JOIN
                    spp_invoicelines_link invll
                ON
                    invll.invoiceline_center = invl.center
                AND invll.invoiceline_id = invl.id
                AND invll.invoiceline_subid = invl.subid
                JOIN
                    subscriptionperiodparts spp
                ON
                    spp.center = invll.period_center
                AND spp.id = invll.period_id
                AND spp.subid = invll.period_subid
                JOIN
                    params
                ON
                    params.centerid = spp.center
                JOIN
                    subscriptions s
                ON
                    s.center = spp.center
                AND s.id = spp.id
                AND (
                        s.end_date >= params.prev_day
                    OR  s.end_date IS NULL)
                AND s.start_date <= params.prev_day
                JOIN
                    persons p
                ON
                    p.center = s.owner_center
                AND p.id = s.owner_id
                JOIN
                    persons p_curr
                ON
                    p_curr.center = p.current_person_center
                AND p_curr.id = p.current_person_id
                LEFT JOIN
                    campaign_codes cc
                ON
                    cc.id = pu.campaign_code_id
                WHERE
                    p.center IN (:scope) ) t1
        JOIN
            params
        ON
            params.centerid = t1.sub_center
        JOIN
            subscription_price sp
        ON
            sp.subscription_center = t1.sub_center
        AND sp.subscription_id = t1.sub_id
        AND sp.from_date <= params.prev_day
        AND (
                sp.to_date >= params.prev_day
            OR  sp.to_date IS NULL)
        AND sp.cancelled = 'false'
        JOIN
            subscriptiontypes st
        ON
            st.center = t1.sub_type_center
        AND st.id = t1.sub_type_id
        JOIN
            products prod
        ON
            prod.center = st.center
        AND prod.id = st.id
        LEFT JOIN
            subscriptions old_sub
        ON
            old_sub.owner_center = t1.center
        AND old_sub.owner_id = t1.id
        AND old_sub.end_date < params.prev_day
        AND old_sub.end_date > old_sub.start_date
        AND t1.type = 'New Sale'
        AND old_sub.end_date >= t1.start_date - interval '3 day'
        LEFT JOIN
            subscription_price old_sp
        ON
            old_sp.subscription_center = old_sub.center
        AND old_sp.subscription_id = old_sub.id
        AND old_sp.to_date IS NULL
        LEFT JOIN
            fw.subscriptiontypes old_st
        ON
            old_st.center = old_sub.subscriptiontype_center
        AND old_st.id = old_sub.subscriptiontype_id
        LEFT JOIN
            products old_pr
        ON
            old_pr.center = old_st.center
        AND old_pr.id = old_st.id
        GROUP BY
            t1.rundate,
            t1.center,
            t1.id,
            t1.external_id,
            t1.fullname,
            t1.persontype,
            t1.person_status,
            t1.sub_center,
            t1.sub_id,
            t1.sub_type_center,
            t1.sub_type_id,
            prod.name,
            sp.price,
            t1.start_date,
            t1.end_date,
            t1.type,
            old_pr.name,
            old_sp.price,
            old_sub_end,
            t1.promocode,
            t1.company,
            t1.company_id,
            t1.company_agreement
            --t1.sqlgroup
    ) t2