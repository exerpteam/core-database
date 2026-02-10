-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     c.ID                    clubId,
     c.SHORTNAME             club,
     p.CENTER || 'p' || p.ID PersonID,
     p.External_ID,
     p.FIRSTNAME,
     p.LASTNAME,
     p.Sex,
     TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                                                                                                                                                STARTDATE,
     TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD')                                                                                                                                                 DOB,
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS STATUS,
     cag.EXTERNAL_ID                                                                                                                                                                    PlanID,
     LegacyMemberId.TXTVALUE "Old MemberId",
     prod.NAME                              AS Subscription,
     LookupEntityId.TXTVALUE                LookupEntityId,
     LookupAuthCode.TXTVALUE                LookupAuthorizationCode,
     LookupAuthCodeOverride.TXTVALUE        LookupAuthCodeOverride,
     LookupEligibleBenefitId.TXTVALUE       LookupEligibleBenefitId,
     LookupPartnerErrorCode.TXTVALUE        LookupPartnerErrorCode,
     LookupPartnerErrorMessage.TXTVALUE     LookupPartnerErrorMessage,
     LookupResult.TXTVALUE                  LookupResult,
     ActivationAuthCode.TXTVALUE            ActivationAuthCode,
     ActivationAuthCodeOverride.TXTVALUE    ActivationAuthCodeOverride,
     ActivationPartnerErrorCode.TXTVALUE    ActivationPartnerErrorCode,
     ActivationPartnerErrorMessage.TXTVALUE ActivationPartnerErrorMessage,
     ActivationResult.TXTVALUE              ActivationResult,
     pcl0.NEW_VALUE                         AS "changed from",
     pcl.NEW_VALUE                          AS "changed to",
     longtodate(pcl.ENTRY_TIME)             AS "Change Time"
 FROM
     PERSON_CHANGE_LOGS pcl
 JOIN
     PERSON_CHANGE_LOGS pcl0
 ON
     pcl0.id = pcl.PREVIOUS_ENTRY_ID
 JOIN
     PERSON_EXT_ATTRS pea
 ON
     pea.PERSONCENTER = pcl.PERSON_CENTER
     AND pea.PERSONID = pcl.PERSON_ID
     AND pea.NAME = '_eClub_PBLookupPartnerPersonId'
     AND pea.TXTVALUE IS NULL
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = pcl.PERSON_CENTER
     AND s.OWNER_ID = pcl.PERSON_ID
     AND s.STATE IN (2,4)
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
 ON
     ppgl.PRODUCT_CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND ppgl.PRODUCT_ID = s.SUBSCRIPTIONTYPE_ID
     AND ppgl.PRODUCT_GROUP_ID IN (247,268)
 JOIN
     PERSONS p
 ON
     p.center = pcl.PERSON_CENTER
     AND p.id = pcl.PERSON_ID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
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
 WHERE
     pcl.CHANGE_ATTRIBUTE = '_eClub_PBLookupPartnerPersonId'
     AND pcl.NEW_VALUE IS NULL
