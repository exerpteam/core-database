WITH
     PARAMS AS
     (
         SELECT
                 /*+ materialize */
                                 TRUNC(to_date(getcentertime(4), 'YYYY-MM-DD HH24:MI')+1) AS tomorrowDate,
                                 datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(4), 'YYYY-MM-DD HH24:MI') + 1), 'YYYY-MM-DD HH24:MI'),'Europe/London') AS nextDayLongDate
                 
     )
 SELECT DISTINCT
        t1.MemberID                                                 AS "Member ID",
        t1.MembershipStatus                             AS "Membership Status",
        t1.External_ID                                          AS "External_ID",
        t1.MembershipSubscription                       AS "Membership Subscription",
         t1.PT_Subscription_ID                           AS "PT Subscription ID",
         t1.PT_Subscription_name                         AS "PT Subscription name",        
     t1.MembershipEndDate                                AS "Membership End Date",
         t1.BindingDate                                          AS "BindingDate",
     MAX(t1.FamilyLink)                                  AS "Family Link",
     t1.FIRSTNAME,
     t1.Email                                                    AS "Email",
     t1.AgeofoldestdebtDAYS                              AS "Age of oldest debt (DAYS)",
     t1.CorporateFunded                                  AS "Corporate Funded",
     t1.PaymentAgreementStatus                   AS "Payment Agreement Status"
    
 FROM
     (
         SELECT
             c.NAME                                                                                                                                                  AS Club,
             p.center||'p'||p.id                                                                                                                                     AS MemberID,
                                 P.External_ID                                                                                                                                                                                                                                                                                   AS External_ID,                                                                                                                                                                                                                                                                                                         
             CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
             CASE r.RTYPE WHEN 4 THEN CASE r.RELATIVECENTER||'p'||r.RELATIVEID WHEN 'p' THEN NULL ELSE r.RELATIVECENTER||'p'||r.RELATIVEID END ELSE NULL END                                         AS FamilyLink,
             CASE r2.RTYPE WHEN 12 THEN r2.center||'p'||r2.id ELSE NULL END                                                                                                          AS MyPayerID,
             CASE r2.RTYPE WHEN 12 THEN payer.FULLNAME ELSE NULL END                                                                                                                 AS MyPayerName,
             p.FIRSTNAME,
            email.TXTVALUE                                                                                                  AS Email,
            TO_CHAR(s.START_DATE,'yyyy-MM-dd')                                                                              AS MembershipStartDate,
             TO_CHAR(s.END_DATE,'yyyy-MM-dd')                                                                                AS MembershipEndDate,
                         TO_CHAR(s.binding_end_date,'yyyy-MM-dd')                                                                                                                                                AS BindingDate,
             pr.NAME                                                                                                         AS MembershipSubscription,
             cs.clipsubid                                                                                                    AS PT_Subscription_ID, 
             cs.clipsubname                                                                                                   AS PT_Subscription_name ,
             s.SUBSCRIPTION_PRICE                                                                                            AS MembershipSubscriptionValue,
             CASE s.STATE WHEN 2 THEN  'ACTIVE'  WHEN 4  THEN  'FROZEN' END                                                                       AS MembershipStatus,
             PARAMS.tomorrowDate - ccc.STARTDATE                                                                             AS AgeofoldestdebtDAYS,
             COALESCE(ar.BALANCE + ar2.BALANCE,0)                                                                                 AS MembershipArrearsBalance,
            CASE  WHEN is_sponsored.center IS NULL THEN 'n' ELSE 'y' END                                                                        AS CorporateFunded,
              --pa.BANK_ACCNO                                                                                                   AS BankAccountCode,
             --pa.BANK_REGNO                                                                                                   AS BankSortCode,
             pa.REF                                                                                                          AS PaymentAgreementReference,
             CASE pa.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END AS PaymentAgreementStatus,
             compa.NAME                                                                                                                                                                                                        AS Companyagreementname,
             compa.center||'p'||compa.id||'rpt'||compa.SUBID                                                                 AS Companyagreementid
         FROM
             PERSONS p
                 JOIN
                         CENTERS c
                 ON
                         p.CENTER = c.ID AND c.COUNTRY = 'GB'
                 CROSS JOIN
             PARAMS
         JOIN
             SUBSCRIPTIONS s
         ON
             s.OWNER_CENTER = p.CENTER
             AND s.OWNER_ID = p.ID
             AND s.STATE IN (2,4)
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
             AND st.id = s.SUBSCRIPTIONTYPE_ID
            and st.st_type != 2
         JOIN
             PRODUCTS pr
         ON
             pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
             AND pr.id = s.SUBSCRIPTIONTYPE_ID
             --staff,pru,buddy PT DD standard
         JOIN
         (Select
         s.OWNER_CENTER,
         s.OWNER_ID,
         s.center ||'ss'|| s.id as clipsubid,
         pradd.name             as clipsubname      
         from
             SUBSCRIPTIONS s
                 
         JOIN
             SUBSCRIPTIONTYPES stadd
         ON
             stadd.CENTER = s.SUBSCRIPTIONTYPE_CENTER
             AND stadd.id = s.SUBSCRIPTIONTYPE_ID
             and stadd.st_type = 2
         JOIN
             PRODUCTS pradd
         ON
             pradd.CENTER = stadd.center
             AND pradd.id = stadd.id  ) cs
             on  
             cs.OWNER_CENTER = p.CENTER
             AND cs.OWNER_ID = p.ID
             
         LEFT JOIN
             PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
         ON
             ppgl.PRODUCT_CENTER = pr.CENTER
             AND ppgl.PRODUCT_ID = pr.ID
             AND ppgl.PRODUCT_GROUP_ID IN(247,268)
         
         LEFT JOIN
             PERSON_EXT_ATTRS email
         ON
             p.center=email.PERSONCENTER
             AND p.id=email.PERSONID
             AND email.name='_eClub_Email'
             AND email.TXTVALUE IS NOT NULL
         
         LEFT JOIN --Family relation / Friend
             RELATIVES r
         ON
             r.CENTER = p.CENTER
             AND r.id = p.ID
             AND r.RTYPE IN (4,1,3)
             AND r.STATUS =1
         LEFT JOIN --Other Payer
             RELATIVES r2
         ON
             r2.RELATIVECENTER = p.CENTER
             AND r2.RELATIVEID = p.ID
             AND r2.RTYPE IN (2,12)
             AND r2.STATUS = 1
         LEFT JOIN --company relation
             RELATIVES r21
         ON
             r21.RELATIVECENTER = p.CENTER
             AND r21.RELATIVEID = p.ID
             AND r21.RTYPE IN (2)
             AND r21.STATUS = 1
         LEFT JOIN
             COMPANYAGREEMENTS compa
         ON
             compa.CENTER = r.RELATIVECENTER
             AND compa.ID = r.RELATIVEID
             AND compa.SUBID = r.RELATIVESUBID
             AND r.RTYPE = 3
         LEFT JOIN
             PERSONS payer
         ON
             payer.CENTER = r2.CENTER
             AND payer.ID = r2.ID
             AND r2.RTYPE = 12
         LEFT JOIN
             PERSONS comp
         ON
             comp.CENTER = CASE  WHEN r21.CENTER IS NULL THEN compa.center ELSE r21.CENTER END
             AND comp.ID = CASE  WHEN r21.id IS NULL THEN compa.id ELSE r21.id END
         LEFT JOIN --company contact
             RELATIVES r3
         ON
             r3.CENTER = comp.CENTER
             AND r3.ID = comp.ID
             AND r3.RTYPE =7
             AND r3.STATUS = 1
         LEFT JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.CUSTOMERCENTER = p.CENTER
             AND ar.CUSTOMERID = p.ID
             AND ar.AR_TYPE = 4
         LEFT JOIN
             ACCOUNT_RECEIVABLES ar2
         ON
             ar2.CUSTOMERCENTER = p.CENTER
             AND ar2.CUSTOMERID = p.ID
             AND ar2.AR_TYPE = 1
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
         LEFT JOIN
             CASHCOLLECTIONCASES ccc
         ON
             ccc.PERSONCENTER = p.CENTER
             AND ccc.PERSONID = p.id
             AND ccc.CLOSED = 0
             AND ccc.MISSINGPAYMENT = 1
         LEFT JOIN
             CASHCOLLECTIONCASES ccc2
         ON
             ccc2.PERSONCENTER = p.CENTER
             AND ccc2.PERSONID = p.id
             AND ccc2.CLOSED = 0
             AND ccc2.MISSINGPAYMENT = 1
             AND ccc2.STARTDATE < ccc.STARTDATE
         LEFT JOIN
             (
                 SELECT
                     s.center,
                     s.id
                 FROM
                     subscriptions s
                                 CROSS JOIN PARAMS
                 JOIN
                     SUBSCRIPTIONTYPES st
                 ON
                     s.subscriptiontype_center = st.center
                     AND s.subscriptiontype_id = st.id
                     
                 JOIN
                     products pr
                 ON
                     st.center = pr.center
                     AND st.id = pr.id
                 JOIN --Family relation / Friend 401 681
                     RELATIVES r
                 ON
                     r.CENTER = s.owner_center
                     AND r.id = s.owner_ID
                     AND r.RTYPE IN (3)
                     AND r.STATUS =1
                 JOIN
                     COMPANYAGREEMENTS ca
                 ON
                     ca.CENTER = r.RELATIVECENTER
                     AND ca.ID = r.RELATIVEID
                     AND ca.SUBID = r.RELATIVESUBID
                 JOIN
                     PRIVILEGE_GRANTS pg
                 ON
                     pg.GRANTER_CENTER = ca.CENTER
                     AND pg.GRANTER_ID = ca.ID
                     AND pg.GRANTER_SUBID = ca.SUBID
                     AND pg.SPONSORSHIP_NAME != 'NONE'
                     AND pg.VALID_FROM < PARAMS.nextDayLongDate
                     AND (
                         pg.VALID_TO >= PARAMS.nextDayLongDate
                         OR pg.VALID_TO IS NULL)
  and pg.GRANTER_SERVICE = 'CompanyAgreement'
                 JOIN
                     PRODUCT_PRIVILEGES pp
                 ON
                     pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
                     AND pp.VALID_FROM < PARAMS.nextDayLongDate
                     AND (
                         pp.VALID_TO >= PARAMS.nextDayLongDate
                         OR pp.VALID_TO IS NULL)
                     AND pp.REF_GLOBALID = pr.GLOBALID
                 WHERE
                     s.CENTER IN (:scope) ) is_sponsored
         ON
             is_sponsored.center = s.CENTER
             AND is_sponsored.id = s.id
         WHERE
             p.CENTER IN (:scope)
             --AND p.id = 1026
             AND ccc2.center IS NULL
          --   and p.center = 27 and p.id = 98832
                         AND C.ID NOT IN (
 5,
 8,
 11,
 13,
 14,
 17,
 18,
 19,
 20,
 22,
 23,
 24,
 25,
 26,
 28,
 32,
 37,
 41,
 42,
 44,
 46,
 49,
 53,
 54,
 63,
 66,
 67,
 70,
 73,
 400,
 401,
 402,
 403,
 404,
 406,
 407,
 409,
 411,
 412,
 413,
 414,
 416,
 417,
 418,
 419,
 420,
 423,
 424,
 426,
 427,
 428,
 429,
 430,
 431,
 432,
 433,
 434,
 435,
 436,
 439,
 440,
 441,
 442,
 443,
 444,
 446,
 447,
 448,
 449,
 450,
 451)
     ) t1
 GROUP BY
         t1.MemberID,
         t1.External_ID,
             t1.FIRSTNAME,
    
     t1.Email,
     t1.MembershipStartDate,
     t1.MembershipEndDate,
     t1.MembershipSubscription,
     t1.PT_Subscription_ID,
     t1.PT_Subscription_name,
     t1.MembershipSubscriptionValue,
     t1.MembershipStatus,
         t1.BindingDate,
     t1.AgeofoldestdebtDAYS,
     t1.MembershipArrearsBalance,
     t1.CorporateFunded,
     --"Bank Sort Code",
     --"Bank Account Code",
     t1.PaymentAgreementReference,
     t1.PaymentAgreementStatus