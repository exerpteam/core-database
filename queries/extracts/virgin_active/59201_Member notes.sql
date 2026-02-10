-- The extract is extracted from Exerp on 2026-02-08
-- Test used for member notes
 SELECT distinct
     p.center || 'p' || p.id AS PERSONID,
     TO_CHAR(longToDateC(jrn.creation_time, jrn.creatorcenter),'yyyy-MM-dd HH24:MI:SS')  AS NoteCreationTime,
     jrn.name                AS Header,
--     UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(jrn.big_text, 2000,1), 'UTF8') AS NoteText,
     convert_from(jrn.big_text, 'UTF-8') AS NoteText,
     jrnCreator.fullname AS CreatorName
 FROM
     journalentries jrn
 JOIN
     persons p
 ON
     p.center = jrn.person_center
     AND p.id = jrn.person_id
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
     --jrn.jetype = 3
    p.center || 'p' || p.id IN ('39p117491')
	--P.external_id = '590019'
ORDER BY  NoteCreationTime desc