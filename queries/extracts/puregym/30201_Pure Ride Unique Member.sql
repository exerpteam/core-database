WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                      AS FromDate,
            ($$EndDate$$ + 86400 * 1000) - 1 AS ToDate
        FROM
            dual
    )
    ,
    unique_person AS
    (
        SELECT
            COUNT(DISTINCT p.center || 'p' || p.id) AS "Unique members"
        FROM
            PERSONS P
        CROSS JOIN
            params
        WHERE
            EXISTS
            (
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG scl
                WHERE
                    params.FromDate <= NVL(scl.entry_end_time, params.FromDate)
                    AND params.ToDate >= scl.ENTRY_START_TIME
                    AND scl.ENTRY_TYPE = 1)
            AND P.persontype != 2
            AND p.center IN ($$scope$$)
    )
    ,
    unique_class_paid AS
    (
        SELECT
            COUNT(DISTINCT person_id) AS "Class taken",
            SUM(paid_flag)            AS "Class paid"
        FROM
            (
                SELECT DISTINCT
                    pa.participant_center || 'p' || pa.participant_id person_id,
                    DECODE(NVL(act.amount, 0), 0, 0, 1)               paid_flag
                FROM
                    BOOKINGS bo
                CROSS JOIN
                    params
                JOIN
                    ACTIVITY ac
                ON
                    ac.ID = bo.ACTIVITY
                JOIN
                    colour_groups cg
                ON
                    cg.id = ac.colour_group_id
                JOIN
                    PARTICIPATIONS pa
                ON
                    pa.booking_center = bo.center
                    AND pa.booking_id = bo.id
                    AND pa.state = 'PARTICIPATION'
                JOIN
                    privilege_usages pu
                ON
                    pu.target_service = 'Participation'
                    AND pu.target_center = pa.center
                    AND pu.target_id = pa.id
                LEFT JOIN
                    privilege_grants pg
                ON
                    pg.id = pu.grant_id
                    AND pg.granter_service = 'GlobalCard'
                LEFT JOIN
                    card_clip_usages ccu
                ON
                    ccu.id = pu.deduction_key
                LEFT JOIN
                    clipcards cc
                ON
                    cc.center = ccu.card_center
                    AND cc.id = ccu.card_id
                    AND cc.subid = ccu.card_subid
                LEFT JOIN
                    invoicelines il
                ON
                    il.center = cc.invoiceline_center
                    AND il.id = cc.invoiceline_id
                    AND il.subid = cc.invoiceline_subid
                LEFT JOIN
                    account_trans act
                ON
                    act.center = il.account_trans_center
                    AND act.id = il.account_trans_id
                    AND act.subid = il.account_trans_subid
                WHERE
                    bo.STATE='ACTIVE'
                    AND bo.center IN ($$scope$$)
                    AND bo.STARTTIME>= params.FromDate
                    AND bo.STARTTIME<= params.ToDate
                    AND cg.name IN ('Performance',
                                    'Signature') )
    )
SELECT
    unique_person.*,
    unique_class_paid.*
FROM
    unique_person
CROSS JOIN
    unique_class_paid