 SELECT
     c.NAME as "Club name",
     ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS "P Number",
     p.FULLNAME as "Member Name",
     mobile.TXTVALUE as "Phone number",
     CASE  pa.ENDED_REASON_CODE  WHEN '5' THEN 'No account'  WHEN 'B' THEN 'Account closed'  WHEN 'F' THEN 'Invalid account type' WHEN 'G' THEN 'Bank will not accept Direct Debits on account' WHEN 'I' THEN 'creditNoteLine' ELSE 'UNKNOWN' END AS Reason,
     ci.RECEIVED_DATE as "Received Date"
 FROM
     PAYMENT_AGREEMENTS pa
 JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.ACTIVE_AGR_CENTER =pa.CENTER
     AND pac.ACTIVE_AGR_ID = pa.ID
     AND pac.ACTIVE_AGR_SUBID = pa.SUBID
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = pac.CENTER
     AND ar.ID = pac.ID
     AND ar.AR_TYPE = 4
 JOIN
     PERSONS p
 ON
     p.CENTER = ar.CUSTOMERCENTER
     AND p.ID = ar.CUSTOMERID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 LEFT JOIN PERSON_EXT_ATTRS mobile
         ON
             mobile.personcenter = p.center
             AND mobile.personid = p.id
             AND mobile.name = '_eClub_PhoneSMS'
 JOIN
     CASHCOLLECTIONCASES ccc
 ON
     ccc.PERSONCENTER = ar.CUSTOMERCENTER
     AND ccc.PERSONID = ar.CUSTOMERID
     AND ccc.MISSINGPAYMENT = 0
     AND ccc.CLOSED = 0
 JOIN
     CLEARING_IN ci
 ON
     ci.ID = pa.ENDED_CLEARING_IN
 WHERE
     pa.STATE = 3
     AND pa.ENDED_REASON_CODE IN ('5',
                                  'B',
                                  'F',
                                  'G',
                                  'I')
     AND ci.RECEIVED_DATE BETWEEN TRUNC(CURRENT_TIMESTAMP-1) AND TRUNC(CURRENT_TIMESTAMP+1)
