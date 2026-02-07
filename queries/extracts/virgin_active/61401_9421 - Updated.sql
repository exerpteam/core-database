SELECT
  
    "PERSONID",
    "EMAILTYPE",
    "EMAILADDRESS",
    "LASTSEENDATE"
FROM
    (
        WITH
            params AS
            (
                SELECT
                    c.id
                FROM
                    centers c
                WHERE
                    c.country = 'IT'
            )
            ,
            timecontrol AS
            (
                SELECT
                    CAST(extract(epoch FROM timezone('Europe/Rome', CAST(CURRENT_DATE AS
                    timestamptz))) AS bigint)*1000 AS FROMDATE,
                    CAST(extract(epoch FROM timezone('Europe/Rome', CAST(CURRENT_DATE AS
                    timestamptz) + interval '1 day')) AS BIGINT) * 1000 AS TODATE
            )
        SELECT
            p.EXTERNAL_ID                                                           "PERSONEMAILID",
            p.EXTERNAL_ID                                                                "PERSONID",
            'HOME'                                                                      "EMAILTYPE",
            atts.TXTVALUE                                                            "EMAILADDRESS",
            longtodatec(pcl.ENTRY_TIME,100)                                                           "LASTSEENDATE",
            row_number() over (partition BY p.center,p.id ORDER BY pcl.entry_time ASC) AS rn
        FROM
            timecontrol,
            PERSON_EXT_ATTRS atts
        JOIN
            PERSONS pOld
        ON
            pOld.CENTER = atts.PERSONCENTER
        AND pOld.ID = atts.PERSONID
        JOIN
            PERSONS p
        ON
            p.CENTER = pOld.CURRENT_PERSON_CENTER
        AND p.ID = pOld.CURRENT_PERSON_ID
        JOIN
            params par
        ON
            par.id = p.center
        LEFT JOIN
            PERSON_CHANGE_LOGS pcl
        ON
            pcl.PERSON_CENTER = p.CENTER
        AND pcl.PERSON_ID = p.ID
        AND pcl.CHANGE_ATTRIBUTE = 'E_MAIL'
        WHERE
            atts.NAME = '_eClub_Email'
        AND p.SEX != 'C'
        AND p.EXTERNAL_ID IS NOT NULL
        AND pcl.entry_time between timecontrol.FROMDATE and timecontrol.TODATE ) t
WHERE
    rn = 1