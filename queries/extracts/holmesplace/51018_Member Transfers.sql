-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
		p.center || 'p' || p.id AS PersonId,
		p.EXTERNAL_ID,
 		c.Shortname        AS "Club",
     	c.Id          AS "Center ID",
     	p.FULLNAME,
     
     email.TXTVALUE      AS "email",
      
     
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

CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'JOINER'
        WHEN 2 THEN 'LEAVER'
        WHEN 3 THEN 'JOINER'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'LEAVER'
        WHEN 8 THEN 'LEAVER'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "JOINER/LEAVER",
MEMTRANS.TXTVALUE AS "MemberTransfer"

 
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
     PERSON_EXT_ATTRS MEMTRANS
 ON
     p.center=MEMTRANS.PERSONCENTER
     AND p.id=MEMTRANS.PERSONID
     AND MEMTRANS.name='MEMBERTRANSFER'
 LEFT JOIN
     PERSON_EXT_ATTRS OSD
 ON
     p.center=OSD.PERSONCENTER
     AND p.id=OSD.PERSONID
     AND OSD.name='OriginalStartDate'


where p.center in(:scope)AND p.status in (1,2,3,7,8) 
AND (MEMTRANS.TXTVALUE >= :TransferFrom
AND MEMTRANS.TXTVALUE <= :TransTo)


