SELECT
	 c.Shortname       AS "Club",
	 p.center || 'p' || p.id AS PersonId,
	 p.EXTERNAL_ID,
     p.FULLNAME,
     c.Id               AS "Center ID",
     email.TXTVALUE      AS "email",
    
     CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARY INACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "STATUS",
     
     CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS "PERSONTYPE",
	VACCINEEXPIRY.TXTVALUE AS "Vaccine Expiry Date",
	VACCINETYPE.TXTVALUE AS "Vaccine type",
	VACCINEACCESS.TXTVALUE AS "Vaccine Access"



FROM
             PERSONS p
         JOIN
             CENTERS c
         ON
             c.id = p.CENTER
         
               
LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     p.center=mobile.PERSONCENTER
     AND p.id=mobile.PERSONID
     AND mobile.name='_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS home
 ON
     p.center=home.PERSONCENTER
     AND p.id=home.PERSONID
     AND home.name='_eClub_PhoneHome'

LEFT JOIN
     PERSON_EXT_ATTRS VACCINEEXPIRY
 ON
     p.center=VACCINEEXPIRY.PERSONCENTER
     AND p.id=VACCINEEXPIRY.PERSONID
     AND VACCINEEXPIRY.name='VACCINEEXPIRY'
 LEFT JOIN
     PERSON_EXT_ATTRS VACCINETYPE
 ON
     p.center=VACCINETYPE.PERSONCENTER
     AND p.id=VACCINETYPE.PERSONID
     AND VACCINETYPE.name='VACCINETYPE'
 LEFT JOIN
     PERSON_EXT_ATTRS VACCINEACCESS
 ON
     p.center=VACCINEACCESS.PERSONCENTER
     AND p.id=VACCINEACCESS.PERSONID
     AND VACCINEACCESS.name='VACCINEACCESS'
  

where p.center in(:scope)
AND p.status in (:status)
AND p.status NOT IN (4,5,7,8)
AND VACCINEEXPIRY.TXTVALUE IS NOT NULL

