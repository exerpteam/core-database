SELECT
    p.FULLNAME                                                        AS "Name",
    p.SEX                                                             AS "Gender",
    TO_CHAR(p.BIRTHDATE ,'yyyy-MM-dd')                                AS "D.O.B",
    TO_CHAR(TRUNC(longtodateC(bo.STARTTIME,par.center)),'yyyy-MM-dd') AS "Date of Class to Attend",
    TO_CHAR(TRUNC(longtodateC(bo.STARTTIME,par.center)),'hh:mm')      AS "Time",
    bs.REF                                                            AS "Seat"
FROM
    PUREGYM.BOOKINGS bo
JOIN
    PUREGYM.PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bo.CENTER
    AND par.BOOKING_ID = bo.ID
JOIN
    PUREGYM.BOOKING_SEATS bs
ON
    bs.ID = par.SEAT_ID
JOIN
    PUREGYM.PERSONS p
ON
    p.center = par.PARTICIPANT_CENTER
    AND p.id = par.PARTICIPANT_ID
WHERE
    par.STATE IN ('BOOKED',
                  'PARTICIPATION')
    AND bo.STARTTIME BETWEEN $$from_date$$ AND $$to_date$$
    AND TO_CHAR(TRUNC(longtodateC(bo.STARTTIME,par.center)),'MM-dd')= TO_CHAR(p.BIRTHDATE,'MM-dd')
    AND p.SEX IN($$Gender$$)
    AND par.CENTER IN ($$scope$$)