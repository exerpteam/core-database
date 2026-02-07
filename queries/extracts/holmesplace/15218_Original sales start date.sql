
SELECT
        t2.PersonCenter || 'p' || t2.PersonId AS "Owner Key",
        infoP.EXTERNAL_ID AS "Owner external ID",
        infoP.FULLNAME AS "Owner name",
        CASE infoP.persontype
                when 0 then 'Private'
                when 1 then 'Student'
                when 2 then 'Staff'
                when 3 then 'Friend'
                when 4 then 'Corporate'
                when 5 then 'Onemancorporate'
                when 6 then 'Family'
                when 7 then 'Senior'
                when 8 then 'Guest'
                when 9 then 'Child'
                when 10 then 'External_staff'
                ELSE 'Unknown'
        END AS "Owner Type",
        CASE infoP.STATUS
                when 1 then 'Active'
                when 3 then 'TemporaryInactive'
        END AS "Owner state",
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
                                        products pr
                                ON
                                    s.SUBSCRIPTIONTYPE_CENTER = pr.center
                                    AND s.SUBSCRIPTIONTYPE_ID = pr.id
                                JOIN
                                    PRODUCT_AND_PRODUCT_GROUP_LINK pp
                                ON
                                    pr.center = pp.PRODUCT_CENTER
                                    AND pr.id = pp.PRODUCT_ID
                                    AND pp.PRODUCT_GROUP_ID in (4,5,18015,20815,21215,23016)
                                JOIN
                                        PERSONS p ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID
                                JOIN
                                        PERSONS cp ON cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER AND cp.ID = p.TRANSFERS_CURRENT_PRS_ID
                                JOIN
                                        HP.STATE_CHANGE_LOG scl1 ON scl1.center = s.center AND scl1.id = s.id AND scl1.ENTRY_TYPE = 2 AND scl1.STATEID = 2
                                JOIN STATE_CHANGE_LOG st 
                                        ON p.CENTER = st.CENTER AND p.ID = st.ID AND st.ENTRY_TYPE = 1 AND st.STATEID = 1
                                WHERE
                                        cp.CENTER IN (:Scope)
                                        --AND cp.ID = 1441
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