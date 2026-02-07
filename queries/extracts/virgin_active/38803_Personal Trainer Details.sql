 SELECT
     p.FULLNAME                                                                                                                                                                           AS "Full Name",
     s.center||'ss'||s.id                                                                                                                                                                 AS "Subscription ID",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END      AS "Person Status",
     TO_CHAR(p.BIRTHDATE,'DD/MM/YYYY')                                                                                                                                                    AS "Birthday",
     p.SSN                                                                                                                                                                                AS "SSN",
     vat.TXTVALUE                                                                                                                                                                         AS "VAT Number",
     c.NAME                                                                                                                                                                               AS "Club",
     s.SUBSCRIPTION_PRICE                                                                                                                                                                 AS "Price",
     to_char(s.START_DATE,'DD/MM/YYYY')                                                                                                                                                   AS "Start Date",
     to_char(s.END_DATE,'DD/MM/YYYY')                                                                                                                                                     AS "Stop Date",
     CASE WHEN pa.STATE <> 4 THEN
       null
     WHEN pcg.INTERVAL_TYPE = 2 THEN
       to_char(Last_Day(trunc(current_timestamp))+pcg.DEDUCTION_DATE,'DD/MM/YYYY')
     ELSE
       'Unknown'
     END AS "Date of Next Payment",
     ssp.SUBSCRIPTION_PRICE+ssp.ADDONS_PRICE AS "Previous Month Deduction",
     payer.FULLNAME AS "Name Other Payer",
     CASE  WHEN payer.CENTER is null THEN '' ELSE payer.CENTER||'p'||payer.ID END AS "ID Other Payer",
         ar_payer.balance  AS  "Account Balance's Other Payer",
     to_char(s.BINDING_END_DATE,'DD/MM/YYYY')   AS "Binding Exp"
 FROM
     persons p
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.center
     AND s.OWNER_ID = p.id
 JOIN
     PRODUCTS  pr
 ON
     s.SUBSCRIPTIONTYPE_CENTER = pr.center
     AND s.SUBSCRIPTIONTYPE_ID = pr.id
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK ppl
 ON
     ppl.PRODUCT_CENTER = pr.CENTER
     AND ppl.PRODUCT_ID = pr.ID
     AND ppl.PRODUCT_GROUP_ID = 12601 -- only in "Fatture PT"
 LEFT JOIN
     SUBSCRIPTIONPERIODPARTS ssp
 ON
    s.CENTER = ssp.CENTER
    AND s.ID = ssp.ID
    AND ssp.TO_DATE = Last_Day(add_months(trunc(current_timestamp),-1))
    AND ssp.SPP_STATE = 1 -- only active
 LEFT JOIN
    ACCOUNT_RECEIVABLES ar
 ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4 -- payment account
 LEFT JOIN
    PAYMENT_AGREEMENTS pa
 ON
    pa.CENTER = ar.CENTER
    AND pa.ID = ar.ID
    AND pa.ACTIVE = 1 -- only active payment aggrements
 JOIN
    PAYMENT_CYCLE_CONFIG pcg
 ON
    pcg.ID = pa.PAYMENT_CYCLE_CONFIG_ID
 JOIN
    CENTERS c
 ON
     c.id = p.center
 LEFT JOIN
    PERSON_EXT_ATTRS vat
 ON
    p.center= vat.PERSONCENTER
    AND p.id= vat.PERSONID
    AND vat.name IN('_eClub_Comment')
 LEFT JOIN
    RELATIVES r
 ON
    r.RTYPE = 12 -- other payer
    AND r.RELATIVECENTER = p.CENTER
    AND r.RELATIVEID = p.ID
    AND r.STATUS = 1 -- Active
 LEFT JOIN
    PERSONS payer
 ON
    r.CENTER = payer.CENTER
    AND r.ID = payer.ID
 LEFT JOIN
    ACCOUNT_RECEIVABLES ar_payer
 ON
    ar_payer.CUSTOMERCENTER = payer.CENTER
    AND ar_payer.CUSTOMERID = payer.ID
    AND ar_payer.AR_TYPE = 4 -- payment account
 WHERE
    p.PERSONTYPE = 2
    AND s.START_DATE >= $$Subcription_Start_From$$
    AND s.START_DATE <= $$Subcription_Start_To$$
    AND s.STATE = 2
