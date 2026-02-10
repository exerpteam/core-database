-- The extract is extracted from Exerp on 2026-02-08
-- RG created on 22nd March 23 for customer service team from request: SR-284436
 SELECT distinct
	C.Shortname,
     -- CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END as SUBSCRIPTION_STATE
   CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END                                                                                     MemberStatus,
     p.center || 'p' || p.id AS PERSONID,
     TO_CHAR(longToDateC(jrn.creation_time, jrn.creatorcenter),'yyyy-MM-dd HH24:MI:SS')  AS NoteCreationTime,
     jrn.name                AS Header,
--     UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(jrn.big_text, 2000,1), 'UTF8') AS NoteText,
     convert_from(jrn.big_text, 'UTF-8') AS NoteText,
	 TRUNC(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12) || ' years ' || TRUNC(mod(months_between (CURRENT_TIMESTAMP, p.BIRTHDATE),12)) || ' month ' || (CURRENT_DATE - add_months(p.BIRTHDATE, (months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12 ) * 12) + TRUNC(mod(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE),12)))::integer || ' days'
                                                                                                                           exact_current_age,
     jrnCreator.fullname AS CreatorName
 FROM
     journalentries jrn
 JOIN
     persons p
 ON
     p.center = jrn.person_center
     AND p.id = jrn.person_id

JOIN 
	Centers C
	ON P.center = c.ID

 join
    employees emp
 on
   emp.center = jrn.creatorcenter
   and emp.id = jrn.creatorid
 JOIN
     persons jrnCreator
 ON
     jrnCreator.center = emp.personcenter
     AND jrnCreator.id = emp.personid
 LEFT JOIN
     subscriptions s
 ON
     s.owner_center = p.center
     AND s.owner_id = p.id
 LEFT JOIN
     CASHCOLLECTIONCASES ccc
 ON
     ccc.PERSONCENTER = p.center
     AND ccc.PERSONID = p.id
     AND ccc.CLOSED = 0
     AND ccc.MISSINGPAYMENT = 1
             -- other payer
         LEFT JOIN
             (
                 SELECT DISTINCT
                     rel.center AS PAYER_CENTER,
                     rel.id     AS PAYER_ID
                 FROM
                     PERSONS mem
                 JOIN
                     SUBSCRIPTIONS sub
                 ON
                     mem.center = sub.OWNER_CENTER
                     AND mem.id = sub.OWNER_ID
                     AND sub.STATE IN (2,4,8)
                     AND (
                         sub.end_date IS NULL
                         OR sub.end_date > sub.BILLED_UNTIL_DATE )
                 JOIN
                     SUBSCRIPTIONTYPES st
                 ON
                     st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                     AND st.id = sub.SUBSCRIPTIONTYPE_ID
                 JOIN
                     RELATIVES rel
                 ON
                     rel.RELATIVECENTER = mem.center
                     AND rel.RELATIVEID = mem.id
                     AND rel.RTYPE = 12
                     AND rel.STATUS < 3
                 WHERE
                     st.ST_TYPE = 1
                     AND mem.persontype NOT IN (2,8) ) pay_for
         ON
             pay_for.payer_center = p.center
             AND pay_for.payer_id = p.id
 WHERE
	 p.blacklisted = '1' 
AND 
	jrn.name = 'Blacklisted'
-- AND 
	-- TO_CHAR(longToDateC(jrn.creation_time, jrn.creatorcenter),'yyyy-MM-dd HH24:MI:SS') > '2025-12-31'
-- AND
     -- P.external_id = '248269'
AND 
	C.ID IN (
	76,
29,
33,
34,
35,
27,
421,
405,
38,
438,
39,
47,
48,
12,
51,
56,
57,
59,
415,
2,
60,
61,
422,
452,
15,
6,
68,
69,
410,
16,
75,
953,
425,
408
)
ORDER BY 
	C.Shortname asc