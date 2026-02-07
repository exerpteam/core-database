 SELECT DISTINCT
     c.NAME Club,
     p.CENTER || 'p' || p.ID "Membership Number",
     s.CENTER || 'ss' || s.ID "Subscription ID",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS STATUS,
     op.FULLNAME                                                                                                                                                                        payer_name,
     CASE WHEN op.CENTER IS NOT NULL THEN  op.CENTER || 'p' || op.ID ELSE  NULL END "Payer ID",
     p.FIRSTNAME,
     p.LASTNAME,
     ROUND(months_between(CURRENT_TIMESTAMP,p.BIRTHDATE)/12) age,
     s.BINDING_END_DATE,
     pg.NAME   product_group_name,
     prod.NAME subscription_name,
     CASE
         WHEN op.fullname IS NOT NULL
         THEN cc2.AMOUNT
         ELSE cc.AMOUNT
     END AS debt_case_amount,
     CASE
         WHEN op.fullname IS NOT NULL
         THEN cc2.STARTDATE
         ELSE cc.STARTDATE
     END      AS debt_case_start_date,
     sp.PRICE    subscription_price,
     p.ADDRESS1,
     p.ADDRESS2,
     p.ADDRESS3,
     p.ZIPCODE,
     p.CITY,
     CASE WHEN invl.SPONSOR_INVOICE_SUBID IS NOT NULL THEN 1 ELSE 0 END funded,
     email.TXTVALUE                       email,
     CASE WHEN comp.center IS NOT NULL THEN  comp.fullname ELSE  null END AS "Company Name",
     CASE WHEN comp.center IS NOT NULL THEN  comp.center||'p'||comp.id  ELSE  null END AS "Company Id",
     CASE WHEN ca.center IS NOT NULL THEN  ca.name ELSE  null END AS "Company Agreement Name",
     CASE WHEN ca.center IS NOT NULL THEN  ca.center||'p'||ca.id||'rpt'||ca.subid ELSE  null END AS "Company Agreement Id",
     privg.sponsorship_name AS "Sponsorship",
     CASE
        WHEN privg.sponsorship_name = 'PERCENTAGE' THEN
            privg.sponsorship_amount*100 || '%'
        ELSE
            privg.sponsorship_amount || ''
     END AS "Sponsorship Amount",
     TO_CHAR(car.expiredate, 'dd-MM-yyyy') AS "Document Expire Date"
 FROM
     SUBSCRIPTIONS s
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PRODUCT_GROUP pg
 ON
     pg.id = prod.PRIMARY_PRODUCT_GROUP_ID
 LEFT JOIN
     SUBSCRIPTION_PRICE sp
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.ID
     AND sp.FROM_DATE <= CURRENT_TIMESTAMP
     AND (
         sp.TO_DATE IS NULL
         OR sp.TO_DATE > CURRENT_TIMESTAMP)
     AND sp.APPLIED = 1
     AND sp.CANCELLED = 0
 LEFT JOIN
     RELATIVES rel
 ON
     rel.RTYPE = 12
     AND rel.STATUS = 1
     AND rel.RELATIVECENTER = p.CENTER
     AND rel.RELATIVEID = p.ID
 LEFT JOIN
     PERSONS op
 ON
     op.CENTER = rel.CENTER
     AND op.ID = rel.ID
 LEFT JOIN
     CASHCOLLECTIONCASES cc
 ON
     cc.PERSONCENTER = p.CENTER
     AND cc.PERSONID = p.ID
     AND cc.CLOSED = 0
     AND cc.MISSINGPAYMENT = 1
 LEFT JOIN
     CASHCOLLECTIONCASES cc2
 ON
     cc2.PERSONCENTER = op.CENTER
     AND cc2.PERSONID = op.ID
     AND cc2.CLOSED = 0
     AND cc2.MISSINGPAYMENT = 1
 LEFT JOIN
     SUBSCRIPTIONPERIODPARTS spp
 ON
     spp.CENTER = s.CENTER
     AND spp.ID = s.id
     AND spp.SPP_STATE = 1
     AND s.BILLED_UNTIL_DATE IS NOT NULL
     AND spp.TO_DATE = s.BILLED_UNTIL_DATE
 LEFT JOIN
     SPP_INVOICELINES_LINK link
 ON
     link.PERIOD_CENTER = spp.CENTER
     AND link.PERIOD_ID = spp.ID
     AND link.PERIOD_SUBID = spp.SUBID
 LEFT JOIN
     INVOICELINES invl
 ON
     invl.CENTER = link.INVOICELINE_CENTER
     AND invl.id = link.INVOICELINE_ID
     AND invl.SUBID = link.INVOICELINE_SUBID
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     email.PERSONCENTER = p.CENTER
     AND email.PERSONID = p.ID
     AND email.NAME = '_eClub_Email'
 LEFT JOIN
     RELATIVES car
 ON
     car.RTYPE = 3
     AND car.STATUS < 3
     AND car.CENTER = p.CENTER
     AND car.ID = p.ID
 LEFT JOIN
     COMPANYAGREEMENTS ca
 ON
     ca.center = car.RELATIVECENTER
     AND ca.id = car.RELATIVEID
     AND ca.SUBID = car.RELATIVESUBID
 LEFT JOIN
     persons comp
 ON
     comp.center = ca.center
     AND comp.id=ca.id
 LEFT JOIN
     PRIVILEGE_GRANTS privg
 ON
     privg.GRANTER_SERVICE='CompanyAgreement'
     AND privg.GRANTER_CENTER=ca.center
     AND privg.granter_id=ca.id
     AND privg.GRANTER_SUBID = ca.SUBID
     AND (
         privg.VALID_TO IS NULL
         OR privg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
 WHERE
     s.END_DATE IS NULL
     AND s.BINDING_END_DATE IS NOT NULL
     AND s.BINDING_END_DATE BETWEEN $$fromDate$$ AND $$toDate$$
     AND p.CENTER IN ($$scope$$)
