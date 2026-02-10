-- The extract is extracted from Exerp on 2026-02-08
-- number of times that a 'blacklisted' note was created and a 'balcklisted cancelled' note was created within 5 minutes
SELECT
    bl.PERSON_CENTER,
    NVL(cen.NAME,'TOTAL'),
    COUNT(*),
    SUM(
        CASE
            WHEN (
                    SELECT
                        1
                    FROM
                        PUREGYM.SUBSCRIPTIONS s
                    WHERE
                        s.STATE =3
                        AND s.OWNER_CENTER = bl.PERSON_CENTER
                        AND s.OWNER_ID = bl.PERSON_ID
                        AND s.SUB_STATE IN (3,4)
                        AND rownum = 1
                        AND s.END_DATE BETWEEN longtodate(bl.CREATION_TIME)-14 AND longtodate(bl.CREATION_TIME)) IS NOT NULL
            THEN 1
            ELSE 0
        END) AS Changed,
    SUM(
        CASE
            WHEN (
                    SELECT
                        1
                    FROM
                        PUREGYM.SUBSCRIPTIONS s
                    WHERE
                        s.STATE =3
                        AND s.OWNER_CENTER = bl.PERSON_CENTER
                        AND s.OWNER_ID = bl.PERSON_ID
                        AND s.SUB_STATE IN (3,4)
                        AND rownum = 1
                        AND s.END_DATE BETWEEN longtodate(bl.CREATION_TIME)-14 AND longtodate(bl.CREATION_TIME)) IS NULL
            THEN 1
            ELSE 0
        END) AS NotChanged
FROM
    PUREGYM.JOURNALENTRIES BL
JOIN
    PUREGYM.JOURNALENTRIES UBL
ON
    UBL.PERSON_CENTER = bl.PERSON_CENTER
    AND ubl.PERSON_ID = BL.PERSON_ID
    AND ubl.CREATION_TIME - bl.CREATION_TIME BETWEEN 0 AND 1000*60*5
    AND ubl.name = 'Blacklist cancelled'
JOIN
    PUREGYM.CENTERS cen
ON
    bl.PERSON_CENTER = cen.ID
    /*LEFT JOIN
    (
    SELECT
    s.OWNER_CENTER,
    s.OWNER_ID,
    s.END_DATE
    FROM
    PUREGYM.SUBSCRIPTIONS s
    WHERE
    s.STATE =3
    AND s.SUB_STATE IN (3,4)) Upgrades
    ON
    Upgrades.OWNER_CENTER = bl.PERSON_CENTER
    AND Upgrades.OWNER_ID = bl.PERSON_ID*/
WHERE
    BL.name='Blacklisted'
    AND BL.CREATION_TIME BETWEEN :start_date AND :end_date
GROUP BY
    grouping sets((bl.PERSON_CENTER,cen.NAME),())