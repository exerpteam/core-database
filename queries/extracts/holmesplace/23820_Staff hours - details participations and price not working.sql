

WITH
    RECURSIVE
    /* Get all relevant bookings */
    v_init_bookings AS
    (
        SELECT
            bk.center,
            bk.id,
            bk.activity,
            bk.starttime,
            bk.stoptime,
            bk.name,
            bk.state
        FROM
            BOOKINGS bk
        WHERE
            bk.center IN ($$Scope$$)
        AND bk.STARTTIME >= $$FromDate$$
        AND bk.STARTTIME < $$ToDate$$ + (1000*60*60*24)
    )
    /* Get activity hieracrhy - with root values and hierarchy levels for each activity */
    ,
    v_activity AS
    (
        SELECT
            act.id,
            act.activity_group_id,
            act.scope_type,
            act.name,
            act.external_id,
            act.scope_id,
            act.id                act_root_id,
            act.activity_group_id act_root_group_id,
            1                     act_node_level
        FROM
            ACTIVITY act
        WHERE
            act.top_node_id IS NULL
        UNION ALL
        SELECT
            act.id,
            act.activity_group_id,
            act.scope_type,
            act.name,
            act.external_id,
            act.scope_id,
            vact.act_root_id,
            vact.act_root_group_id,
            vact.act_node_level +1 act_node_level
        FROM
            ACTIVITY act
        JOIN
            v_activity vact
        ON
            vact.id = act.top_node_id
    )
    /* For each booking, find all activities that exist as top node level or as an area override.
    Then for each activity, find areas at any level that come udner the activities scope *
    Give the activity with no more area branches in its scope the highest rank */
    ,
    v_bk_act_area_override AS
    (
        SELECT
            act.external_id,
            bk.*,
            act.id                                             AS act_override_id,
            act.act_root_id                                    AS act_root_id,
            COALESCE(act.activity_group_id, act_root_group_id)    activity_group_id,
            a.id                                                  area_id ,
            act.act_node_level
        FROM
            v_init_bookings bk ,
            v_activity act,
            areas a
        WHERE
            act.act_root_id = bk.activity
        AND COALESCE(act.scope_type, 'Z') IN ('A',
                                              'G',
                                              'T')
        AND a.id = act.scope_id
        UNION ALL
        SELECT
            v.external_id,
            bk.*,
            act.id act_override_id,
            v.act_root_id ,
            COALESCE(act.activity_group_id, act_root_group_id)    activity_group_id,
            a.id                                                  area_id ,
            v.act_node_level                                   AS act_node_level
        FROM
            v_init_bookings bk ,
            v_activity act,
            areas a,
            v_bk_act_area_override v
        WHERE
            act.act_root_id = bk.activity
        AND COALESCE(act.scope_type, 'Z') IN ('A',
                                              'G',
                                              'T')
        AND v.area_id = a.parent
        AND v.act_override_id = act.id
        AND v.center = bk.center
        AND v.id = bk.id
    )
    /*     Find the activity with no more area branches for the booking center
    */
    ,
    v_bk_act_area_override_rank AS
    (
        SELECT
            *,
            rank() over (partition BY act_root_id, area_id ORDER BY act_node_level DESC) AS
            act_area_finallevel
        FROM
            v_bk_act_area_override
    )
    ,
    v_bk_act_area_centers_override AS
    (
        SELECT
            baao.*,
            ac.center center_id
        FROM
            v_bk_act_area_override_rank baao
        JOIN
            area_centers ac
        ON
            baao.area_id = ac.area
        AND ac.center = baao.center
        WHERE
            baao.act_area_finallevel = 1
    )
    /*Find activity overrides made at center level*/
    ,
    v_bk_act_center_override AS
    (
        SELECT
            act.external_id,
            bk.*,
            act.id                                             act_override_id,
            act.id                                             act_root_id,
            COALESCE(act.activity_group_id, act_root_group_id) activity_group_id,
            CAST(NULL AS INTEGER)                              area_id,
            CAST(NULL AS INTEGER)                              act_node_level,
            0                                                  act_area_finallevel,
            act.scope_id                                       center_id
        FROM
            v_init_bookings bk,
            v_activity act
        WHERE
            act.act_root_id = bk.activity
        AND COALESCE(act.scope_type, 'Z') = 'C'
        AND bk.center = act.scope_id
    )
    /*USE activity WITH center level override IF available ELSE most relevant area level override
    FOR
    the booking center*/
    ,
    v_bookings AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    bk1.*,
                    rank() over (partition BY bk1.center, bk1.id, bk1.activity, bk1.center_id
                    ORDER BY bk1.act_area_finallevel ASC) act_center_finallevel
                FROM
                    (
                        SELECT
                            *
                        FROM
                            v_bk_act_area_centers_override
                        UNION
                        SELECT
                            *
                        FROM
                            v_bk_act_center_override ) bk1 ) bk
        WHERE
            bk.act_center_finallevel = 1
    )
