 SELECT DISTINCT
     cs.SHORTNAME "Club",
     ps.CENTER || 'p' || ps.ID "Staff Id",
     ss.TXTVALUE "Title",
     ps.FIRSTNAME "Staff First Name",
     ps.LASTNAME "Staff Last Name",
     /* Might be that the member has more then one sub, get the one that has the first start date */
     FIRST_VALUE(prod.NAME) OVER (PARTITION BY ps.CENTER,ps.ID ORDER BY s.START_DATE ASC) "Membership Subscription",
     p.CENTER || 'p' || p.ID "Link Membership Id",
     c.SHORTNAME "Club",
     sp.TXTVALUE "Title",
     p.FIRSTNAME "Link First Name",
     p.LASTNAME "Link Last Name",
     rel."Relation Type" ,
     CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS "Person Type",
     /* Might be that the member has more then one sub, get the one that has the first start date */
     FIRST_VALUE(lprod.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY ls.START_DATE ASC) "Membership Subscription",
     p.BIRTHDATE "Date of birth",
     CASE
         WHEN TRUNC(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE)/12) < 16
         THEN 1
         ELSE 0
     END                                            AS "Under 16",
     TRUNC(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE)/12) age,
     FIRST_VALUE(ls.BINDING_PRICE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY ls.START_DATE ASC) "Monthly Payment"
 FROM
     (
         SELECT
             rel.RELATIVECENTER EMPLOYEE_CENTER,
             rel.RELATIVEID     EMPLOYEE_ID,
             rel.CENTER         PERSON_CENTER,
             rel.ID             PERSON_ID,
             rel.RTYPE,
             CASE  rel.RTYPE  WHEN 1 THEN 'FRIEND'  WHEN 2 THEN 'EMPLOYEE'  WHEN 3 THEN 'COMPANYAGREEMENT'  WHEN 4 THEN 'FAMILY'  WHEN 5 THEN 'BUDDY'  WHEN 6 THEN 'SUBCOMPANY'  WHEN 7 THEN 'CONTACTPERSON'  WHEN 8 THEN 'CREATEDBY'  WHEN 9 THEN 'COUNSELLOR'  WHEN 10 THEN 'ACCOUNTMANAGER'  WHEN 11 THEN 'DUPLICATE'  WHEN 12 THEN 'EFT_PAYER'  WHEN 13 THEN 'REFERED_BY_ME' ELSE 'UNKNOWN' END AS "Relation Type"
         FROM
             RELATIVES rel
         WHERE
             rel.RELATIVECENTER IN ($$scope$$)
             AND rel.RTYPE IN (1,2,4,9,13)
             AND rel.STATUS = 1
         UNION
         SELECT
             rel.CENTER ,
             rel.ID,
             rel.RELATIVECENTER ,
             rel.RELATIVEID,
             rel.RTYPE,
             CASE  rel.RTYPE  WHEN 1 THEN 'FRIEND'  WHEN 2 THEN 'EMPLOYEE'  WHEN 3 THEN 'COMPANYAGREEMENT'  WHEN 4 THEN 'FAMILY'  WHEN 5 THEN 'BUDDY'  WHEN 6 THEN 'SUBCOMPANY'  WHEN 7 THEN 'CONTACTPERSON'  WHEN 8 THEN 'CREATEDBY'  WHEN 9 THEN 'COUNSELLOR'  WHEN 10 THEN 'ACCOUNTMANAGER'  WHEN 11 THEN 'DUPLICATE'  WHEN 12 THEN 'EFT_PAYER'  WHEN 13 THEN 'REFERED_BY_ME' ELSE 'UNKNOWN' END AS "Relation Type"
         FROM
             RELATIVES rel
         WHERE
             rel.CENTER IN ($$scope$$)
             AND rel.RTYPE IN (5,12)
             AND rel.STATUS = 1 )rel
 JOIN
     PERSONS ps
 ON
     rel.EMPLOYEE_CENTER = ps.CENTER
     AND rel.EMPLOYEE_ID = ps.ID
 JOIN
     CENTERS cs
 ON
     cs.ID = ps.CENTER
 LEFT JOIN
     PERSON_EXT_ATTRS ss
 ON
     ss.PERSONCENTER = ps.CENTER
     AND ss.PERSONID = ps.ID
     AND ss.NAME = '_eClub_Salutation'
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = ps.CENTER
     AND s.OWNER_ID = ps.ID
     AND s.STATE IN (2,4,8)
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
     /* Join on both sides and filer out the wrong side under persons */
 JOIN
     PERSONS p
 ON
     p.CENTER = rel.PERSON_CENTER
     AND p.ID = rel.PERSON_ID
 LEFT JOIN
     SUBSCRIPTIONS ls
 ON
     ls.OWNER_CENTER = p.CENTER
     AND ls.OWNER_ID = p.ID
     AND ls.STATE IN (2,4,8)
 LEFT JOIN
     PRODUCTS lprod
 ON
     lprod.CENTER = ls.SUBSCRIPTIONTYPE_CENTER
     AND lprod.ID = ls.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PERSON_EXT_ATTRS sp
 ON
     sp.PERSONCENTER = p.CENTER
     AND sp.PERSONID = p.ID
     AND sp.NAME = '_eClub_Salutation'
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 WHERE
     ps.PERSONTYPE = 2
 ORDER BY
     ps.CENTER || 'p' || ps.ID DESC
