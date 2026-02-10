-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     -- DO NOT REMOVE DISTINCT
     DISTINCT
 -- ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID person_Id,
     mobile.TXTVALUE AS "MOBILE_NO",
     ei.IDENTITY AS "SWIPE_NO",
     c.SHORTNAME AS "CLUB_NAME",
    -- p.FIRSTNAME,
     p.LASTNAME AS "LASTNAME",
  --   to_char(CASE
  --       WHEN pr.XFR_AMOUNT IS NOT NULL
   --      THEN pr.REQ_AMOUNT - pr.XFR_AMOUNT
  --       ELSE LEAST(prs.OPEN_AMOUNT, -ar.BALANCE)
   --  END,'FM99999999999999999990.00') OPEN_AMOUNT,
   --  prs.REF invoice_ref,
     'Exerp' AS "SOURCE_SYSTEM"
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     pr.INV_COLL_CENTER = prs.CENTER
     AND pr.INV_COLL_ID = prs.ID
     AND pr.INV_COLL_SUBID = prs.SUBID
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = prs.CENTER
     AND ar.ID = prs.ID
 JOIN
     PERSONS p
 ON
     ar.CUSTOMERCENTER = p.CENTER
     AND ar.CUSTOMERID = p.ID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER and c.country = 'GB'
 JOIN
     PERSON_EXT_ATTRS mobile
 ON
     p.center = mobile.PERSONCENTER
     AND p.id = mobile.PERSONID
     AND mobile.name = '_eClub_PhoneSMS'
         AND mobile.TXTVALUE is not null
 JOIN
     ENTITYIDENTIFIERS ei
 ON
     p.CENTER = ei.REF_CENTER
     AND p.ID = ei.REF_ID
     AND ei.ENTITYSTATUS = 1
     AND ei.REF_TYPE = 1
     AND ei.IDMETHOD = 2 -- Magnetic card
 WHERE
 -- exclude Vantage, Ring & Eclipse clubs
 p.center not in (403,
 440,
 436,
 411,
 441,
 442,
 419,
 434,
 407,
 400,
 406,
 435,
 401,
 443,
 450,
 448,
 427,
 67
 )
 and
     -- Only send requests for current month
     TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM') = TO_CHAR(TO_DATE(getcentertime(pr.CENTER),'YYYY-MM-DD'),'YYYY-MM')
     AND prs.OPEN_AMOUNT >= 5
     AND ar.BALANCE <= -5
     -- Not below 18 years
     AND EXTRACT('year' from AGE(p.BIRTHDATE)) > 17
     -- Not companies
     AND p.SEX <> 'C'
     -- Exclude deceased reason code
     AND (
         pr.REJECTED_REASON_CODE IS NULL
         OR pr.REJECTED_REASON_CODE NOT IN ('2'))
     AND ((
             -- FAILED NOT SUPPORTED, NO CREDITOR
             pr.STATE IN (12,19))
         OR (
             -- OR REJECTED OR REVOKED AND ONLY STATES NOT REPRESENTED
             pr.REQUEST_TYPE = 1
             AND pr.STATE IN (5,6,7,17,18)
             AND (
                 pr.REJECTED_REASON_CODE IS NULL
                 OR pr.REJECTED_REASON_CODE NOT IN ('0',
                                                    '2',
                                                    '7',
                                                    '8',
                                                    '9')) )
         OR (
             -- OR REPRESENTATION REJECTED OR REVOKED
             pr.REQUEST_TYPE = 6
             AND (
                 pr.REJECTED_REASON_CODE IS NULL
                 OR pr.STATE IN (5,6,7,17,18) ) ))
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             CASHCOLLECTIONCASES cc
         WHERE
             cc.PERSONCENTER = p.CENTER
             AND cc.PERSONID = p.ID
             AND cc.CASHCOLLECTIONSERVICE IS NOT NULL
             AND cc.MISSINGPAYMENT = 1
             AND cc.CLOSED = 0 )
