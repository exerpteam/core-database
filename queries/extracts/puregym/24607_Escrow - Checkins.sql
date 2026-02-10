-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center || 'p' || p.id                                                                                 personid,
    c.ID                                                                                                    CHECKIN_ID,
    c.CHECKIN_CENTER                                                                                        CENTER_ID,
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd')                                     CHECK_IN_DATE,
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'HH24:MI')                                        CHECK_IN_TIME ,
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd')                                    CHECK_OUT_DATE,
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER),'HH24:MI')                                       CHECK_OUT_TIME ,
    DECODE(c.CHECKIN_RESULT, 1, 'ACCESS_GRANTED' , 2, 'PRESENCE_REGISTERED', 3, 'ACCESS_DENIED', 'UNKNOWN') CHECK_IN_RESULT,
    c.checkin_result
FROM
    CHECKINS c
JOIN
    PERSONS p
ON
    p.CENTER = c.PERSON_CENTER
    AND p.id = c.PERSON_ID
WHERE
    c.CHECKIN_TIME BETWEEN $$from_date$$ AND $$to_date$$
    AND p.center IN ($$scope$$)
