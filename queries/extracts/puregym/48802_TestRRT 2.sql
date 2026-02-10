-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-5555
SELECT
     pr.center,
     pr.id,
     pr.subid,
     p.center || 'p' || p.id            AS "PERSONKEY",
     TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD') AS "REQ_DATE" ,
     pr.REJECTED_REASON_CODE 			AS "REJECTED_REASON_CODE",
     pr.XFR_INFO						AS "XFR_INFO",
     -- no rejections on Thursdays
     TO_CHAR(
         CASE
             WHEN (TO_CHAR(ci.RECEIVED_DATE + 10, 'D') = TO_CHAR(to_date('2014-11-06', 'YYYY-MM-DD')
                     , 'D'))
             THEN ci.RECEIVED_DATE + 11
             ELSE ci.RECEIVED_DATE + 10
         END , 'YYYY-MM-DD') 			AS "REPR_REQ_DATE" ,
     pag.BANK_ACCOUNT_HOLDER 			AS "BANK_ACCOUNT_HOLDER",
     pag.BANK_REGNO 					AS "BANK_REGNO",
     pag.BANK_ACCNO 					AS "BANK_ACCNO" ,
     pag.REF 							AS "REF",
     TO_CHAR(pr.REQ_AMOUNT, 'fm9999999.90')                                 AS "REQ_AMOUNT" ,
     TO_CHAR(prod.PRICE, 'fm9999999.90')                               AS "REPR_FEE_AMOUNT" ,
     TO_CHAR(COALESCE(ivl.TOTAL_AMOUNT,0), 'fm9999999.90')                       AS "REJC_FEE_AMOUNT" ,
     TO_CHAR(pr.REQ_AMOUNT + prod.Price + ivl.TOTAL_AMOUNT, 'fm9999999.90') AS "REPR_REQ_AMOUNT" ,
     TO_CHAR(pr.REQ_AMOUNT + ivl.TOTAL_AMOUNT, 'fm9999999.90')              AS "REJC_REQ_AMOUNT" ,
     pea_email.txtvalue                                                     AS "EMAIL"
 FROM
     PAYMENT_REQUEST_SPECIFICATIONS prs
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.center = prs.center
     AND ar.id = prs.id
 JOIN
     PERSONS p
 ON
     p.center = ar.CUSTOMERCENTER
     AND p.id = ar.CUSTOMERID
 LEFT JOIN
     PERSON_EXT_ATTRS pea_email
 ON
     pea_email.PERSONCENTER = p.center
     AND pea_email.PERSONID = p.id
     AND pea_email.NAME = '_eClub_Email'
 JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.center = ar.center
     AND pac.id = ar.id
 JOIN
     PAYMENT_AGREEMENTS pag
 ON
     pag.center = pac.ACTIVE_AGR_center
     AND pag.id = pac.ACTIVE_AGR_id
     AND pag.SUBID = pac.ACTIVE_AGR_SUBID
 JOIN
     PAYMENT_REQUESTS pr
 ON
     prs.center = pr.INV_COLL_CENTER
     AND prs.id = pr.INV_COLL_ID
     AND prs.subid = pr.INV_COLL_SUBID
     AND pr.REQUEST_TYPE = 1
     AND pr.STATE NOT IN (1,2,3,4,8,12)
     --AND pr.REQ_DELIVERY is not null
     AND pr.REJECTED_REASON_CODE = '0'
 JOIN
     CLEARING_IN ci
 ON
     ci.ID = pr.XFR_DELIVERY
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = p.CENTER
     AND prod.GLOBALID = 'BOUNCE_FEE'
 LEFT JOIN
     INVOICELINES ivl
 ON
     ivl.CENTER = pr.REJECT_FEE_INVLINE_CENTER
     AND ivl.ID = pr.REJECT_FEE_INVLINE_ID
     AND ivl.SUBID = pr.REJECT_FEE_INVLINE_SUBID
 WHERE
     pag.state = 4
     AND ar.BALANCE < 0
     AND ci.RECEIVED_DATE > (CURRENT_TIMESTAMP - 6)
     AND ci.RECEIVED_DATE >= to_date('2014-01-14', 'YYYY-MM-DD')
     AND p.PERSONTYPE != 2
         AND p.sex != 'C'
     AND pr.center = 221
 and (p.center,p.id) not in 
 (
 SELECT  
     persons.CENTER,
     persons.ID
 FROM
     PERSONS persons
 JOIN
     CONVERTER_ENTITY_STATE con
 ON
     con.NEWENTITYCENTER = persons.CENTER
     AND con.NEWENTITYID = persons.ID
     AND con.WRITERNAME = 'ClubLeadPersonWriter'
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = persons.CENTER
     AND s.OWNER_ID = persons.ID
     AND s.STATE IN (2,4,8)
     
 LEFT JOIN
     SUBSCRIPTIONS sext
 ON
     sext.EXTENDED_TO_CENTER = s.CENTER
     AND sext.EXTENDED_TO_ID = s.ID
     and sext.CREATOR_CENTER = 100 and sext.CREATOR_ID = 1
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND st.id = s.SUBSCRIPTIONTYPE_ID
     AND st.ST_TYPE = 1
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.id = s.SUBSCRIPTIONTYPE_ID
 WHERE
     persons.CENTER IN (141,
                        147,
                        123,149)
     AND prod.GLOBALID IN ('DD_TIER_1000',
                           'LAX_PIF',
                           'DD_TIER_777')
      and ((s.CREATOR_CENTER = 100 and s.CREATOR_ID = 1) or sext.CENTER is not null) 
 )