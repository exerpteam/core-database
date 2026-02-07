SELECT distinct
    p.CENTER || 'p' || p.id "MemberID"
  , p.FIRSTNAME             "Firstname"
  , p.LASTNAME              "Lastname"
  , ExtPhoneSMS.TXTVALUE    "Phonenumber"
  , ExtEmail.TXTVALUE "E-mailaddress"
  , chc.FIELD_3 "Account number"
  , pa.ref "KID number"
FROM
    PERSONS p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.id
    AND ar.AR_TYPE = 4
	AND ar.state = 0
    AND p.STATUS IN (1,3)
    AND p.sex != 'C'
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.CLEARINGHOUSE
    AND ch.state = 'ACTIVE' 
    AND 
      (  ch.ctype in (8,16,32,136,147) /* Invoice agreements */
         OR
         (
                ch.ctype in (1,2,4,64,158) /* EFT agreements */
           AND  pa.STATE in (3,5,6,7,8,9,10,14,17) /* Failed;Ended,bank;Ended,clearing house;Ended,debtor;Cancelled,not sent;Cancelled,sent;Ended,creditor;Agreement information incomplete;Agreement signature missing */
         )
      )                       
JOIN
    CLEARINGHOUSE_CREDITORS chc
ON
    chc.CLEARINGHOUSE = ch.id
    AND chc.CREDITOR_ID = pa.CREDITOR_ID
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 12
    /* Will be billed again */
JOIN
    SUBSCRIPTIONS s
ON
    (
        s.OWNER_CENTER = p.CENTER
        AND s.OWNER_ID = p.ID)
    OR (
        s.OWNER_CENTER = rel.RELATIVECENTER
        AND s.OWNER_ID = rel.RELATIVEID)
    AND (
        s.BILLED_UNTIL_DATE < s.END_DATE
        OR s.END_DATE IS NULL)
LEFT JOIN
    PERSON_EXT_ATTRS ExtEmail
ON
    ExtEmail.PERSONCENTER = p.CENTER
    AND ExtEmail.PERSONID = p.ID
    AND ExtEmail.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS ExtPhoneSMS
ON
    ExtPhoneSMS.PERSONCENTER = p.CENTER
    AND ExtPhoneSMS.PERSONID = p.ID
    AND ExtPhoneSMS.NAME = '_eClub_PhoneSMS'
WHERE
    p.center in ($$scope$$)