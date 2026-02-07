 WITH
         params AS
         (
                 SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24* $$offset$$
            AS bigint) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint)
            AS TODATE
                 
         )
 SELECT
    t3.PERSON_ID AS "PERSON_ID",
    BI_DECODE_FIELD ('PERSONS','MEMBER_STATUS',t3.STATEID) AS "MEMBER_STATE",
    t3.FROM_DATE AS "FROM_DATE",
    t3.CENTER AS "CENTER_ID"
 FROM
 params,
 (
        SELECT
            t2.PERSON_ID,
            t2.STATEID,
            TO_CHAR(longtodateC(FLOOR(t2.START_TIME/1000)*1000,t2.CENTER),'yyyy-MM-dd') AS FROM_DATE,
            t2.CENTER
         FROM
         (
                 SELECT
                         t1.PERSON_ID,
                         t1.STATEID,
                         t1.START_TIME,
                         t1.CENTER,
                         rank() over (partition BY t1.PERSON_ID,BI_TRUNC_DATE(longtodateC(FLOOR(t1.START_TIME/1000)*1000,t1.CENTER)) ORDER BY t1.START_TIME DESC) AS RNK
                 FROM
                 params,
                 (
                         SELECT
                                 cp.EXTERNAL_ID AS PERSON_ID,
                                 scl.STATEID,
                                 scl.CENTER AS CENTER,
                                 (CASE
                                         WHEN scl.STATEID = 5 THEN scl.BOOK_START_TIME
                                         WHEN scl.STATEID = 1 THEN scl.BOOK_START_TIME
                                         ELSE scl.ENTRY_START_TIME
                                 END) AS START_TIME
                        FROM STATE_CHANGE_LOG scl
                        JOIN CENTERS c ON c.ID = scl.CENTER AND c.COUNTRY = 'GB'
                        JOIN PERSONS p ON p.CENTER = scl.CENTER AND p.ID = scl.ID
                        JOIN PERSONS cp ON cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER AND cp.ID = p.TRANSFERS_CURRENT_PRS_ID
                        WHERE
                                 scl.ENTRY_TYPE = 5
                 ) t1
                 WHERE
                        t1.START_TIME BETWEEN params.FROMDATE AND params.TODATE
         ) t2
         WHERE
                 t2.RNK=1
 ) t3
