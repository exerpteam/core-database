WITH
     Member AS
     (
         SELECT DISTINCT
             p.*,
             c.name AS centerName,
             c.id   AS centerId
         FROM
             PERSONS p
         JOIN
             CENTERS c
         ON
             c.id = p.CENTER
         WHERE
             
			p.status IN (1,2,3,0,6,9)--Active inact temp lead prosp cont
			 AND p.persontype NOT IN (2) --NOT STAFF
             AND c.COUNTRY IN ('DE', 'AT', 'CH')
			AND p.CENTER IN (:Scope)
     )
     
 SELECT DISTINCT
	 p.center||'p'||p.id AS MemberID,
     p.EXTERNAL_ID,
	 p.centername        AS "Club",
     p.centerId          AS "Center ID",
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
	Prod.Name as "Memership",

     p.FIRSTNAME,
     p.LASTNAME,
     email.TXTVALUE      AS email,
     CASE WHEN
	mobile.TXTVALUE IS NULL
	THEN home.TXTVALUE
	ELSE mobile.TXTVALUE
	END AS "Phone",
     p.ADDRESS1,
     p.ZIPCODE,
     p.CITY,
     p.COUNTRY,
     
    
  staff.TXTVALUE                                                                                                                                                                  AS "Sales Staff",
 staff2.fullname                                                                                                                                                                 AS "Sales Name",
   
CASE WHEN
   (p.CENTER, p.ID) NOT IN
(
        SELECT
                pea.PERSONCENTER,
                pea.PERSONID
        FROM PERSON_EXT_ATTRS pea
        WHERE
				pea.PERSONCENTER IN (:Scope)
				AND pea.NAME IN ('_eClub_Picture','_eClub_PictureFace')
                AND pea.mimevalue IS NOT NULL
)

   THEN 'NoPhoto'
   ELSE 'Photo'
END AS Photo,



osd.TXTVALUE AS "JoinDate"



 FROM
     Member p
LEFT JOIN
     PERSON_EXT_ATTRS aggregator
 ON
     p.center=aggregator.PERSONCENTER
     AND p.id=aggregator.PERSONID
     AND aggregator.name='AGGREGATOR'

LEFT JOIN
     PERSON_EXT_ATTRS keepmeid
 ON
     p.center=keepmeid.PERSONCENTER
     AND p.id=keepmeid.PERSONID
     AND keepmeid.name='KEEPMEID'
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
PERSON_EXT_ATTRS photo
 ON
     p.center=photo.PERSONCENTER
     AND p.id=photo.PERSONID
     AND photo.name IN ('_eClub_Picture','_eClub_PictureFace')


 LEFT JOIN
     PERSON_EXT_ATTRS staff
 ON
     p.center=staff.PERSONCENTER
     AND p.id=staff.PERSONID
     AND staff.name='Sales_Staff'
 
 
 LEFT JOIN
     PERSON_EXT_ATTRS assigned_email
 ON
     p.center=assigned_email.PERSONCENTER
     AND p.id=assigned_email.PERSONID
     AND assigned_email.name='_eClub_Email'
 LEFT JOIN
     persons staff2
 ON
     staff2.center||'p'||staff2.id = staff.TXTVALUE
 LEFT JOIN
     PERSON_EXT_ATTRS sales_name
 ON
     staff2.center=sales_name.PERSONCENTER
     AND staff2.id=sales_name.PERSONID
     AND sales_name.name='p.FULLNAME'

 LEFT JOIN
     PERSON_EXT_ATTRS sales_email
 ON
     staff2.center=sales_email.PERSONCENTER
     AND staff2.id=sales_email.PERSONID
     AND sales_email.name='_eClub_Email'
 

LEFT JOIN			
                PERSON_EXT_ATTRS cd			
                ON			
                   p.center = cd.PERSONCENTER			
                AND p.id = cd.PERSONID 			
                AND cd.name = 'CREATION_DATE'	
LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    p.center = osd.PERSONCENTER
    AND p.id = osd.PERSONID
	AND osd.name = 'OriginalStartDate'

JOIN
	SUBSCRIPTIONS subs
ON
	subs.owner_center = p.CENTER 
	AND subs.OWNER_ID = p.id
	
JOIN
SUBSCRIPTIONTYPES subt
ON
subt.center = subs.center
AND subt.id = subs.subscriptiontype_id

LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = subs.SUBSCRIPTIONTYPE_CENTER
    AND prod.id = subs.SUBSCRIPTIONTYPE_ID

LEFT JOIN
       PERSONS cp
        ON
            cp.center = subs.OWNER_CENTER
        AND cp.ID = subs.OWNER_ID

LEFT JOIN			
                PERSON_EXT_ATTRS egid			
                ON			
                   p.center = egid.PERSONCENTER			
                AND p.id = egid.PERSONID 			
                AND egid.name = 'EGYMID'	

LEFT JOIN			
                PERSON_EXT_ATTRS egidch			
                ON			
                   p.center = egidch.PERSONCENTER			
                AND p.id = egidch.PERSONID 			
                AND egidch.name = 'EGYMIDCH'
LEFT JOIN			
                PERSON_EXT_ATTRS egidat			
                ON			
                   p.center = egidat.PERSONCENTER			
                AND p.id = egidat.PERSONID 			
                AND egidat.name = 'EGYMIDAT'		

WHERE

         (p.CENTER, p.ID) NOT IN
(
        SELECT
                pea.PERSONCENTER,
                pea.PERSONID
        FROM PERSON_EXT_ATTRS pea
        WHERE
				pea.PERSONCENTER IN (:Scope)
				AND pea.NAME IN ('_eClub_Picture','_eClub_PictureFace')
                AND pea.mimevalue IS NOT NULL
)
    
	AND subs.state IN (2,4) --active frozen
	AND p.status IN (1,3) --ACTIVE TEMP INACTIVE
	AND p.persontype NOT IN (2) --staff
	AND p.center NOT IN (100)
	
 





