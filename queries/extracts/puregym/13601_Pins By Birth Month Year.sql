SELECT
    NVL("MMYY",'Total') as MMYY,
    "Active Pins"
FROM
    (
        SELECT
            MONTH    AS "MMYY",
            COUNT(*) AS "Active Pins"
        FROM
            (
                SELECT
                    NVL(TO_CHAR(p.BIRTHDATE,'MMYY'),'XXXX') AS MONTH
                FROM
                    PUREGYM.PERSONS p
                JOIN
                    PUREGYM.ENTITYIDENTIFIERS e
                ON
                    e.IDMETHOD = 5
                    AND e.ENTITYSTATUS = 1
                    AND e.REF_CENTER = p.CENTER
                    AND e.REF_ID = p.ID
                    AND e.REF_TYPE = 1 )
        GROUP BY
            grouping sets ( ( MONTH), () ))