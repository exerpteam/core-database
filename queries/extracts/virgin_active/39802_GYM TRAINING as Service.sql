-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4895
 SELECT
     p.FULLNAME           AS "Full Name",
     s.center||'ss'||s.id AS "Subscription ID",
     p.center||'p'||p.id  AS "Person ID",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 
     'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS
     "Person Status",
     CASE  s.state  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS
     "Subscription Status",
     CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 
     'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS
     "Subscription Sub State",
     TO_CHAR(p.BIRTHDATE,'DD/MM/YYYY')                        AS "Birthday",
     p.SSN                                                    AS "SSN",
     c.NAME                                                   AS "Club",
     email.TXTVALUE                                           AS "Email",
     sms.TXTVALUE                                             AS "Mobile Phone",
     sub_pr.NAME                                              AS "Subscription Name",
     s.SUBSCRIPTION_PRICE                                     AS "Price",
     TO_CHAR(s.START_DATE,'DD/MM/YYYY')                       AS "Start Date",
     TO_CHAR(s.END_DATE,'DD/MM/YYYY')                         AS "Stop Date",
     TO_CHAR(s.BINDING_END_DATE,'DD/MM/YYYY')                 AS "Binding Date",
     Biometrico.TXTVALUE                                      AS "Biometrico",
     DatiSensibili.TXTVALUE                                   AS "DatiSensibili",
     Immagine.TXTVALUE                                        AS "Immagine",
     Marketing.TXTVALUE                                       AS "Marketing",
     Profilazione.TXTVALUE                                    AS "Profilazione",
     TO_CHAR(longtodateC(i.ENTRY_TIME,i.center),'DD/MM/YYYY') AS "Date of Transaction",
     i.TEXT                                                   AS "Description of Service",
     il.QUANTITY                                              AS "Quantity",
     il.TOTAL_AMOUNT                                          AS "Amount Paid",
     CASE crt.CRTTYPE WHEN 1 THEN 'CASH' WHEN 2 THEN 'CHANGE' WHEN 3 THEN 'RETURN ON CREDIT' WHEN 4 THEN 'PAYOUT CASH' WHEN 5 THEN 
     'PAID BY CASH AR ACCOUNT' WHEN 6 THEN 'DEBIT CARD' WHEN 7 THEN 'CREDIT CARD' WHEN 8 THEN 'DEBIT OR CREDIT CARD' WHEN 9 THEN 'GIFT CARD'
      WHEN 10 THEN 'CASH ADJUSTMENT' WHEN 11 THEN 'CASH TRANSFER' WHEN 12 THEN 'PAYMENT AR' WHEN 13 THEN 'CONFIG PAYMENT METHOD' WHEN 14 THEN 
     'CASH REGISTER PAYOUT' WHEN 15 THEN 'CREDIT CARD ADJUSTMENT' WHEN 16 THEN 'CLOSING CASH ADJUST' WHEN 17 THEN 'VOUCHER' WHEN 18 THEN 
     'PAYOUT CREDIT CARD' WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS' WHEN 20 THEN 'CLOSING CREDIT CARD ADJ' WHEN 21 THEN 
     'TRANSFER BACK CASH COINS' ELSE 'UNKNOWN' END AS "Method Of Payment"
 FROM
     persons p
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.center
     AND s.OWNER_ID = p.id
 JOIN
     PRODUCTS sub_pr
 ON
     s.SUBSCRIPTIONTYPE_CENTER = sub_pr.center
     AND s.SUBSCRIPTIONTYPE_ID = sub_pr.id
 JOIN
     INVOICES i
 ON
     i.PAYER_CENTER = p.center
     AND i.PAYER_ID = p.id
 JOIN
     INVOICE_LINES_MT il
 ON
     il.center = i.center
     AND il.id = i.id
 JOIN
     PRODUCTS sales_prod
 ON
     sales_prod.center = il.PRODUCTCENTER
     AND sales_prod.id = il.PRODUCTID
 JOIN
     STATE_CHANGE_LOG scl
 ON
     scl.ENTRY_TYPE = 2
     AND scl.CENTER = s.CENTER
     AND scl.ID = s.ID
     AND scl.stateid IN (2,4) -- only active, frozen
     AND scl.ENTRY_START_TIME < i.ENTRY_TIME
     AND (
         scl.ENTRY_END_TIME IS NULL
         OR  scl.ENTRY_END_TIME >= i.ENTRY_TIME
     )
 LEFT JOIN
     CASHREGISTERTRANSACTIONS crt
 ON
     crt.CENTER = i.CASHREGISTER_CENTER
     AND crt.ID = i.CASHREGISTER_ID
     AND crt.PAYSESSIONID = i.PAYSESSIONID
 JOIN
     CENTERS c
 ON
     c.id = s.center
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS sms
 ON
     p.center=sms.PERSONCENTER
     AND p.id=sms.PERSONID
     AND sms.name = '_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS Biometrico
 ON
     p.center=Biometrico.PERSONCENTER
     AND p.id=Biometrico.PERSONID
     AND Biometrico.name = 'BIOMETRICO'
 LEFT JOIN
     PERSON_EXT_ATTRS DatiSensibili
 ON
     p.center=DatiSensibili.PERSONCENTER
     AND p.id=DatiSensibili.PERSONID
     AND DatiSensibili.name = 'DATISENSIBILI'
 LEFT JOIN
     PERSON_EXT_ATTRS Immagine
 ON
     p.center=Immagine.PERSONCENTER
     AND p.id=Immagine.PERSONID
     AND Immagine.name = 'IMMAGINE'
 LEFT JOIN
     PERSON_EXT_ATTRS Marketing
 ON
     p.center=Marketing.PERSONCENTER
     AND p.id=Marketing.PERSONID
     AND Marketing.name = 'MARKETING'
 LEFT JOIN
     PERSON_EXT_ATTRS Profilazione
 ON
     p.center=Profilazione.PERSONCENTER
     AND p.id=Profilazione.PERSONID
     AND Profilazione.name = 'PROFILAZIONE'
 WHERE
     i.ENTRY_TIME > $$From_Date$$
     AND i.ENTRY_TIME <= $$To_Date$$ + 24*3600*1000
     AND i.CENTER in ($$Scope$$)
     AND sales_prod.GLOBALID = 'GYMTRAINING2'
     AND sales_prod.PTYPE = 2 --Service product
