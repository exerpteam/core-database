SELECT
    FULLNAME
  , BIRTHDATE
  , PID
  ,SUBSCRIPTION
  ,CHECKIN_DATE
  , CHECKIN_TIME
  , CHECKOUT_TIME
  , RESOURCES_USED
  , CLUB_NAME
FROM
    (
        WITH
            params AS
            (
                SELECT
                    /*+ materialize */
                    dateToLongTZ(TO_CHAR(SYSDATE-1,'YYYY-MM-DD') || ' 00:00','Europe/London') AS PREV_DAY
                  , dateToLongTZ(TO_CHAR(SYSDATE,'YYYY-MM-DD') || ' 00:00','Europe/London')   AS TODAY
                FROM
                    dual
            )
        SELECT DISTINCT
            p.FULLNAME
          ,p.BIRTHDATE
          ,c.PERSON_CENTER || 'p' || c.PERSON_ID         pid
          ,prod.NAME subscription
          ,to_char(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER),'YYYY-MM-DD')  CHECKIN_DATE
          , to_char(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER),'HH24:MI')  CHECKIN_TIME
          , to_char(longToDateC(c.CHECKOUT_TIME,c.PERSON_CENTER),'HH24:MI') CHECKOUT_TIME
          , CASE
                WHEN c.CHECKIN_TIME - LEAD(c.CHECKOUT_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC) >= (1000 * 60 * 60 * 2) 
                and trunc(longToDateC(c.CHECKIN_TIME,c.CHECKIN_CENTER)) = trunc(longToDateC(LEAD(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC),c.CHECKIN_CENTER))
                THEN 1
                ELSE 0
            END DIFF_FROM_PREV_ROW_OK
          , CASE
                WHEN LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC) - c.CHECKOUT_TIME >= (1000 * 60 * 60 * 2)
                and trunc(longToDateC(c.CHECKIN_TIME,c.CHECKIN_CENTER)) = trunc(longToDateC(LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC),c.CHECKIN_CENTER))
                THEN 1
                ELSE 0
            END                                                                                         DIFF_FROM_NEXT_ROW_OK
          ,LISTAGG(br.name ,' / ') WITHIN GROUP (ORDER BY att.START_TIME DESC) OVER (PARTITION BY c.ID) RESOURCES_USED
          ,cen.SHORTNAME                                                                                CLUB_NAME
            --  ,LEAD(longToDateC(c.CHECKOUT_TIME,c.PERSON_CENTER)) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) PREV_CHECKOUT
            --  ,LAG(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER)) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) NEXT_CHECKIN
            --  ,LEAD(c.CHECKOUT_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) PREV_CHECKOUT_LONG
            --  ,LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) NEXT_CHECKIN_LONG
        FROM
            CHECKINS c
        CROSS JOIN
            PARAMS
        LEFT JOIN
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
        left join SUBSCRIPTIONS s on s.OWNER_CENTER = p.CENTER and s.OWNER_ID = p.ID and s.STATE in (2,4,8)    
        left join PRODUCTS prod on prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER and prod.ID = s.SUBSCRIPTIONTYPE_ID
        WHERE
            c.CHECKIN_TIME >= PARAMS.PREV_DAY
            AND c.CHECKIN_TIME < PARAMS.TODAY
            AND c.PERSON_CENTER in ($$scope$$)
            and p.PERSONTYPE != 2
)
WHERE
    DIFF_FROM_PREV_ROW_OK = 1
    OR DIFF_FROM_NEXT_ROW_OK = 1
order by pid, CHECKIN_DATE, CHECKIN_TIME 