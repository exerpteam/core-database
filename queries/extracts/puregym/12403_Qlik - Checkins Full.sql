SELECT
            c.ID                                                                                                    CHECKIN_ID,
            c.CHECKIN_CENTER                                                                                        CENTER_ID,
            cp.EXTERNAL_ID                                                                                          PERSON_ID,
            TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd')                             CHECK_IN_DATE,
            TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'HH24:MI')                                CHECK_IN_TIME ,
            TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd')                            CHECK_OUT_DATE,
            TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER),'HH24:MI')                               CHECK_OUT_TIME ,
            DECODE(c.CHECKIN_RESULT, 1, 'ACCESS_GRANTED' , 2, 'PRESENCE_REGISTERED', 3, 'ACCESS_DENIED', 'UNKNOWN') CHECK_IN_RESULT,
            c.CHECKIN_TIME                                                                                          CHECK_IN_ETS
        FROM
            CHECKINS c
        JOIN
            PERSONS p
        ON
            p.CENTER = c.PERSON_CENTER
            AND p.id = c.PERSON_ID
        JOIN
            PERSONS cp
        ON
            cp.center = p.CURRENT_PERSON_CENTER
            AND cp.id = p.CURRENT_PERSON_ID
where c.CHECKIN_TIME >= 1446336000000 