-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     centers.name,
     TO_CHAR(TRUNC(longToDateTZ(CIL.CHECKIN_TIME,'Europe/London'),'HH'),'YYYY-MM-dd') AS "Checkin date",
     TO_CHAR(TRUNC(longToDateTZ(CIL.CHECKIN_TIME,'Europe/London'),'HH'),'HH24:MI')    AS "Checkin Hour",
     COUNT(DISTINCT CIL.PERSON_CENTER||'p'||CIL.PERSON_ID)                            AS "Checkins"
 FROM
     CHECKINS CIL
 JOIN
     CENTERS centers
 ON
     centers.id = cil.CHECKIN_CENTER
 WHERE
     (
         CIL.CHECKIN_CENTER IN($$scope$$)
         AND CIL.CHECKIN_TIME >= datetolong(TO_CHAR(trunc(current_timestamp-1), 'YYYY-MM-DD HH24:MI'))
         AND CIL.CHECKIN_TIME <= datetolong(TO_CHAR(trunc(current_timestamp), 'YYYY-MM-DD HH24:MI'))
         AND NOT EXISTS
         (
             SELECT
                 1
             FROM
                 CHECKINS CIL2
             WHERE
                 CIL2.PERSON_CENTER = cil.PERSON_CENTER
                 AND cil2.PERSON_ID = cil.PERSON_ID
                 AND cil2.ID!=cil.id
                 AND CIL2.CHECKIN_TIME<CIL.CHECKIN_TIME
                 AND CIL2.CHECKIN_TIME>datetolongtz(TO_CHAR(TRUNC(longToDateTZ(CIL.CHECKIN_TIME,'Europe/London')),'YYYY-MM-dd HH24:MI'),'Europe/London') )
         AND EXISTS
         (
             SELECT
                 SCL99.STATEID AS SCL99_STATEID
             FROM
                 STATE_CHANGE_LOG SCL99
             WHERE
                 (
                     SCL99.ENTRY_TYPE = 3
                     AND SCL99.CENTER = CIL.PERSON_CENTER
                     AND SCL99.ID = CIL.PERSON_ID
                     AND SCL99.BOOK_START_TIME <= datetolong(TO_CHAR(trunc(current_timestamp), 'YYYY-MM-DD HH24:MM'))
                     AND (
                         SCL99.BOOK_END_TIME IS NULL
                         OR SCL99.BOOK_END_TIME >= datetolong(TO_CHAR(trunc(current_timestamp), 'YYYY-MM-DD HH24:MM'))
                     AND SCL99.STATEID IN (0,1,2,3,4,5,6,7,8)))))
 GROUP BY
     TRUNC(longToDateTZ(CIL.CHECKIN_TIME,'Europe/London'),'HH'),
     centers.name,
         datetolong(TO_CHAR(trunc(current_timestamp), 'YYYY-MM-DD HH24:MM'))
 ORDER BY
     centers.name,
     TRUNC(longToDateTZ(CIL.CHECKIN_TIME,'Europe/London'),'HH')
