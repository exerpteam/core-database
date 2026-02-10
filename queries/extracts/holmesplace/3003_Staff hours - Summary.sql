-- The extract is extracted from Exerp on 2026-02-08
--  


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
SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD')                       b_date,
    TO_CHAR(longtodate(bk.STOPTIME), 'MON')                               b_month,
    TO_CHAR(longtodate(bk.STOPTIME), 'DY')                                b_day,
    TO_CHAR(longtodate(bk.STARTTIME), 'HH24:MI')                          startTime,
    TO_CHAR(longtodate(bk.STOPTIME), 'HH24:MI')                           endTime,
    extract(HOUR FROM(longtodate(bk.STOPTIME)- longtodate(bk.STARTTIME)))   hours,
    extract(MINUTE FROM(longtodate(bk.STOPTIME)- longtodate(bk.STARTTIME))) minutes,
    ROUND((bk.STOPTIME - bk.STARTTIME)/(1000*60*60),2) timeTotal,
    psg.SALARY                                                          staffSalary,
    CASE
        WHEN psg.SALARY IS NOT NULL
        THEN ROUND((bk.STOPTIME - bk.STARTTIME)/(1000*60*60),2)*psg.SALARY
        ELSE NULL
    END        wages,
    bk.NAME    activityname,
    actgr.NAME activitygroup,
    stfg.NAME  staffgroup,
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
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            THEN 1
            ELSE 0
        END ) participants,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'BOOKED'
            THEN 1
            ELSE 0
        END) booked,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'PARTICIPATION'
            THEN 1
            ELSE 0
        END) showup,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'CANCELLED'
            THEN 1
            ELSE 0
        END) cancelled_Total,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'CANCELLED'
            AND par.CANCELATION_REASON = 'CENTER'
            THEN 1
            ELSE 0
        END) cancel_center,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'CANCELLED'
            AND par.CANCELATION_REASON = 'USER'
            THEN 1
            ELSE 0
        END) cancel_user,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'CANCELLED'
            AND par.CANCELATION_REASON = 'NO_SHOW'
            THEN 1
            ELSE 0
        END) cancel_noshow,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'CANCELLED'
            AND par.CANCELATION_REASON = 'NO_SEAT'
            THEN 1
            ELSE 0
        END) cancel_noseat,
    SUM(
        CASE
            WHEN par.center IS NOT NULL
            AND par.state = 'CANCELLED'
            AND par.CANCELATION_REASON = 'BOOKING'
            THEN 1
            ELSE 0
        END) cancel_booking
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
GROUP BY
    bk.center,
    bk.STARTTIME,
    bk.STOPTIME,
    psg.SALARY,
    bk.NAME,
    actgr.NAME,
    stfg.NAME,
    ins.CENTER ,
    ins.ID,
    ins.FIRSTNAME,
    ins.LASTNAME,
    bk.STATE
ORDER BY
    bk.STARTTIME