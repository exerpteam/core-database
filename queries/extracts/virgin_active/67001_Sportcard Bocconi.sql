SELECT
     p.center||'p'||p.id       AS "Person ID",
     to_char(to_date(Sportcard.TXTVALUE, 'YYYY-MM-DD'),'dd/mm/yyyy') AS "Sportcard Bocconi"
FROM
     PERSONS p
JOIN
     CENTERS cn
ON
     cn.ID = p.CENTER
         AND cn.Country = 'IT'
LEFT JOIN
     PERSON_EXT_ATTRS Sportcard
ON
     p.center=Sportcard.PERSONCENTER
     AND p.id=Sportcard.PERSONID
     AND (Sportcard.name = 'SPORTCARDBOCCONI'
	 OR Sportcard.name = 'SPORTCARDBOCCONIDIAZ')
 
WHERE
     Sportcard.TXTVALUE IS NOT null
	 AND p.CENTER IN ($$Scope$$)