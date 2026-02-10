-- The extract is extracted from Exerp on 2026-02-08
-- ST - 1669
SELECT
    FULLNAME
  , PID
  ,SUBSCRIPTION
  ,CHECKIN_DATE
  ,attends_per_checkin
  , CHECKIN_TIME
  , RESOURCES_USED
  , CLUB_NAME
FROM
    (
        WITH
            params AS
            (
                SELECT
                    /*+ materialize */
                    dateToLongTZ(TO_CHAR(
                        CASE
                            WHEN $$type$$ = 'DAY'
                            THEN exerpsysdate() -1
                            WHEN $$type$$ = 'WEEK'
                            THEN exerpsysdate() -7
                            WHEN $$type$$ = 'MONTH'
                            THEN exerpsysdate() - TO_CHAR(last_day(exerpsysdate()),'DD')
                        END,'YYYY-MM-DD') || ' 00:00','Europe/Copenhagen')                      AS START_DATE
                  , dateToLongTZ(TO_CHAR(exerpsysdate(),'YYYY-MM-DD') || ' 00:00','Europe/Copenhagen') AS TODAY
                FROM
                    dual
            )
        SELECT DISTINCT
            p.FULLNAME
            --,                                                                                         att.CENTER,att.ID,att.START_TIME
          ,c.PERSON_CENTER || 'p' || c.PERSON_ID                                                        pid
          ,prod.NAME                                                                                    subscription
          ,TO_CHAR(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER),'YYYY-MM-DD')                            CHECKIN_DATE
          , TO_CHAR(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER),'HH24:MI')                              CHECKIN_TIME
            --          ,                                                                               CASE
            --                                                                                          WHEN c.CHECKIN_TIME - LEAD(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC) >= (1000 * 60 * 60 * 2)
            --                                                                                          AND TRUNC(longToDateC(c.CHECKIN_TIME,c.CHECKIN_CENTER)) = TRUNC(longToDateC(LEAD(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC),c.CHECKIN_CENTER))
            --                                                                                          THEN 1
            --                                                                                          ELSE 0
            --                                                                                          END DIFF_FROM_PREV_ROW_OK
          , COUNT(distinct att.ID) OVER (PARTITION BY c.ID)                                                           attends_per_checkin
            --          ,                                                                               CASE
            --                                                                                          WHEN LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC) - c.CHECKIN_TIME >= (1000 * 60 * 60 * 2)
            --                                                                                          AND TRUNC(longToDateC(c.CHECKIN_TIME,c.CHECKIN_CENTER)) = TRUNC(longToDateC(LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC),c.CHECKIN_CENTER))
            --                                                                                          THEN 1
            --                                                                                          ELSE 0
            --                                                                                          END                                                                                         DIFF_FROM_NEXT_ROW_OK
          ,LISTAGG(br.name ,' / ') WITHIN GROUP (ORDER BY att.START_TIME DESC) OVER (PARTITION BY c.ID) RESOURCES_USED
          ,cen.SHORTNAME                                                                                CLUB_NAME
        FROM
            CHECKINS c
        CROSS JOIN
            PARAMS
        JOIN
            ATTENDS att
        ON
            att.PERSON_CENTER = c.PERSON_CENTER
            AND att.PERSON_ID = c.PERSON_ID
            AND att.STATE = 'ACTIVE'
            AND att.START_TIME BETWEEN c.CHECKIN_TIME AND c.CHECKOUT_TIME
        LEFT JOIN
            BOOKING_RESOURCES br
        ON
            br.CENTER = att.BOOKING_RESOURCE_CENTER
            AND br.ID = att.BOOKING_RESOURCE_ID
        JOIN
            CENTERS cen
        ON
            cen.ID = c.CHECKIN_CENTER
        JOIN
            PERSONS p
        ON
            p.CENTER = c.PERSON_CENTER
            AND p.ID = c.PERSON_ID
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4,8)
        LEFT JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        WHERE
            c.CHECKIN_TIME >= PARAMS.START_DATE
            AND c.CHECKIN_TIME < PARAMS.TODAY
            AND c.PERSON_CENTER IN ($$scope$$)
            AND p.PERSONTYPE != 2 )
WHERE
    attends_per_checkin > 1
ORDER BY
    pid
  , CHECKIN_DATE
  , CHECKIN_TIME