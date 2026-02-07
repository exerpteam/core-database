SELECT 
    p.center||'p'||p.id                                              AS PERSONID,
    TO_CHAR(longToDateC(a.start_TIME,a.center),'YYYY-MM-dd HH24:MI') AS VisitDateTime,
    c.id                                                             AS VisitClubId,  
    c.name                                                           AS VisitClubName
FROM
    persons p
JOIN
    attends a
ON
    a.person_center = p.center
    AND a.person_id = p.id
JOIN
    centers c
ON
    c.id = a.center
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
    p.center IN (13)
	--AND Rownum<100000
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
                  AND scl.ENTRY_START_TIME > exerpro.datetolong(TO_CHAR(add_months(SYSDATE,-5),'YYYY-MM-DD HH24:MI')))                 
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s2
                WHERE
                    s2.OWNER_CENTER = p.CENTER
                    AND s2.OWNER_ID = p.ID
                    AND NVL(s2.end_date,SYSDATE) > NVL(s.END_DATE,SYSDATE)))
        -- inactive member from last 1 month
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
                    AND scl.ENTRY_START_TIME > exerpro.datetolong(TO_CHAR(add_months(SYSDATE,-1),'YYYY-MM-DD HH24:MI')))
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s2
                WHERE
                    s2.OWNER_CENTER = p.CENTER
                    AND s2.OWNER_ID = p.ID
                    AND NVL(s2.end_date,SYSDATE) > NVL(s.END_DATE,SYSDATE))))
					AND Rownum<1048571