 WITH
     params AS
     (
         SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI'
                    ) )
            END                                                                       AS FROMDATE,
            datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS TODATE
     )
 SELECT
 replace(replace(replace(replace(replace("VISIT_ID", CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "VISIT_ID",
 "CENTER_ID",
 "PERSON_ID",
 "HOME_CENTER_ID",
 "CHECK_IN_DATE",
 "CHECK_IN_TIME",
 "CHECK_OUT_DATE",
 "CHECK_OUT_TIME",
 "CHECK_IN_RESULT",
 "CARD_CHECKED_IN"
 FROM
     params,
     BI_VISIT_LOG biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
     and biview."CENTER_ID" in ($$scope$$)
