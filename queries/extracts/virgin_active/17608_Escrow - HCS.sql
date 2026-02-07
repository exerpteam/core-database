SELECT
        qaa.CENTER || 'p' || qaa.ID AS PersonId,
        qaa.RESULT_CODE
FROM QUESTIONNAIRE_ANSWER qaa
WHERE (qaa.CENTER, qaa.ID, qaa.LOG_TIME) in (
        SELECT
             p.CENTER,
             p.ID,
             max(qa.LOG_TIME)
        FROM QUESTIONNAIRE_CAMPAIGNS qc
        JOIN QUESTIONNAIRE_ANSWER qa ON qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
        JOIN PERSONS p ON p.CENTER=qa.CENTER AND p.ID=qa.ID
        LEFT JOIN SUBSCRIPTIONS s ON s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID
        LEFT JOIN CASHCOLLECTIONCASES ccc ON ccc.PERSONCENTER = p.CENTER AND ccc.PERSONID = p.ID AND ccc.CLOSED = 0 AND ccc.MISSINGPAYMENT = 1
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
                qc.QUESTIONNAIRE=1601
                AND qa.RESULT_CODE is not null
               -- AND length(qa.RESULT_CODE) = 8
                AND p.CENTER in (403,
440,
436,
411,
441,
442,
419,
434,
407,
400,
406,
435,
401,
443)
                --AND p.CENTER=28 AND p.ID=2646
                AND p.PERSONTYPE NOT IN (8)
                AND (
                        -- active,temp inactive
                        (p.STATUS IN (1,3) AND s.STATE in (2,4,8))
                        -- prospect,contact
                        OR (p.STATUS IN (6,9) AND s.ID is null  AND pay_for.PAYER_CENTER IS NOT NULL)
                        -- Open debt collection case member
                        OR (ccc.ID IS NOT NULL 
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
                                       AND scl.ENTRY_START_TIME > exerpro.datetolong(TO_CHAR(add_months(SYSDATE,-6),'YYYY-MM-DD HH24:MI')))                 
                             AND NOT EXISTS
                                (
                                SELECT
                                    1
                                FROM
                                    SUBSCRIPTIONS s2
                                WHERE
                                    s2.OWNER_CENTER = p.CENTER
                                    AND s2.OWNER_ID = p.ID
                                    AND NVL(s2.end_date,sysdate) > NVL(s.END_DATE,sysdate)))        
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
                                    AND scl.ENTRY_START_TIME > exerpro.datetolong(TO_CHAR(add_months(SYSDATE,-6),'YYYY-MM-DD HH24:MI'))) 
                            AND NOT EXISTS
                            (
                                SELECT
                                    1
                                FROM
                                    SUBSCRIPTIONS s2
                                WHERE
                                    s2.OWNER_CENTER = p.CENTER
                                    AND s2.OWNER_ID = p.ID
                                    AND NVL(s2.end_date,sysdate) > NVL(s.END_DATE,sysdate))))
        
         group by p.CENTER, p.ID              
)  
