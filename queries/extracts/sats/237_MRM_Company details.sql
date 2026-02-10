-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 ca.center as companycenter,
 ca.id as companyid,
 ca.subid as agreementid,
 c.lastname as company,
 ca.name as agreement,
 c.zipcode as ZipCode,
 /*ca.SPONSOR_TYPE as SponsorType,
 ca.SPONSOR_AMOUNT as SponsorAmount,
 ca.SPONSOR_PERCENTAGE as SponsorPercent,*/
 ext.TXTVALUE as Commment,
 mc.LASTNAME as MotherCompany
 FROM
         COMPANYAGREEMENTS ca,
         PERSONS c
         LEFT JOIN PERSON_EXT_ATTRS ext ON
                              c.CENTER = ext.PERSONCENTER AND
                              c.ID = ext.PERSONID  AND
                             ext.NAME = '_eClub_Comment'
         LEFT JOIN
                             RELATIVES rel ON
                             rel.RELATIVECENTER = c.CENTER AND
                             rel.RELATIVEID = c.ID
         LEFT JOIN
                 PERSONS mc ON
                 mc.CENTER = rel.CENTER AND
                 mc.ID = rel.ID
  WHERE
     ca.CENTER = c.CENTER AND
     ca.ID = c.ID AND
     c.SEX = 'C' AND
       (rel.RTYPE IS NULL OR rel.RTYPE = 6)
 ORDER BY  ca.center, ca.id, ca.subid
