-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.NAME AS "club",
    c.id   AS "Club ID",
    CASE
        WHEN c.STARTUPDATE>SYSDATE
        THEN 'Pre-Join'
        ELSE 'Open'
    END                                                                                                                                                                                                        AS status,
    a.NAME                                                                                                                                                                                                        AS Area,
    DECODE(a.NAME,'Justin Way',1,'Graeme Penny',2,'Jake Rostron',3,'Matt Buckley',4,'Johanna Brogan',5,'Matt Tomlinson',6,'Naj Chekara',7,'Malcom Armstrong',8,'Barry Ashby',9,'Andrew Ingham',10,'John Maddox',11,'Jacqui Pope',12) AS "Region Number",
    COUNT(*)
FROM
    PUREGYM.SUBSCRIPTIONS s
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
    AND pr.GLOBALID = 'DAY_PASS_90_DAY'
JOIN
    PUREGYM.CENTERS c
ON
    c.id = s.center
JOIN
    AREA_CENTERS AC
ON
    C.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    AND A.PARENT = 61
WHERE
   s.START_DATE <= s.END_DATE
and s.state in (2,4)
    AND s.center IN ($$scope$$)

GROUP BY
    grouping sets ( (c.NAME,c.id,
    CASE
        WHEN c.STARTUPDATE>SYSDATE
        THEN 'Pre-Join'
        ELSE 'Open'
    END,A.NAME), () )