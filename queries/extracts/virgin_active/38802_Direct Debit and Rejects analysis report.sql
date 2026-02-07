 SELECT
   "Full Name",
   "Subscription ID",
   "Person ID",
   "Person Status",
   "Subscription Status",
   "SSN",
   "Club",
   "Email",
   "Mobile Phone",
   "Membership Name",
   "Price",
   "Start Date",
   "Stop Date",
   "Binding Date",
   COALESCE(SUM("Gross Direct Debit"),0)  AS "Gross Direct Debit",
   COALESCE(SUM("Direct Debit Collected"),0) AS "Direct Debit Collected",
   COALESCE(SUM("Gross Direct Debit"),0)+COALESCE(SUM("Direct Debit Collected"),0) AS "Net Direct Debits",
   "Account Balance"
 FROM
 (
 SELECT
     p.FULLNAME                                                                                                                                                                           AS "Full Name",
     s.center||'ss'||s.id                                                                                                                                                                 AS "Subscription ID",
     p.center||'p'||p.id                                                                                                                                                                  AS "Person ID",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END      AS "Person Status",
     CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END                                                                                               AS "Subscription Status",
     p.SSN                                                                                                                                                                                AS "SSN",
     c.NAME                                                                                                                                                                               AS "Club",
     email.TXTVALUE                                                                                                                                                                       AS "Email",
     sms.TXTVALUE                                                                                                                                                                         AS "Mobile Phone",
     pr.NAME                                                                                                                                                                              AS "Membership Name",
     s.SUBSCRIPTION_PRICE                                                                                                                                                                 AS "Price",
     s.START_DATE                                                                                                                                                                         AS "Start Date",
     s.END_DATE                                                                                                                                                                           AS "Stop Date",
     s.BINDING_END_DATE                                                                                                                                                                   AS "Binding Date",
     CASE WHEN (UPPER(art.TEXT) like '%AUTO RENEWAL%') OR (UPPER(art.TEXT) like '%AUTORENEWAL%') THEN
       COALESCE(art.AMOUNT,0)
     END AS "Gross Direct Debit",
     CASE WHEN (UPPER(art.TEXT) like '%AUTOMATIC PLACEMENT%') OR (UPPER(art.TEXT) like 'PAYMENT INTO ACCOUNT%') THEN
       COALESCE(art.AMOUNT,0)
     END AS "Direct Debit Collected",
     ar.BALANCE  AS "Account Balance"
 FROM
     persons p
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.center
     AND s.OWNER_ID = p.id
 JOIN
     PRODUCTS pr
 ON
     pr.center = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = s.SUBSCRIPTIONTYPE_ID
 JOIN
     centers c
 ON
     c.id = p.center
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.center
     AND ar.CUSTOMERID = p.id
     AND ar.AR_TYPE = 4 -- ?? Only Payment Account
 JOIN
     AR_TRANS art
 ON
     ar.center = art.center
     AND ar.id = art.id
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name IN('_eClub_Email')
 LEFT JOIN
     PERSON_EXT_ATTRS sms
 ON
     p.center=sms.PERSONCENTER
     AND p.id=sms.PERSONID
     AND sms.name IN('_eClub_PhoneSMS')
 WHERE
     art.TRANS_TIME >=  :from_date
     AND art.TRANS_TIME < :to_date + 24*3600*1000
     AND s.START_DATE < longtodate(:from_date)
     AND (s.END_DATE is null OR s.END_DATE > longtodate(:to_date + 24*3600*1000))
     AND p.center in (:scope)
     AND (UPPER(art.TEXT) like '%AUTO RENEWAL%' OR UPPER(art.TEXT) like '%AUTORENEWAL%' OR UPPER(art.TEXT) like '%AUTOMATIC PLACEMENT%' OR UPPER(art.TEXT) like '%PAYMENT INTO ACCOUNT%')
 ) t
 GROUP BY
   "Full Name",
   "Subscription ID",
   "Person ID",
   "Person Status",
   "Subscription Status",
   "SSN",
   "Club",
   "Email",
   "Mobile Phone",
   "Membership Name",
   "Price",
   "Start Date",
   "Stop Date",
   "Binding Date",
   "Account Balance"
