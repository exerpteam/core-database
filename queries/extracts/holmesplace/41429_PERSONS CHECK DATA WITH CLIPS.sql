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
             p.STATUS NOT IN (4,5,7,8)--Not Transferred Dup Deleted or anonymized

			AND p.persontype NOT IN (2)
             AND c.COUNTRY IN ('DE','AT','CH')
			AND p.CENTER IN (:Scope)
     )
     
 SELECT DISTINCT
	 p.center||'p'||p.id AS MemberID,
     p.EXTERNAL_ID,
	 p.centerName        AS "Center",
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
aggregator.TXTVALUE
AS "Aggregator Name",	
     p.FIRSTNAME,
     p.LASTNAME,
     email.TXTVALUE      AS email,
     mobile.TXTVALUE AS "MobiPhone",
     home.TXTVALUE   AS "HomePhone",
     p.ADDRESS1,
     p.ZIPCODE,
     p.CITY,
     p.COUNTRY,
     p.BIRTHDATE,
     p.SEX,   
    
  staff.TXTVALUE                                                                                                                                                                  AS "Sales Staff",
 staff2.fullname                                                                                                                                                                 AS "Sales Name",
   allow_Email.TXTVALUE                                                                                                                                                    AS allow_Email,
   allow_SMS.TXTVALUE                                                                                                                                                         AS allow_SMS,
   allow_Phone_Call.TXTVALUE                                                                                                                                                       AS allow_Phone_Call,
   allow_Letter.TXTVALUE                                                                                                                                                     AS allow_Letter,
   OPTIN.TXTVALUE                                                                                                                                                              AS "OPTIN",
   OPTIN_Date.TXTVALUE                                                                                                                                                          AS "OPTIN_Date",
   DOI.TXTVALUE                                                                                                                                                        AS "DOI",
   DOI_Date.TXTVALUE                                                                                                                                                    AS "DOI_Date",
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
cd.TXTVALUE
AS "create date",
egid.TXTVALUE AS "EgymId",
CASE WHEN
c.clips_left >0 THEN c.clips_left
ELSE '0'
END AS  "ClipsLeft",
pr.name AS "ClipName"
                                                                                 



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
     PERSON_EXT_ATTRS allow_SMS
 ON
     p.center=allow_SMS.PERSONCENTER
     AND p.id=allow_SMS.PERSONID
     AND allow_SMS.name='_eClub_AllowedChannelSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Phone_Call
 ON
     p.center=allow_Phone_Call.PERSONCENTER
     AND p.id=allow_Phone_Call.PERSONID
     AND allow_Phone_Call.name='_eClub_AllowedChannelPhone'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Letter
 ON
     p.center=allow_Letter.PERSONCENTER
     AND p.id=allow_Letter.PERSONID
     AND allow_Letter.name='_eClub_AllowedChannelLetter'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Email
 ON
     p.center=allow_Email.PERSONCENTER
     AND p.id=allow_Email.PERSONID
     AND allow_Email.name='_eClub_AllowedChannelEmail'
 LEFT JOIN
     PERSON_EXT_ATTRS NEWSL
 ON
     p.center = NEWSL.PERSONCENTER
     AND p.id = NEWSL.PERSONID
     AND NEWSL.Name = '_eClub_IsAcceptingEmailNewsLetters'
 
 
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
     PERSON_EXT_ATTRS OPTIN
 ON
     p.center=OPTIN.PERSONCENTER
     AND p.id=OPTIN.PERSONID
     AND OPTIN.name='GDPROPTIN'
 LEFT JOIN
     PERSON_EXT_ATTRS OPTIN_Date
 ON
     p.center=OPTIN_Date.PERSONCENTER
     AND p.id=OPTIN_Date.PERSONID
     AND OPTIN_Date.name='GDPROPTINDATE'
 LEFT JOIN
     PERSON_EXT_ATTRS DOI
 ON
     p.center=DOI.PERSONCENTER
     AND p.id=DOI.PERSONID
     AND DOI.name='GDPRDOUBLEOPTIN'
 LEFT JOIN
     PERSON_EXT_ATTRS DOI_Date
 ON
     p.center=DOI_Date.PERSONCENTER
     AND p.id=DOI_Date.PERSONID
     AND DOI_Date.name='GDPRDOUBLEOPTINdate'

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

LEFT JOIN			
                PERSON_EXT_ATTRS egid			
                ON			
                   p.center = egid.PERSONCENTER			
                AND p.id = egid.PERSONID 			
                AND egid.name = 'EGYMID'	
LEFT JOIN
    clipcards c
ON
    p.center = c.owner_center
AND p.id = c.owner_id
AND c.finished != true
AND c.blocked = 0
AND c.cancelled =0
JOIN
    products pr
ON
    pr.center = c.center
AND pr.id = c.id
AND pr.ptype = 4
JOIN product_group prg
ON prg.id = pr.PRIMARY_PRODUCT_GROUP_ID


