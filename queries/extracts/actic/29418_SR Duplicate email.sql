SELECT
    COUNT(p.center),
	pea_mobile.txtvalue AS Mobile

FROM
    persons p
	
LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = p.center
	AND pea_mobile.PERSONID = p.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'

WHERE
p.center IN (:Scope)
    p.status NOT IN (4,5,7)
    AND p.sex != 'C'
AND p.ssn IS NULL    
AND p.center BETWEEN 0 AND 999
GROUP BY
	pea_mobile.txtvalue
HAVING
    COUNT(p.center) > 1