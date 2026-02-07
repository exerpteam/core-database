 SELECT * FROM 
    (
    select
        CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId,
        p.FULLNAME,
		(CASE  p.persontype  
		WHEN 0 THEN 'Private'  
		WHEN 1 THEN 'Student'  
		WHEN 2 THEN 'Staff'  
		WHEN 3 THEN 'Friend'  
		WHEN 4 THEN 'Corporate'  
		WHEN 5 THEN 'Onemancorporate'  
		WHEN 6 THEN 'Family'  
		WHEN 7 THEN 'Senior'  
		WHEN 8 THEN 'Guest'  
		WHEN 9 THEN  'Child'  
	    WHEN 10 THEN  'External_Staff' 
	    ELSE 'Unknown' END) AS Person_Type,
        p.BIRTHDATE,
        MAX(js.EXPIRATION_DATE) "scadenza",
        e."EMAILADDRESS",
        hp."HOMEPHONE",
        mp."MOBILEPHONE"
	from
        persons P
    LEFT JOIN
        (SELECT
            p.center,
            p.id,
            atts.TXTVALUE "EMAILADDRESS"
        FROM
            PERSON_EXT_ATTRS atts
        JOIN 
            PERSONS pOld
        ON
            pOld.CENTER = atts.PERSONCENTER
            AND pOld.ID = atts.PERSONID
        JOIN PERSONS p
        ON
            p.CENTER = pOld.CURRENT_PERSON_CENTER
            AND p.ID = pOld.CURRENT_PERSON_ID
        LEFT JOIN 
            PERSON_CHANGE_LOGS pcl
        ON
            pcl.PERSON_CENTER = p.CENTER
            AND pcl.PERSON_ID = p.ID
            AND pcl.CHANGE_ATTRIBUTE = 'E_MAIL'
        WHERE
            atts.NAME = '_eClub_Email'
            and p.SEX != 'C'
            and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
        GROUP BY
            p.center,
            p.id,
            atts.TXTVALUE) e
        ON e.ID = P.id AND e.center = p.center
    LEFT JOIN
        (SELECT
            p.center,
            p.id,
            atts.TXTVALUE "HOMEPHONE"
        FROM
            PERSON_EXT_ATTRS atts
        JOIN 
            PERSONS pOld
        ON
            pOld.CENTER = atts.PERSONCENTER
            AND pOld.ID = atts.PERSONID
        JOIN 
            PERSONS p
        ON
            p.CENTER = pOld.CURRENT_PERSON_CENTER
            AND p.ID = pOld.CURRENT_PERSON_ID
        LEFT JOIN 
            PERSON_CHANGE_LOGS pcl
        ON
            pcl.PERSON_CENTER = p.CENTER
            AND pcl.PERSON_ID = p.ID
            AND pcl.CHANGE_ATTRIBUTE = 'HOME_PHONE'
        WHERE
            atts.NAME = '_eClub_PhoneHome'
            and p.SEX != 'C'
            and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
        GROUP BY
            p.center,
            p.id,
            atts.TXTVALUE) hp
        ON hp.ID = P.id AND hp.center = p.center
    LEFT JOIN
        (SELECT
            p.center,
            p.id,
            atts.TXTVALUE "MOBILEPHONE"
        FROM
            PERSON_EXT_ATTRS atts
        JOIN 
            PERSONS pOld
        ON
            pOld.CENTER = atts.PERSONCENTER
            AND pOld.ID = atts.PERSONID
        JOIN 
            PERSONS p
        ON
            p.CENTER = pOld.CURRENT_PERSON_CENTER
            AND p.ID = pOld.CURRENT_PERSON_ID
        LEFT JOIN 
            PERSON_CHANGE_LOGS pcl
        ON
            pcl.PERSON_CENTER = p.CENTER
            AND pcl.PERSON_ID = p.ID
            AND pcl.CHANGE_ATTRIBUTE = 'MOB_PHONE'
        WHERE
            atts.NAME = '_eClub_PhoneSMS'
            and p.SEX != 'C'
            and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
        GROUP BY
            p.center,
            p.id,
            atts.TXTVALUE) mp
        ON mp.ID = P.id AND mp.center = p.center
    LEFT JOIN
        JOURNALENTRIES js
    ON 
        p.ID =  js.PERSON_ID
        AND p.CENTER = js.PERSON_CENTER
    WHERE
        (NAME = 'Certificato medico' or NAME Like 'Health%')
        AND p.STATUS IN(1,3)
        AND p.center in ($$SCOPE$$)
        AND js.EXPIRATION_DATE > ($$start_date$$)
    GROUP BY 
        CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))),
        p.FULLNAME,
		p.persontype,
        e."EMAILADDRESS",
        hp."HOMEPHONE",
        mp."MOBILEPHONE",
        p.BIRTHDATE) ex
    where ex.scadenza <= ($$end_date$$)
