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
COMPENSATION.TXTVALUE AS "AprMay20 Chosen",
COMPENSATIONGIVEN.TXTVALUE AS "AprMay20 Given",
COMPENSATION2.TXTVALUE AS "Nov20 Chosen",
COMPENSATIONGIVEN2.TXTVALUE AS "Nov20 Given",
COMPENSATION3.TXTVALUE AS "Dec20 Chosen",
COMPENSATIONGIVEN3.TXTVALUE AS "Dec20 Given",
COMPENSATION4.TXTVALUE AS "Jan-May21 Chosen",
COMPENSATIONGIVEN4.TXTVALUE AS "Jan21 Given",
COMPENSATIONGIVEN5.TXTVALUE AS "Feb21 Given",
COMPENSATIONGIVEN6.TXTVALUE AS "Mar21 Given",
COMPENSATIONGIVEN7.TXTVALUE AS "Apr21 Given",
COMPENSATIONGIVEN8.TXTVALUE AS "May21 Given",
CORONACOMP.TXTVALUE AS "WebshopComp"
 
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
     PERSON_EXT_ATTRS COMPENSATION
 ON
     p.center=compensation.PERSONCENTER
     AND p.id=compensation.PERSONID
     AND compensation.name='COMPENSATION'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATION2
 ON
     p.center=compensation2.PERSONCENTER
     AND p.id=compensation2.PERSONID
     AND compensation2.name='COMPENSATION2'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATION3
 ON
     p.center=compensation3.PERSONCENTER
     AND p.id=compensation3.PERSONID
     AND compensation3.name='COMPENSATION3'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATION4
 ON
     p.center=compensation4.PERSONCENTER
     AND p.id=compensation4.PERSONID
     AND compensation4.name='COMPENSATION4'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN
 ON
     p.center=compensationgiven.PERSONCENTER
     AND p.id=compensationgiven.PERSONID
     AND compensationgiven.name='COMPENSATIONGIVEN'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN2
 ON
     p.center=compensationgiven2.PERSONCENTER
     AND p.id=compensationgiven2.PERSONID
     AND compensationgiven2.name='COMPENSATIONGIVEN2'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN3
 ON
     p.center = compensationgiven3.PERSONCENTER
     AND p.id = compensationgiven3.PERSONID
     AND compensationgiven3.name = 'COMPENSATIONGIVEN3'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN4
 ON
     p.center = compensationgiven4.PERSONCENTER
     AND p.id = compensationgiven4.PERSONID
     AND compensationgiven4.name = 'COMPENSATIONGIVEN4'
 
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN5
 ON
     p.center=compensationgiven5.PERSONCENTER
     AND p.id=compensationgiven5.PERSONID
     AND compensationgiven5.name='COMPENSATIONGIVEN5'
 
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN6
 ON
     p.center=compensationgiven6.PERSONCENTER
     AND p.id=compensationgiven6.PERSONID
     AND compensationgiven6.name='COMPENSATIONGIVEN6'

 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN7
  ON
     p.center=compensationgiven7.PERSONCENTER
     AND p.id=compensationgiven7.PERSONID
     AND compensationgiven7.name='COMPENSATIONGIVEN7'
 LEFT JOIN
     PERSON_EXT_ATTRS COMPENSATIONGIVEN8
 ON
     p.center=compensationgiven8.PERSONCENTER
     AND p.id=compensationgiven8.PERSONID
     AND compensationgiven8.name='COMPENSATIONGIVEN8'
 
LEFT JOIN
     PERSON_EXT_ATTRS CORONACOMP
 ON
     p.center=CORONACOMP.PERSONCENTER
     AND p.id=CORONACOMP.PERSONID
     AND CORONACOMP.name='CORONACOMP'

where p.center in(:scope)AND p.status in (:status)

