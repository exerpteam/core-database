-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     p.CENTER || 'p' || p.ID as PersonID,
     cen.NAME as GymName,
     p.FULLNAME,
     en.IDENTITY as PIN,
     p.ADDRESS1,
     p.ADDRESS2,
     p.ADDRESS3,
     p.CITY,
     p.ZIPCODE,
     p.BIRTHDATE,
     ext.TXTVALUE as HomePhone,
     ext2.TXTVALUE as MobilePhone,
     ext3.TXTVALUE as Email,
         p.LAST_ACTIVE_START_DATE as LatestStartDate
 FROM
     PERSONS p
 LEFT JOIN
     PERSON_EXT_ATTRS ext
 ON
     ext.PERSONID = p.ID
 AND ext.PERSONCENTER = p.CENTER
 AND ext.NAME = '_eClub_PhoneHome'
 LEFT JOIN
     PERSON_EXT_ATTRS ext2
     ON
     ext2.PERSONCENTER = p.CENTER
     AND
     ext2.PERSONID = p.ID
     and ext2.NAME = '_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS ext3
 ON
     ext3.PERSONID = p.ID
 AND ext3.PERSONCENTER = p.CENTER
 and ext3.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS ext4
 ON
     ext4.PERSONID = p.ID
 AND ext4.PERSONCENTER = p.CENTER
 and ext4.NAME = 'PIN_ABUSE'
 LEFT JOIN
      ENTITYIDENTIFIERS en
      on
      en.REF_CENTER = p.CENTER
      and en.REF_ID = p.ID
      and en.REF_TYPE = 1
      and en.IDMETHOD = 5
 LEFT JOIN JOURNALENTRIES jo
      on
      P.SUSPENSION_INTERNAL_NOTE = jo.ID
 LEFT JOIN CENTERS cen
      on
      p.CENTER = cen.ID
 where P.STATUS in (1,3)
 and P.BLACKLISTED = 2
 and jo.NAME = 'Suspended'
 and p.CENTER in (:scope)
 and ext4.TXTVALUE is null
 Order by
 p.CENTER
