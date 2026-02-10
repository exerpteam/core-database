-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/issues/EC-8358
WITH V_EXCLUDED_SUBSCRIPTIONS AS
    (
        SELECT
            ppgl.PRODUCT_CENTER as center,
            ppgl.PRODUCT_ID as id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
 )
 SELECT
     center,
     COUNT(*)                                             AS Members,
     SUM(student)                                         AS Students,
     ROUND(( SUM(student) / COUNT(*))*100 ,2)             AS Students_Percentage,
     ROUND(CAST(SUM(CASE WHEN student = 1 THEN age ELSE 0 END) / NULLIF(SUM(student),0) AS DECIMAL),2) AS Avg_Student_age
 FROM
     (
         SELECT DISTINCT
             p.center,
             p.id,
             floor(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12)    age,
             CASE WHEN scl2.STATEID = 1 THEN 1 ELSE 0 END  AS student
         FROM
             STATE_CHANGE_LOG scl
         JOIN
             SUBSCRIPTIONS s
         ON
             s.CENTER = scl.center
             AND s.id = scl.id
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             st.center = s.SUBSCRIPTIONTYPE_CENTER
             AND st.id = s.SUBSCRIPTIONTYPE_ID
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
         JOIN
             PERSONS p
         ON
             s.OWNER_CENTER = p.center
             AND s.OWNER_ID = p.id
         JOIN
             STATE_CHANGE_LOG scl2
         ON
             scl2.center = p.center
             AND scl2.id = p.id
             AND scl2.ENTRY_TYPE = 3
             AND $$check_date$$ >= scl2.BOOK_START_TIME
             AND (
                 $$check_date$$ < scl2.BOOK_END_TIME
                 OR scl2.BOOK_END_TIME IS NULL)
         WHERE
             $$check_date$$ >= scl.BOOK_START_TIME
             AND (
                 $$check_date$$ < scl.BOOK_END_TIME
                 OR scl.BOOK_END_TIME IS NULL)
             AND scl.STATEID IN (2,4)
             AND scl.ENTRY_TYPE = 2
             AND scl.center IN ($$scope$$)) t
 GROUP BY
     center
