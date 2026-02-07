-- This is the version from 2026-02-05
--  
   SELECT
		pa.txtvalue AS "LEGACY ID",
        p.center ||'p'|| p.id AS "PERSON KEY",
		p.fullname AS "FULL NAME",
		p.status AS "PERSON STATUS"
		


    FROM
		PERSONS P
LEFT JOIN
        PERSON_EXT_ATTRS pa
    ON
       
         p.CENTER = pa.PERSONCENTER
        AND p.ID = pa.PERSONID
		AND  pa.NAME = '_eClub_OldSystemPersonId'
        WHERE pa.txtvalue IN (:oldid)