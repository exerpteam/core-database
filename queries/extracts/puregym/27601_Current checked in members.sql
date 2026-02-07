SELECT
    c.id,
    COUNT(ch.ID) AS checked_in
FROM
    centers c
LEFT JOIN
    PUREGYM.CHECKINS ch
ON
    ch.CHECKIN_CENTER = c.id
JOIN
    PUREGYM.PERSONS p
ON
    p.center = ch.PERSON_CENTER
    AND p.id = ch.PERSON_ID
WHERE
    ch.CHECKED_OUT = 0
    AND p.PERSONTYPE != 2
    AND ch.CHECKIN_CENTER IN ($$scope$$)
GROUP BY
    c.id