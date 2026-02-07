SELECT
        t2.PersonCenter || 'p' || t2.PersonId AS "Owner Key",
        infoP.EXTERNAL_ID AS "Owner external ID",
        infoP.FULLNAME AS "Owner name",
        DECODE(infoP.PERSONTYPE, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 
                              6,'Family', 7,'Senior', 8,'Guest', 9, 'Child', 10, 'External_Staff','Unknown') AS "Owner type",
        DECODE(infoP.STATUS,1,'Active',3,'TemporaryInactive') AS "Owner state",
        t2.FirstActiveDate AS "Member's first activation date",
        t2.MinCreationTime AS "Original membership sales date",
        t2.MinStartDate AS "Original membership start date",
        t2.MaxCreationTime AS "Latest membership sales date",
        t2.MaxStartDate AS "Latest membership start date"
FROM
(
        SELECT
                t1.PersonCenter,
                t1.PersonId,
                longtodateC(MAX(t1.SubCreationTime),t1.PersonCenter)    AS MinCreationTime,
                MAX(t1.BOOK_S)                                          AS MinStartDate,
                longtodateC(t1.LATEST_START_DATE,t1.PersonCenter)       AS MaxStartDate,
                longtodateC(t1.LATEST_CREATION_DATE,t1.PersonCenter)    AS MaxCreationTime,
                longtodateC(t1.FirstActiveDate,t1.PersonCenter)         AS FirstActiveDate
        FROM
            (
                SELECT
                    x.PersonCenter,
                    x.PersonId,
                    x.SubscriptionId,
                    x.SubCreationTime,
                    longtodateC(lag(x.END_DATE) over (partition BY x.PersonCenter,x.PersonId ORDER BY x.SubStartDate ASC),x.PersonCenter)        AS PREV,
                    longtodateC(x.END_DATE,x.PersonCenter)                                                                                       AS BOOK_E,
                    longtodateC(x.SubStartDate,x.PersonCenter)                                                                                   AS BOOK_S,
                    (x.SubStartDate - lag(x.END_DATE) over (partition BY x.PersonCenter,x.PersonId ORDER BY x.SubStartDate ASC))/(1000*60*60*24) AS DIST_TO_PREV,
                    MAX(x.SubStartDate) over (partition BY x.PersonCenter,x.PersonId ORDER BY x.SubStartDate DESC)                               AS LATEST_START_DATE,
                    MAX(x.SubCreationTime) over (partition BY x.PersonCenter,x.PersonId ORDER BY x.SubStartDate DESC)                            AS LATEST_CREATION_DATE,
                    MIN(x.FirstActiveDate) over (partition BY x.PersonCenter,x.PersonId)                                                         AS FirstActiveDate
                FROM
                        (
                                SELECT
                                        p.TRANSFERS_CURRENT_PRS_CENTER AS PersonCenter,
                                        p.TRANSFERS_CURRENT_PRS_ID     AS PersonId,
                                        s.CENTER||'ss'|| s.ID          AS SubscriptionId,
                                        s.CREATION_TIME                AS SubCreationTime,
                                        MAX(scl1.BOOK_END_TIME)   AS END_DATE,
                                        MIN(scl1.BOOK_START_TIME) AS SubStartDate,
                                        MIN(st.ENTRY_START_TIME) AS FirstActiveDate
                                FROM
                                        SUBSCRIPTIONS s
                                JOIN
                                        PERSONS p ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID
                                JOIN
                                        PERSONS cp ON cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER AND cp.ID = p.TRANSFERS_CURRENT_PRS_ID
                                JOIN
                                        HP.STATE_CHANGE_LOG scl1 ON scl1.center = s.center AND scl1.id = s.id AND scl1.ENTRY_TYPE = 2 AND scl1.STATEID = 2
                                JOIN STATE_CHANGE_LOG st 
                                        ON p.CENTER = st.CENTER AND p.ID = st.ID AND st.ENTRY_TYPE = 1 AND st.STATEID = 1
                                WHERE

                                        cp.center = 19 and cp.id = 3533
                                GROUP BY
                                        p.TRANSFERS_CURRENT_PRS_CENTER ,
                                        p.TRANSFERS_CURRENT_PRS_ID ,
                                        s.CENTER,
                                        s.ID,
                                        s.CREATION_TIME
                        ) x
                ) t1
        WHERE
                t1.DIST_TO_PREV IS NULL
                OR 
                t1.DIST_TO_PREV >= 90
        GROUP BY
                t1.PersonCenter,
                t1.PersonId,
                t1.LATEST_START_DATE,
                t1.LATEST_CREATION_DATE,
                t1.FirstActiveDate
) t2
JOIN PERSONS infoP ON t2.PersonCenter = infoP.CENTER AND t2.PersonId = infoP.ID