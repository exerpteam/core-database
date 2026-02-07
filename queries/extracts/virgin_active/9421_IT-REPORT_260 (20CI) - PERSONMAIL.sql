WITH
    info AS MATERIALIZED
    (
        WITH
            PARAMS AS MATERIALIZED
            (
                SELECT
                    id
                FROM
                    centers c
                WHERE
                    c.country = 'IT'

            )
        SELECT
            p.EXTERNAL_ID                           "PERSONEMAILID",
            p.EXTERNAL_ID                           "PERSONID",
            'HOME'                                  "EMAILTYPE",
            atts.TXTVALUE                           "EMAILADDRESS",
            longToDateC(pcl.ENTRY_TIME,p.center) AS "LASTSEENDATE"
        FROM
            person_ext_attrs atts
        JOIN
            persons pOld
        ON
            pOld.CENTER = atts.PERSONCENTER
        AND pOld.ID = atts.PERSONID
        AND CAST(pOld.SEX AS VARCHAR) != 'C'
        AND atts.NAME = '_eClub_Email'
        JOIN
            params par
        ON
            par.id = pOld.center
        JOIN
            persons p
        ON
            p.CENTER = pOld.CURRENT_PERSON_CENTER
        AND p.ID = pOld.CURRENT_PERSON_ID
        LEFT JOIN
            PERSON_CHANGE_LOGS pcl
        ON
            pcl.PERSON_CENTER = p.CENTER
        AND pcl.PERSON_ID = p.ID
        AND pcl.CHANGE_ATTRIBUTE = 'E_MAIL'
            --WHERE
            --    atts.NAME = '_eClub_Email'
            --AND p.SEX != 'C'
            --AND p.center IN
            --    (
            --        SELECT
            --            c.ID
            --        FROM
            --            CENTERS c
            --        WHERE
            --            c.COUNTRY = 'IT')
            --GROUP BY
            --    p.center,
            --    p.EXTERNAL_ID ,
            --    atts.TXTVALUE
    )
SELECT
    "PERSONEMAILID",
    "PERSONID",
    "EMAILTYPE",
    "EMAILADDRESS",
    MAX("LASTSEENDATE") AS "LASTSEENDATE"
FROM
    info
GROUP BY
    "PERSONEMAILID",
    "PERSONID",
    "EMAILTYPE",
    "EMAILADDRESS"