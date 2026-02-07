SELECT
		p.center || 'p' || p.id AS PersonId,
		p.EXTERNAL_ID,
     p.FIRSTNAME,
     p.LASTNAME,
     c.Shortname        AS "Club",
     c.Id          AS "Center ID",
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
	BS.TXTVALUE AS "BS AMOUNT",
BS25.TXTVALUE AS "BS 25",
BS29.TXTVALUE AS "BS 29",
BS2990.TXTVALUE AS "BS 2990"


 
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
     PERSON_EXT_ATTRS BS
 ON
     p.center=BS.PERSONCENTER
     AND p.id=BS.PERSONID
     AND BS.name='CHARGEBSDE'

LEFT JOIN
     PERSON_EXT_ATTRS BS25
 ON
     p.center=BS25.PERSONCENTER
     AND p.id=BS25.PERSONID
     AND BS25.name='CHARGEBODYSCANFEE'
 LEFT JOIN
     PERSON_EXT_ATTRS BS29
 ON
     p.center=BS29.PERSONCENTER
     AND p.id=BS29.PERSONID
     AND BS29.name='CHARGEBODYSCANFEE29'
 LEFT JOIN
     PERSON_EXT_ATTRS BS2990
 ON
     p.center=BS2990.PERSONCENTER
     AND p.id=BS2990.PERSONID
     AND BS2990.name='CHARGEBODYSCANFEE2990'

 
 

where p.center in(:scope)AND p.status in (:status)


