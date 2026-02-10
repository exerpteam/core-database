-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-7477
 WITH
	PARAMS AS Materialized
    (
        SELECT
            CAST($$FromDate$$ AS BIGINT)                   AS STARTTIME ,
            CAST($$FromDate$$ + 86400 * 1000 AS BIGINT)    AS ENDTIME,
            CAST($$FromDate$$ + 86400 * 1000 *2 AS BIGINT) AS HARDCLOSETIME
         
     ),
	V_EXCLUDED_SUBSCRIPTIONS AS Materialized
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
    ),
    INCLUDED_ST AS Materialized
    (
         SELECT
             DISTINCT st1.center,
             st1.id
         FROM
             SUBSCRIPTIONTYPES st1
         WHERE
             st1.center IN ($$Scope$$)
             AND (
                 st1.center, st1.id) NOT IN
             (
                 SELECT
                     center,
                     id
                 FROM
                     V_EXCLUDED_SUBSCRIPTIONS
                 WHERE
                     center IN ($$Scope$$) )
     )
     ,
     SCL_TEMP AS  Materialized
     (
         SELECT
             per.fullname                                                                                                                                                AS FULLNAME,
             per.CENTER                                                                                                                                                  AS CENTER,
             per.ID                                                                                                                                                      AS ID,
             su.center                                                                                                                                                   AS SUB_CENTER,
             su.id                                                                                                                                                       AS SUB_ID,
             curper.external_id                                                                                                                                          AS EXTERNAL_ID,
    	     CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE, 
             TO_CHAR(su.end_date, 'YYYY-MM-DD')                                                                                                                                                          AS SUB_END_DATE,
             c.shortname                                                                                                                                                 AS CENTER_NAME,
             pd.name                                                                                                                                                     AS PROD_NAME,
             CASE
                 WHEN ( SCL.BOOK_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                         OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                     AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
                     AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                 THEN 1
                 ELSE 0
             END AS "IN_OUTGOING" ,
             CASE
                 WHEN ( SCL.BOOK_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                         OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                     AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME
                     AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
                 THEN 1
                 ELSE 0
             END AS "IN_INCOMING",
             rank() over (partition BY per.center, per.id ORDER BY su.creation_time) AS rnk,
            SUM(
                CASE
                    WHEN ( SCL.BOOK_END_TIME IS NULL
                        OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR  SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    THEN 1
                    ELSE 0
                END) over (partition BY per.center, per.id) AS outgoing_sum
         FROM
             PARAMS,
             INCLUDED_ST ST
         JOIN
             SUBSCRIPTIONS su
         ON
             su.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
             AND su.SUBSCRIPTIONTYPE_ID = ST.ID
         JOIN
             persons per
         ON
             per.center = su.owner_center
             AND per.id = su.owner_id
         JOIN
             persons curper
         ON
             curper.center = per.transfers_current_prs_center
             AND curper.id = per.transfers_current_prs_id
         JOIN
             centers c
         ON
             c.id = per.center
         JOIN
             products pd
         ON
             pd.center = su.subscriptiontype_center
             AND pd.id = su.subscriptiontype_id
         JOIN
             STATE_CHANGE_LOG SCL
         ON
             SCL.CENTER = SU.CENTER
             AND SCL.ID = SU.ID
             AND SCL.ENTRY_TYPE = 2
         WHERE
             SU.CENTER IN ($$Scope$$)
             AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
             AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
             AND (
                 SCL.BOOK_END_TIME IS NULL
                 OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                 OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
             AND SCL.ENTRY_TYPE = 2
             AND SCL.STATEID IN ( 2,4,8 )
     )
 SELECT
     tmp1.FULLNAME                          AS "Name",
     tmp1.PERSONTYPE                        AS "Person Type",
     tmp1.SUB_END_DATE                      AS "Subscription End Date",
     tmp1.CENTER                            AS "Center ID",
     tmp1.CENTER_NAME                       AS "Club Name",
     tmp1.EXTERNAL_ID                       AS "External ID",
     tmp1.CENTER || 'p'|| tmp1.ID           AS "Person ID",
     tmp1.SUB_CENTER || 'ss' || tmp1.SUB_ID AS "Subscription ID",
     tmp1.PROD_NAME                         AS "Product Name"
 FROM
     SCL_TEMP tmp1
 WHERE
    tmp1."IN_INCOMING" = 1
	AND tmp1.rnk = 1
	AND tmp1.outgoing_sum = 0