SELECT DISTINCT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') b_date,
    TO_CHAR(longtodate(bk.STOPTIME), 'MON')         b_month,
    TO_CHAR(longtodate(bk.STOPTIME), 'DY')          b_day,
    TO_CHAR(longtodate(bk.STARTTIME), 'HH24:MI')    startTime,
    TO_CHAR(longtodate(bk.STOPTIME), 'HH24:MI')     endTime,
    bk.NAME                                         activityname,
    actgr.NAME                                      activitygroup,
    stfg.NAME                                       staffgroup,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.CENTER || 'p' || ins.ID
    END instructorId,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END      instructorName,
    bk.STATE bookingState,
    CASE
        WHEN par.CENTER IS NOT NULL
        THEN par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID
        ELSE NULL
    END participantId,
    CASE
        WHEN par.CENTER IS NOT NULL
        THEN per.FIRSTNAME || ' ' || per.LASTNAME
        ELSE NULL
    END       participantName,
    par.STATE participationState,
    par.CANCELATION_REASON,
    psg.SALARY staffSalary,
    CASE
        WHEN psg.SALARY IS NOT NULL
        THEN ROUND((bk.STOPTIME - bk.STARTTIME)/(1000*60*60),2)*psg.SALARY
        ELSE NULL
    END wages,
    CASE
        WHEN bk.external_id = 'undefined'
        THEN NULL
        ELSE bk.external_id
    END     external_id,
    pc.Name AS "PT Product",
    CASE
        WHEN s.SUBSCRIPTION_PRICE IS NULL
        THEN ROUND(il.NET_AMOUNT / t1.invtotal, 2)
        ELSE
            CASE
                WHEN il.NET_AMOUNT <> 0
                THEN ROUND(il.NET_AMOUNT / t1.invtotal, 2)
                ELSE ROUND(s.SUBSCRIPTION_PRICE / (1+prvat.rate),2)
            END
    END AS "PT Product Price excl VAT",
    cc.CLIPS_INITIAL "PT product clips amount",
    longtodateC(inv.TRANS_TIME, inv.CENTER) "PT product sales date",
    il.net_amount AS "Total Amount Net.",
    CASE
        WHEN cc.center IS NOT NULL
        THEN cc.center||'cc'||cc.id||'cc'||cc.subid
        ELSE NULL
    END AS "Clipcard ID",
    CASE
        WHEN s1.id IS NOT NULL
        THEN pdrc.name
        ELSE NULL
    END AS "SubscriptionName",
    CASE
        WHEN s1.start_date IS NOT NULL
        THEN s1.start_date
        ELSE NULL
    END AS "Subscription Start Date"
FROM
    v_bookings bk
JOIN
    ACTIVITY_GROUP actgr
ON
    bk.ACTIVITY_GROUP_ID = actgr.ID
LEFT JOIN
    HP.ACTIVITY_STAFF_CONFIGURATIONS staffconfig
ON
    staffconfig.ACTIVITY_ID = bk.act_override_id -- uses bottom node if available else top node
LEFT JOIN
    HP.STAFF_GROUPS stfg
ON
    stfg.ID = staffconfig.STAFF_GROUP_ID
LEFT JOIN
    PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
AND par.BOOKING_ID = bk.ID
LEFT JOIN
    STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
AND bk.id = st.BOOKING_ID
AND st.state = 'ACTIVE'
LEFT JOIN
    PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
AND st.PERSON_ID = ins.ID
LEFT JOIN
    PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
AND par.PARTICIPANT_ID = per.ID
LEFT JOIN
    PERSON_STAFF_GROUPS psg
ON
    psg.PERSON_CENTER = ins.CENTER
AND psg.PERSON_ID = ins.ID
AND psg.STAFF_GROUP_ID = stfg.ID
AND COALESCE(psg.SALARY, 0) <> 0
AND psg.SCOPE_TYPE = 'C'
AND psg.SCOPE_ID = bk.center
LEFT JOIN
    PRIVILEGE_USAGES pu
