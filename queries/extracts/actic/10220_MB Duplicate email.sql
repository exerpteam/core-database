SELECT
    COUNT(p.center),
	pea_email.txtvalue
FROM
    persons p
	
LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = p.center
	AND pea_email.PERSONID = p.id
	AND pea_email.NAME = '_eClub_Email'

WHERE
p.center IN (:Scope)
   	AND p.status NOT IN (4,5,7)
    AND p.sex != 'C'
    --AND p.ssn IS NOT NULL
    AND p.center BETWEEN 0 AND 9999
GROUP BY
	pea_email.txtvalue
HAVING
    COUNT(p.center) > 1
