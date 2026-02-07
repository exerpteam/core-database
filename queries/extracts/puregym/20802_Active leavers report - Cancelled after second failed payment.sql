 SELECT DISTINCT
     cen.name                                           AS "Club Name",
     p.CURRENT_PERSON_CENTER||'p'|| p.CURRENT_PERSON_ID AS "Member Id",
     p.FULLNAME                                         AS "Full Name",
     pem.TXTVALUE                                       AS Email,
     ph.TXTVALUE                                        AS PhoneHome,
     pm.TXTVALUE                                        AS Mobile,
     TO_CHAR(s.START_DATE,'yyyy-MM-dd')                 AS "Membership Start",
     TO_CHAR(s.END_DATE,'yyyy-MM-dd')                   AS "Membership End"
 FROM
     PERSONS p
 JOIN
     CENTERS cen
 ON
     cen.Id = p.CENTER
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.center
     AND s.OWNER_ID = p.id
     AND s.END_DATE = TRUNC(CURRENT_TIMESTAMP-1)
     AND s.SUB_STATE != 6 -- Exclude transfered
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.center
     AND ar.CUSTOMERID = p.id
 JOIN
     PAYMENT_AGREEMENTS pag
 ON
     pag.center = ar.center
     AND pag.id = ar.id
     AND pag.ACTIVE = 1
 LEFT JOIN
     person_ext_attrs ph
 ON
     ph.personcenter = p.center
     AND ph.personid = p.id
     AND ph.name = '_eClub_PhoneHome'
 LEFT JOIN
     person_ext_attrs pem
 ON
     pem.personcenter = p.center
     AND pem.personid = p.id
     AND pem.name = '_eClub_Email'
 LEFT JOIN
     person_ext_attrs pm
 ON
     pm.personcenter = p.center
     AND pm.personid = p.id
     AND pm.name = '_eClub_PhoneSMS'
 WHERE
     s.center IN ($$scope$$)
     AND p.status = 2
     AND MONTHS_BETWEEN(s.END_DATE,s.START_DATE) > 3
     AND EXISTS
     (
         SELECT
             1
         FROM
             PAYMENT_REQUESTS pr,
             PAYMENT_REQUEST_SPECIFICATIONS prs
         WHERE
             pr.CENTER = pag.center
             AND pr.id = pag.id
             AND pr.AGR_SUBID = pag.subid
             AND pr.state IN (17,7)
             AND pr.REJECTED_REASON_CODE = '0'
             AND pr.request_type IN (1,6)
             AND prs.CENTER = pr.INV_COLL_CENTER
             AND prs.ID = pr.INV_COLL_ID
             AND prs.SUBID = pr.INV_COLL_SUBID
         GROUP BY
             prs.ref,
             pr.center,
             pr.id
         HAVING
             COUNT(*) > 1 )
