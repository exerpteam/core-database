WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                      AS FromDate
          , ($$EndDate$$ + 86400 * 1000) - 1 AS ToDate
        FROM
            dual
    )
SELECT
    pid
    ,CLIP_CARD_KEY
    ,CLIP_CARD_NAME
  , classdate                                                                AS "Class Date"
  , classtime                                                                AS "Class Time"
  , name                                                                     AS "Class Type"
--  , CLASS_CAPACITY                                                           AS "Available Seats"
--  , total_attend + total_absent                                              AS "Total Booked"
--  , total_attend                                                             AS "Total Attend"
--  , total_absent                                                             AS "Total Absent"
--  , ROUND(((total_attend + total_absent) / CLASS_CAPACITY) * 100, 2)         AS "Booked Ratio %"
--  , ROUND(total_attend / NULLIF((total_attend + total_absent),0) * 100, 2)   AS "Show Ration %"
--  , ROUND((total_attend / CLASS_CAPACITY) * 100, 2)                          AS "Attend Ratio %"
--  , ROUND((total_absent / NULLIF((total_attend + total_absent),0)) * 100, 2) AS "Absent Ratio %"
  , total_attend_clips                                                       AS "Attend Clips Used"
  , total_absent_clips                                                       AS "Absent Clips Used"
  , total_attend_clips + total_absent_clips                                  AS "Total Clips Used"
  , ROUND((total_absent_clips / NULLIF(total_absent,0)) * 100, 2)            AS "Absent Clips Charge Ratio %"
  , ROUND(total_attend_revenue, 2)                                           AS "Attend Clip Revenue"
  , ROUND(total_absent_revenue, 2)                                           AS "Absent Clip Revenue"
  , ROUND(total_attend_revenue + total_absent_revenue, 2)                    AS "Total Revenue"
--  , ROUND(total_attend_revenue / NULLIF(total_attend,0), 2)                  AS "Yield per attend"
FROM
    (
        SELECT
            class.classdate
          , class.classtime
          , class.name
          , class.CLASS_CAPACITY
          , class.pid
          ,class.CC_KEY CLIP_CARD_KEY
          ,class.CC_NAME CLIP_CARD_NAME
          , SUM(
                CASE
                    WHEN class.state = 'PARTICIPATION'
                    THEN 1
                    ELSE 0
                END )AS total_attend
          , SUM(
                CASE
                    WHEN class.state = 'CANCELLED'
                    THEN 1
                    ELSE 0
                END)AS total_absent
          , SUM(
                CASE
                    WHEN class.state = 'PARTICIPATION'
                    THEN class.clips * -1
                    ELSE 0
                END )AS total_attend_clips
          , SUM(
                CASE
                    WHEN class.state = 'CANCELLED'
                    THEN class.clips * -1
                    ELSE 0
                END)AS total_absent_clips
          , SUM(
                CASE
                    WHEN class.state = 'PARTICIPATION'
                    THEN class.amount / clips_initial
                    ELSE 0
                END )AS total_attend_revenue
          , SUM(
                CASE
                    WHEN class.state = 'CANCELLED'
                    THEN class.amount / clips_initial
                    ELSE 0
                END)AS total_absent_revenue
        FROM
            (
                SELECT
                    TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'yyyy-MM-dd') classdate
                  , TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'HH24:MI')    classtime
                  , p.center || 'p' || p.id                                          pid
                  ,cc.center || 'cc' || cc.id || 'cc' || cc.subid CC_KEY
                  ,cp.name CC_NAME
                  , bo.NAME
                  , GREATEST(bo.CLASS_CAPACITY, NVL(brc.maximum_participations, bo.CLASS_CAPACITY)) AS CLASS_CAPACITY
                  , pa.state
                  , ccu.clips
                  , cc.clips_initial
                  , act.amount
                FROM
                    BOOKINGS bo
                JOIN
                    BOOKING_RESOURCE_USAGE bru
                ON
                    bru.BOOKING_ID = bo.ID
                    AND bru.BOOKING_CENTER = bo.CENTER
                JOIN
                    BOOKING_RESOURCES br
                ON
                    br.CENTER = bru.BOOKING_RESOURCE_CENTER
                    AND br.ID = bru.BOOKING_RESOURCE_ID
                JOIN
                    BOOKING_RESOURCE_CONFIGS brc
                ON
                    brc.BOOKING_RESOURCE_CENTER = br.CENTER
                    AND brc.BOOKING_RESOURCE_ID = br.ID
                CROSS JOIN
                    params
                JOIN
                    ACTIVITY ac
                ON
                    ac.ID = bo.ACTIVITY
                JOIN
                    ACTIVITY_GROUP ag
                ON
                    ag.ID = ac.activity_group_id
                JOIN
                    participations pa
                ON
                    (
                        pa.state = 'PARTICIPATION'
                        OR (
                            pa.state = 'CANCELLED'
                            AND pa.cancelation_reason = 'NO_SHOW'))
                    AND pa.booking_center = bo.center
                    AND pa.booking_id = bo.id
                JOIN
                    persons p
                ON
                    p.id = pa.participant_id
                    AND p.center = pa.participant_center
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
                left join PRODUCTS cp on cp.CENTER = il.productcenter and cp.id    = il.productid
                LEFT JOIN
                    account_trans act
                ON
                    act.center = il.account_trans_center
                    AND act.id = il.account_trans_id
                    AND act.subid = il.account_trans_subid
                WHERE
                    bo.CENTER IN ($$Scope$$)
                    AND bo.STARTTIME >= params.FromDate
                    AND bo.STARTTIME <= params.ToDate
                    AND p.sex IN ($$Sex$$)
                    AND bo.STATE = 'ACTIVE'
                    AND ag.name = 'Pure Ride Classes')class
        GROUP BY
            class.classdate
          , class.classtime
          , class.name
          , class.CLASS_CAPACITY
          , class.pid,class.CC_KEY, class.CC_NAME )