-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     c.ID AS "CLUBID",
     c.SHORTNAME AS "CLUB",
     p.CENTER || 'p' || p.ID AS "PERSONID",
         p.External_ID AS "EXTERNAL_ID",
     p.FIRSTNAME AS "FIRSTNAME",
     p.LASTNAME AS "LASTNAME",
         p.Sex AS "SEX",
         CASE  p.PersonType  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'One Man Corporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior' WHEN 8 THEN  'Guest'  ELSE 'UNKNOWN' END AS "PERSONTYPE",
         TO_CHAR(s.START_DATE, 'YYYY-MM-DD') AS "STARTDATE",
     TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD') AS "DOB",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "STATUS",
         cag.EXTERNAL_ID AS "PLANID",
         LegacyMemberId.TXTVALUE "Old MemberId",
         prod.NAME "Subscription",
     LookupEntityId.TXTVALUE AS "LOOKUPENTITYID",
     LookupAuthCode.TXTVALUE AS "LOOKUPAUTHORIZATIONCODE",
     LookupAuthCodeOverride.TXTVALUE AS "LOOKUPAUTHCODEOVERRIDE",
     LookupEligibleBenefitId.TXTVALUE AS "LOOKUPELIGIBLEBENEFITID",
     LookupPartnerErrorCode.TXTVALUE AS "LOOKUPPARTNERERRORCODE",
     LookupPartnerErrorMessage.TXTVALUE AS "LOOKUPPARTNERERRORMESSAGE",
         LookupResult.TXTVALUE AS "LOOKUPRESULTS",
     ActivationAuthCode.TXTVALUE AS "ACTIVATIONAUTHCODE",
     ActivationAuthCodeOverride.TXTVALUE AS "ACTIVATIONAUTHCODEOVERRIDE",
     ActivationPartnerErrorCode.TXTVALUE AS "ACTIVATIONPARTNERERRORCODE",
     ActivationPartnerErrorMessage.TXTVALUE AS "ACTIVATIONPARTNERERRORMESSAGE",
         ActivationResult.TXTVALUE AS "ACTIVATIONRESULT",
         comp.FullName AS "LINKEDCORPORATE",
         EarliestStartDate.TXTVALUE AS "EARLIESTSTARTDATE",
         LatestStartDate.TXTVALUE AS "LATESTSTARTDATE",
         sp.TXTVALUE AS "BRANCHENTITYID"
 FROM
     PERSONS p
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER and c.country = 'GB'
 JOIN
     RELATIVES comp_rel
 ON
     comp_rel.center = p.center
     AND comp_rel.id = p.id
     AND comp_rel.RTYPE = 3
     AND comp_rel.STATUS < 3
 JOIN
     COMPANYAGREEMENTS cag
 ON
     cag.center= comp_rel.RELATIVECENTER
     AND cag.id=comp_rel.RELATIVEID
     AND cag.subid = comp_rel.RELATIVESUBID
 JOIN
     persons comp
 ON
     comp.center = cag.center
     AND comp.id=cag.id
 LEFT JOIN
         SUBSCRIPTIONS s
 ON
         s.OWNER_CENTER = p.CENTER
         AND s.OWNER_ID = p.id
         AND s.STATE IN (2)
 LEFT JOIN
         PRODUCTS prod
 ON
         prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
         AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PERSON_EXT_ATTRS LookupEntityId
 ON
     p.center = LookupEntityId.PERSONCENTER
     AND p.id = LookupEntityId.PERSONID
     AND LookupEntityId.name = '_eClub_PBLookupPartnerPersonId'
 LEFT JOIN
     PERSON_EXT_ATTRS ActivationAuthCode
 ON
     p.center = ActivationAuthCode.PERSONCENTER
     AND p.id = ActivationAuthCode.PERSONID
     AND ActivationAuthCode.name = '_eClub_PBActivationAuthorizationCode'
 LEFT JOIN
     PERSON_EXT_ATTRS ActivationAuthCodeOverride
 ON
     p.center = ActivationAuthCodeOverride.PERSONCENTER
     AND p.id = ActivationAuthCodeOverride.PERSONID
     AND ActivationAuthCodeOverride.name = '_eClub_PBActivationAuthorizationCodeOverride'
 LEFT JOIN
     PERSON_EXT_ATTRS ActivationPartnerErrorCode
 ON
     p.center = ActivationPartnerErrorCode.PERSONCENTER
     AND p.id = ActivationPartnerErrorCode.PERSONID
     AND ActivationPartnerErrorCode.name = '_eClub_PBActivationPartnerErrorCode'
 LEFT JOIN
     PERSON_EXT_ATTRS ActivationPartnerErrorMessage
 ON
     p.center = ActivationPartnerErrorMessage.PERSONCENTER
     AND p.id = ActivationPartnerErrorMessage.PERSONID
     AND ActivationPartnerErrorMessage.name = '_eClub_PBActivationPartnerErrorMessage'
 LEFT JOIN
     PERSON_EXT_ATTRS LookupAuthCode
 ON
     p.center = LookupAuthCode.PERSONCENTER
     AND p.id = LookupAuthCode.PERSONID
     AND LookupAuthCode.name = '_eClub_PBLookupAuthorizationCode'
 LEFT JOIN
     PERSON_EXT_ATTRS LookupAuthCodeOverride
 ON
     p.center = LookupAuthCodeOverride.PERSONCENTER
     AND p.id = LookupAuthCodeOverride.PERSONID
     AND LookupAuthCodeOverride.name = '_eClub_PBLookupAuthorizationCodeOverride'
 LEFT JOIN
     PERSON_EXT_ATTRS LookupEligibleBenefitId
 ON
     p.center = LookupEligibleBenefitId.PERSONCENTER
     AND p.id = LookupEligibleBenefitId.PERSONID
     AND LookupEligibleBenefitId.name = '_eClub_PBLookupEligibleBenefitId'
 LEFT JOIN
     PERSON_EXT_ATTRS LookupPartnerErrorCode
 ON
     p.center = LookupPartnerErrorCode.PERSONCENTER
     AND p.id = LookupPartnerErrorCode.PERSONID
     AND LookupPartnerErrorCode.name = '_eClub_PBLookupPartnerErrorCode'
 LEFT JOIN
     PERSON_EXT_ATTRS LookupPartnerErrorMessage
 ON
     p.center = LookupPartnerErrorMessage.PERSONCENTER
     AND p.id = LookupPartnerErrorMessage.PERSONID
     AND LookupPartnerErrorMessage.name = '_eClub_PBLookupPartnerErrorMessage'
 LEFT JOIN
         PERSON_EXT_ATTRS LegacyMemberId
         ON
             LegacyMemberId.PERSONCENTER = p.CENTER
             AND LegacyMemberId.PERSONID = p.ID
             AND LegacyMemberId.NAME = '_eClub_OldSystemPersonId'
 LEFT JOIN
         PERSON_EXT_ATTRS LookupResult
         ON
             LookupResult.PERSONCENTER = p.CENTER
             AND LookupResult.PERSONID = p.ID
             AND LookupResult.NAME = '_eClub_PBLookupResultType'
 LEFT JOIN
         PERSON_EXT_ATTRS ActivationResult
         ON
             ActivationResult.PERSONCENTER = p.CENTER
             AND ActivationResult.PERSONID = p.ID
             AND ActivationResult.NAME = '_eClub_PBActivationResultType'
 LEFT JOIN
         PERSON_EXT_ATTRS EarliestStartDate
         ON
             EarliestStartDate.PERSONCENTER = p.CENTER
             AND EarliestStartDate.PERSONID = p.ID
             AND EarliestStartDate.NAME = '_eClub_PBLookupEarliestStartDate'
 LEFT JOIN
         PERSON_EXT_ATTRS LatestStartDate
         ON
             LatestStartDate.PERSONCENTER = p.CENTER
             AND LatestStartDate.PERSONID = p.ID
             AND LatestStartDate.NAME = '_eClub_PBLookupLatestStartDate'
 LEFT JOIN
         SYSTEMPROPERTIES sp
                 ON
                         sp.SCOPE_ID = c.ID
                         AND sp.SCOPE_TYPE = 'C'
                         AND sp.GLOBALID = 'PruhealthBranchEntityNo'
 WHERE
     comp.center = 4
     AND comp.ID = 674
     --AND p.STATUS IN (1,3)
