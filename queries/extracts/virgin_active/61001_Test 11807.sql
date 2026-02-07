WITH
    params AS
    (
        SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24* $$offset$$
            AS bigint) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint
            ) AS TODATE
    )
SELECT
    biview.*
FROM
    (
        SELECT
            c.ID             "ID",
            c.CHECKIN_CENTER "CENTER_ID",
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                    OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END AS                                                        "PERSON_ID",
            p.CENTER                                                      "HOME_CENTER_ID",
            c.CHECKIN_TIME  AS                                            "CHECK_IN_DATETIME",
            c.CHECKOUT_TIME AS                                            "CHECK_OUT_DATETIME",
            BI_DECODE_FIELD('CHECKINS','CHECKIN_RESULT',c.CHECKIN_RESULT) "RESULT",
            CAST(CAST (c.CARD_CHECKED_IN AS INT) AS SMALLINT) AS          "CARD_CHECKED_IN",
            c.CHECKIN_TIME                                                "ETS"
        FROM
            CHECKINS c
        LEFT JOIN
            PERSONS p
        ON
            p.CENTER = c.PERSON_CENTER
        AND p.id = c.PERSON_ID) biview,
    PARAMS
WHERE
    biview."ETS" >= PARAMS.FROMDATE
AND biview."ETS" < PARAMS.TODATE
AND biview."CENTER_ID" IN ($$scope$$)  