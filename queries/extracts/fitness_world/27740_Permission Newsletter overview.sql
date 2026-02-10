-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER,
	c.shortname,
    SUM(DECODE(p.STATUS,1,1,3,1,0)) AS "Active accepting newsletter",
    SUM(DECODE(p.STATUS,2,1,0))     AS "Inactive accepting newsletter"
FROM
    FW.PERSONS p
join centers c on c.id = p.center
JOIN
    FW.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.CENTER
    AND pea.PERSONID = p.id
    AND pea.name = 'eClubIsAcceptingEmailNewsLetters'
    AND pea.TXTVALUE = 'true'
WHERE
    p.STATUS IN (1,2,3)
    AND p.center IN ($$scope$$)
GROUP BY
    p.center,
c.shortname