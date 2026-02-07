 SELECT distinct
     p.center || 'p' || p.id AS PERSONID,
         p.status,
     TO_CHAR(longToDateC(jrn.creation_time, jrn.creatorcenter),'yyyy-MM-dd HH24:MI:SS')  AS NoteCreationTime,
     replace(replace(replace(replace(jrn.name, CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]') AS Header,
    /* replace(replace(replace(replace(UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(jrn.big_text, 2000,1), 'UTF8'), CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]') AS NoteText,*/
       replace(replace(replace(replace(convert_from(jrn.big_text, 'UTF-8'), CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]') AS NoteText,
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
     jrn.jetype = 3
     AND p.center IN (75)
     -- Exclude following jrn note header
     AND jrn.name NOT IN ('Person created', 'State Unchanged', 'Password was updated', 'Apply: Resend payment request', 'Person Type Changed')
     -- no guest records
     AND p.persontype NOT IN (8)
     AND (
         -- active,temp inactive
         (
             p.status IN (1,3)
             AND s.state IN (2,4,8))
         -- prospect,contact if they are other payer
         OR (
             p.status IN (6,9)
             AND s.id IS NULL
             AND pay_for.PAYER_CENTER IS NOT NULL)
         -- Open debt collection case member
         OR (
             ccc.id IS NOT NULL
             AND EXISTS
             (
               SELECT
                   1
               FROM
                   STATE_CHANGE_LOG scl
               WHERE
                   scl.CENTER = p.CENTER
                   AND scl.ID = p.ID
                   AND scl.ENTRY_TYPE=1
                   AND scl.BOOK_END_TIME IS NULL
                   AND scl.STATEID=2
                   AND scl.ENTRY_START_TIME > datetolong(TO_CHAR(add_months(CURRENT_TIMESTAMP,-6),'YYYY-MM-DD HH24:MI')))
             AND NOT EXISTS
             (
                 SELECT
                     1
                 FROM
                     SUBSCRIPTIONS s2
                 WHERE
                     s2.OWNER_CENTER = p.CENTER
                     AND s2.OWNER_ID = p.ID
                     AND COALESCE(s2.end_date,CURRENT_TIMESTAMP) > COALESCE(s.END_DATE,CURRENT_TIMESTAMP)))
         -- inactive member from last 6 months
         OR (
             p.status = 2
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG scl
                 WHERE
                     scl.CENTER = p.CENTER
                     AND scl.ID = p.ID
                     AND scl.ENTRY_TYPE=1
                     AND scl.BOOK_END_TIME IS NULL
                     AND scl.STATEID=2
                     AND scl.ENTRY_START_TIME > datetolong(TO_CHAR(add_months(CURRENT_TIMESTAMP,-6),'YYYY-MM-DD HH24:MI')))
             AND NOT EXISTS
             (
                 SELECT
                     1
                 FROM
                     SUBSCRIPTIONS s2
                 WHERE
                     s2.OWNER_CENTER = p.CENTER
                     AND s2.OWNER_ID = p.ID
                     AND COALESCE(s2.end_date,CURRENT_TIMESTAMP) > COALESCE(s.END_DATE,CURRENT_TIMESTAMP))))
