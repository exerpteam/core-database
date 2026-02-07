SELECT  
        t1.innertxtvalue AS "Email",
		p2.BIRTHDATE AS "Birthdate",
        count(*) AS "Repetitions"
FROM
(
        SELECT
                DISTINCT
                atr.TXTVALUE as innertxtvalue
        FROM PUREGYM.PERSONS P
        JOIN PUREGYM.PERSON_EXT_ATTRS ATR ON p.CENTER = atr.PERSONCENTER AND p.ID = atr.PERSONID AND atr.NAME = '_eClub_Email' AND atr.TXTVALUE IS NOT NULL
        WHERE
                p.STATUS NOT IN (4,5,7,8)
                AND p.PERSONTYPE NOT IN (2,8)
				AND p.BIRTHDATE IS NOT NULL
                AND p.CENTER IN (:Scope)
				AND atr.TXTVALUE NOT IN ('noemail@puregym.com','lead@puregym.com','deleted@puregym.com','blank@puregym.com','prospect@puregym.com')
) t1
JOIN PUREGYM.PERSON_EXT_ATTRS ATR2 ON  atr2.NAME = '_eClub_Email' AND atr2.TXTVALUE = t1.innertxtvalue
JOIN PERSONS p2 ON p2.CENTER = atr2.PERSONCENTER AND p2.ID = atr2.PERSONID
WHERE 
        p2.BIRTHDATE IS NOT NULL
GROUP BY
        t1.innertxtvalue, p2.BIRTHDATE
HAVING COUNT (*) > 1