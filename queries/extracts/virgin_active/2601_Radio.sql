SELECT
    c.NAME                                               AS "Club",
    p.center||'p'||p.id                                  AS "Member ID",
    DECODE(r.RELATIVECENTER||'p'||r.RELATIVEID,'p',NULL) AS "Family Link",
    salutation.TXTVALUE                                  AS "Title",
    p.FIRSTNAME,
    p.LASTNAME,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE                          AS "Post Code",
    email.TXTVALUE                     AS "Email",
    mobile.TXTVALUE                    AS "Mobile",
    home.TXTVALUE                      AS "Home Phone",
    Creationdate.TXTVALUE              AS "Join Date",
    TO_CHAR(p.BIRTHDATE,'yyyy-MM-dd')  AS "Date of Birth",
    TO_CHAR(s.START_DATE,'yyyy-MM-dd') AS "Membership Start Date",
    TO_CHAR(s.END_DATE,'yyyy-MM-dd')   AS "Membership End Date",
    pr.NAME                            AS "Membership Subscription",
    s.SUBSCRIPTION_PRICE,
    DECODE(s.STATE,2, 'ACTIVE', 4 , 'FROZEN') AS "Membership Status",
    --Age of oldest debt (any)
    --Membership Arrears Balance
    --Upfront
    --Pru
    --Staff
    --Buddy
    --Corporate Funded
    comp.FULLNAME                                                                                                                                                                                                        AS "Company Name",
    exerpro.longtodate(inv.TRANS_TIME)                                                                                                                                                                                                        AS "Last Swim Purchase Date",
    il.TOTAL_AMOUNT                                                                                                                                                                                                        AS "Last Swim Purchase Value",
    pa.BANK_ACCNO                                                                                                                                                                                                        AS "Bank Account Code",
    pa.BANK_REGNO                                                                                                                                                                                                        AS "Bank Sort Code",
    pa.REF                                                                                                                                                                                                        AS "Payment Agreement Reference",
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') AS "Payment Agreement State"
FROM
    PERSONS p
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4)
LEFT JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
    AND home.TXTVALUE IS NOT NULL
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
    AND mobile.TXTVALUE IS NOT NULL
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
    AND email.TXTVALUE IS NOT NULL
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
    AND p.id=salutation.PERSONID
    AND salutation.name='_eClub_Salutation'
    AND salutation.TXTVALUE IS NOT NULL
LEFT JOIN
    PERSON_EXT_ATTRS Creationdate
ON
    p.center=Creationdate.PERSONCENTER
    AND p.id=Creationdate.PERSONID
    AND Creationdate.name='CREATION_DATE'
    AND Creationdate.TXTVALUE IS NOT NULL
JOIN
    CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN --Family relation
    RELATIVES r
ON
    r.CENTER = p.CENTER
    AND r.id = p.ID
    AND r.RTYPE IN (4)
    AND r.STATUS =1
LEFT JOIN --company relation
    RELATIVES r2
ON
    r2.RELATIVECENTER = p.CENTER
    AND r2.RELATIVEID = p.ID
    AND r2.RTYPE IN (2)
    AND r2.STATUS = 1
LEFT JOIN
    PERSONS comp
ON
    comp.CENTER = r2.CENTER
    AND comp.ID = r2.ID
LEFT JOIN
    (
        SELECT
            il.PERSON_CENTER,
            il.PERSON_ID,
            MAX(inv.TRANS_TIME) TRANS_TIME
        FROM
            INVOICELINES il
        JOIN
            INVOICES inv
        ON
            inv.CENTER=il.CENTER
            AND inv.ID = il.ID
        JOIN
            PRODUCTS pr
        ON
            pr.CENTER = il.PRODUCTCENTER
            AND pr.id = il.PRODUCTID
            AND pr.GLOBALID = 'swimming'
        GROUP BY
            il.PERSON_CENTER,
            il.PERSON_ID) last_swim
ON
    last_swim.PERSON_CENTER = p.CENTER
    AND last_swim.PERSON_ID = p.ID
LEFT JOIN
    INVOICELINES il
ON
    il.PERSON_CENTER = last_swim.PERSON_CENTER
    AND il.PERSON_ID = last_swim.PERSON_ID
LEFT JOIN
    INVOICES inv
ON
    inv.CENTER=il.CENTER
    AND inv.ID = il.ID
    AND inv.TRANS_TIME = last_swim.TRANS_TIME
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.id = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
WHERE
    p.CENTER IN ($$scope$$)