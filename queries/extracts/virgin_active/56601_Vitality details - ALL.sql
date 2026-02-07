 SELECT
	per.status,
     per.center||'p'||per.id "Member ID",
	 per.external_id,
     sub.center||'ss'||sub.id  "Subscription",
     prd.name,
     sub.start_date "Subscription start date",
	 sub.end_date "Subscription end date",
         LookupEntityId.TXTVALUE as EntityNo,
     activation_result_type.txtvalue "Activation result type",
     lookup_result_type.txtvalue "Lookup result tpe",
         compa.center||'p'||compa.id||'rpt'||compa.SUBID as Companyagreement,
         Compa.Name as PlanType
 FROM
     persons per
 LEFT JOIN
     person_ext_attrs activation_result_type
         ON per.id = activation_result_type.personid
         AND per.center = activation_result_type.personcenter
         AND activation_result_type.name='_eClub_PBActivationResultType'
 LEFT JOIN
     person_ext_attrs lookup_result_type
         ON per.id = lookup_result_type.personid
         AND per.center = lookup_result_type.personcenter
         AND lookup_result_type.name='_eClub_PBLookupResultType'

 JOIN
     subscriptions sub
         ON sub.owner_center=per.center
         AND sub.owner_id=per.id
 JOIN
     products prd
         ON sub.SUBSCRIPTIONTYPE_CENTER = prd.center
         AND sub.SUBSCRIPTIONTYPE_ID = prd.id
                 JOIN
                         CENTERS C
                         ON per.center = C.id
                 JOIN --Family relation / Friend
                         RELATIVES R
                                 ON
                                         r.CENTER = per.CENTER
                                         AND r.id = per.ID
                                         AND r.RTYPE IN (4,1,3)
                                         AND r.STATUS =1
                 JOIN
             COMPANYAGREEMENTS compa
         ON
             compa.CENTER = r.RELATIVECENTER
             AND compa.ID = r.RELATIVEID
             AND compa.SUBID = r.RELATIVESUBID
             AND r.RTYPE = 3
                 JOIN
                         PERSON_EXT_ATTRS LookupEntityId
                 ON
                         per.CENTER = LookupEntityId.PERSONCENTER
                         AND per.ID = LookupEntityId.PERSONID
                         AND LookupEntityId.NAME = '_eClub_PBLookupPartnerPersonId'
 WHERE
 LookupEntityId.TXTVALUE = '1253087611' --ENTITY NO
	--AND
		--prd.globalid = 'OP005' --ONLINE VITALITY SUB ONLY
  --AND 
	--per.id=3655 --EXTERNAL ID
  --AND 
  --per.center=999 --CLUB ID
-- AND
	-- per.status = 1
--AND
      --sub.start_date BETWEEN to_date('18-01-2021','dd-mm-yyyy') AND to_date('20-01-2022','dd-mm-yyyy')


 ORDER BY
         sub.start_date desc
