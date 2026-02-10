-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1.CTime AS "Date",
        COUNT(*) AS "Stop date"
FROM
(
        WITH PREPARAMS AS
        (
                SELECT
                        TRUNC(TO_DATE(getCenterTime(c.ID), 'YYYY-MM-DD HH24:MI'))-:Offset DATE_BUILD_FROM,
                        TRUNC(TO_DATE(getCenterTime(c.ID), 'YYYY-MM-DD HH24:MI')) DATE_BUILD_TO,
                        c.ID AS CENTER,
                        co.DEFAULTTIMEZONE
                FROM
                        CENTERS c
                JOIN
                        FW.COUNTRIES co ON co.ID = c.COUNTRY
        )
        ,
        PARAMS AS
        (
                SELECT
                        /*+ materialize  */
                        DATETOLONGTZ(TO_CHAR(pp.DATE_BUILD_FROM, 'YYYY-MM-DD HH24:MI'),pp.DEFAULTTIMEZONE) AS FROM_DATE,
                        DATETOLONGTZ(TO_CHAR(pp.DATE_BUILD_TO, 'YYYY-MM-DD HH24:MI'),pp.DEFAULTTIMEZONE) AS TO_DATE,
                        pp.CENTER
                FROM 
                        PREPARAMS pp
        )
        SELECT
                TRUNC(longtodateC(sc.CHANGE_TIME, sc.OLD_SUBSCRIPTION_CENTER)) AS CTime     
        FROM
                SUBSCRIPTIONS s
        JOIN
                PARAMS params
                ON
                        s.CENTER = params.CENTER
        JOIN
                FW.SUBSCRIPTIONTYPES st
                        ON
                                st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                                AND st.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN 
                SUBSCRIPTION_CHANGE sc
                ON
                        sc.OLD_SUBSCRIPTION_CENTER = s.CENTER
                        AND sc.OLD_SUBSCRIPTION_ID = s.ID
                        AND sc.TYPE = 'END_DATE'
                        AND sc.CANCEL_TIME IS NULL
        WHERE
                s.END_DATE IS NOT NULL
                AND st.ST_TYPE = 1
                AND s.CENTER IN (:Scope)
                AND sc.CHANGE_TIME >= params.FROM_DATE
                AND sc.CHANGE_TIME < params.TO_DATE
                AND
                NOT EXISTS
                (
                        SELECT
                                1
                        FROM 
                                FW.SUBSCRIPTION_CHANGE sc2
                        WHERE
                                sc2.OLD_SUBSCRIPTION_CENTER = sc.OLD_SUBSCRIPTION_CENTER
                                AND sc2.OLD_SUBSCRIPTION_ID = sc.OLD_SUBSCRIPTION_ID
                                AND sc2.CHANGE_TIME BETWEEN sc.CHANGE_TIME-60000 AND sc.CHANGE_TIME+60000  -- EXTENSIONS CAN TAKE UP TO 1 MINUTE
                                AND sc2.ID != sc.ID
                                AND sc2.TYPE != 'END_DATE'
                )
                
) t1
GROUP BY t1.CTime
ORDER BY t1.CTime