ON
    pu.PERSON_CENTER = per.CENTER
AND pu.PERSON_ID = per.ID
AND pu.PRIVILEGE_TYPE = 'BOOKING'
AND pu.TARGET_SERVICE = 'Participation'
AND pu.TARGET_CENTER = par.CENTER
AND pu.TARGET_ID = par.ID
LEFT JOIN
    CLIPCARDS cc
ON
    pu.SOURCE_CENTER = cc.CENTER
AND pu.SOURCE_ID = cc.ID
AND pu.SOURCE_SUBID = cc.SUBID
LEFT JOIN
    PRODUCTS pc
ON
    pc.CENTER = cc.CENTER
AND pc.ID = cc.ID
LEFT JOIN
    INVOICE_LINES_MT il
ON
    IL.CENTER = cc.INVOICELINE_CENTER
AND IL.ID = cc.INVOICELINE_ID
AND IL.SUBID = cc.INVOICELINE_SUBID
LEFT JOIN
    (
        SELECT
            il.CENTER,
            il.ID,
            COUNT(*) AS invtotal
        FROM
            CLIPCARDS cc
        JOIN
            INVOICE_LINES_MT il
        ON
            cc.INVOICELINE_CENTER = il.CENTER
        AND cc.INVOICELINE_ID = il.ID
        AND cc.INVOICELINE_SUBID = il.SUBID
        GROUP BY
            il.CENTER,
            il.ID ) t1
ON
    t1.CENTER = il.CENTER
AND t1.ID = il.ID
LEFT JOIN
    INVOICES inv
ON
    il.CENTER = inv.CENTER
AND il.ID = inv.ID
LEFT JOIN
    PRIVILEGE_USAGES pu2
ON
    pu2.PERSON_CENTER = per.CENTER
AND pu2.PERSON_ID = per.ID
AND pu2.PRIVILEGE_TYPE = 'PRODUCT'
AND pu2.target_center = IL.CENTER
AND pu2.target_id = IL.ID
AND pu2.target_subid = IL.SUBID
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.id = pu2.GRANT_ID
AND pg.granter_service = 'GlobalSubscription'
LEFT JOIN
    SUBSCRIPTIONS s
ON
    pu2.SOURCE_CENTER = s.CENTER
AND pu2.SOURCE_ID = s.ID
LEFT JOIN
    spp_invoicelines_link link
ON
    link.invoiceline_center = il.CENTER
    AND link.invoiceline_id = il.ID
    AND link.invoiceline_subid = il.subid
LEFT JOIN
    subscriptionperiodparts spp
ON
    link.period_center = spp.center
    AND link.period_id = spp.id
    AND link.period_subid = spp.subid
LEFT JOIN
    subscriptions s1
ON
    spp.center = s1.center
    AND spp.id = s1.id
LEFT JOIN
    subscriptiontypes sts
ON
    sts.center = s1.subscriptiontype_center
    AND sts.id = s1.subscriptiontype_id
    AND sts.st_type = 2
LEFT JOIN
    products pdrc
ON
    pdrc.center = sts.center
    AND pdrc.id = sts.id
LEFT JOIN
    (
        SELECT
            pr.CENTER,
            pr.ID,
            vt.rate,
            pr.NAME
        FROM
            PRODUCTS pr
        JOIN
            PRODUCT_ACCOUNT_CONFIGURATIONS pag
        ON
            pr.PRODUCT_ACCOUNT_CONFIG_ID = pag.ID
            --AND pr.blocked = 0
            --AND pag.blocked = 0
        JOIN
            ACCOUNTS acc
        ON
            acc.GLOBALID = pag.SALES_ACCOUNT_GLOBALID
        AND acc.CENTER = pr.CENTER
            --AND acc.blocked = 0
        JOIN
            ACCOUNT_VAT_TYPE_GROUP avtg
        ON
            avtg.account_center = acc.center
        AND avtg.account_id = acc.id
        JOIN
            VAT_TYPES vt
        ON
            vt.GLOBALID = avtg.GLOBAL_ID
        AND vt.CENTER = pr.CENTER ) prvat
ON
    prvat.center = s.SUBSCRIPTIONTYPE_CENTER
AND prvat.id = s.SUBSCRIPTIONTYPE_ID