SELECT
    p.center,c.NAME,count(*)
FROM
    SATS.PERSONS p
JOIN
    SATS.ENTITYIDENTIFIERS e
ON
    e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.IDMETHOD IN (2,4)
    AND e.REF_TYPE = 1 and e.ENTITYSTATUS = 1
    join SATS.CENTERS c on p.CENTER = c.ID
    where p.CENTER in ($$scope$$)
    group by p.center,c.NAME