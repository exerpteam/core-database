-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                c.id,
                datetolongC(to_char(add_months(to_date(getCenterTime(c.id),'YYYY-MM-DD'),-t1.number_of_months),'YYYY-MM-DD'),c.id) AS cutdate,
                dateToLongC(getCenterTime(c.id),c.id) AS currentdatetime
        FROM centers c
        CROSS JOIN
        (
                SELECT 
                        :delete_person_interval AS number_of_months
        ) t1
        WHERE c.id IN (:Scope)
),
eligible_members AS
(
        SELECT  
                p.center || 'p' || p.id AS personid,
                p.center,
                p.id,
                p.blacklisted,
                p.persontype
        FROM persons p
        JOIN params par ON p.center = par.id
        WHERE
                p.status IN (0,2,6,9)
                AND p.sex NOT IN ('C')
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM checkins c
                        WHERE
                                c.person_center = p.center
                                AND c.person_id = p.id
                                AND c.checkin_time > par.cutdate
                )
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM attends att
                        WHERE
                                att.person_center = p.center
                                AND att.person_id = p.id
                                AND att.state NOT IN ('CANCELLED')
                                AND att.start_time > par.cutdate
                )
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM participations part
                        WHERE
                                part.participant_center = p.center
                                AND part.participant_id = p.id
                                AND part.state NOT IN ('CANCELLED')
                                AND part.start_time > par.cutdate
                )
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM state_change_log scl
                        WHERE
                                scl.entry_type = 1
                                AND scl.center = p.center
                                AND scl.id = p.id
                                AND scl.book_start_time > par.cutdate
                )
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM account_receivables ar
                        WHERE
                                ar.customercenter = p.center
                                AND ar.customerid = p.id
                                AND ar.last_entry_time > par.cutdate
                )
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM account_receivables ar
                        WHERE
                                ar.customercenter = p.center
                                AND ar.customerid = p.id
                                AND ar.ar_type = 6
                                AND ar.balance != 0
                )
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM relatives r
                        WHERE
                                r.relativecenter = p.center
                                AND r.relativeid = p.id
                                AND r.rtype = 7
                                AND r.status NOT IN (3)
                )
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM relatives r
                        INNER JOIN persons p2 ON r.relativecenter = p2.center AND r.relativeid = p2.id AND r.rtype <> 3
                        WHERE
                                r.center = p.center
                                AND r.id = p.id
                                AND r.rtype = 14
                                AND r.status IN (1)
                                AND p2.status NOT IN (7)
                )
				AND (p.center,p.id) NOT IN ((100,1))
),
condition_1 AS
(
        SELECT 
                DISTINCT
                em.*
        FROM eligible_members em
        JOIN subscriptions s ON em.center = s.owner_center AND em.id = s.owner_id 
        WHERE
                s.state != 3
                OR
                s.end_date IS NULL
),
condition_2 AS
(
        SELECT 
                DISTINCT
                em.*
        FROM eligible_members em
        JOIN subscriptions s ON em.center = s.owner_center AND em.id = s.owner_id AND s.end_date IS NULL
        JOIN subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id AND st.st_type NOT IN (0)
        WHERE
                s.billed_until_date IS NULL AND s.end_date >= s.start_date
),
condition_3 AS
(
        SELECT 
                DISTINCT
                em.*
        FROM eligible_members em
        JOIN subscriptions s ON em.center = s.owner_center AND em.id = s.owner_id AND s.end_date IS NULL
        JOIN subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id AND st.st_type NOT IN (0)
        WHERE
                s.billed_until_date IS NOT NULL AND s.billed_until_date < s.end_date
),
condition_4 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em
        JOIN clipcards cc ON em.center = cc.owner_center AND em.id = cc.owner_id
        WHERE
                cc.cancelled = false
                AND cc.blocked = false
                AND cc.finished = false
),
condition_5 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em
        JOIN relatives r ON em.center = r.center AND em.id = r.id AND r.rtype = 12 AND r.status NOT IN (3)
),
condition_6 AS
(
        SELECT
                DISTINCT
                em.*,
                ar.balance
        FROM eligible_members em 
        JOIN account_receivables ar ON em.center = ar.customercenter AND em.id = ar.customerid AND ar.state NOT IN (4)
        WHERE
                ar.balance != 0
                AND ar.ar_type = 1
),
condition_7 AS
(
        SELECT
                DISTINCT
                em.*,
                ar.balance
        FROM eligible_members em 
        JOIN account_receivables ar ON em.center = ar.customercenter AND em.id = ar.customerid AND ar.state NOT IN (4)
        WHERE
                ar.balance != 0
                AND ar.ar_type = 4
),
condition_8 AS
(
        SELECT
                DISTINCT
                em.*,
                ar.balance
        FROM eligible_members em 
        JOIN account_receivables ar ON em.center = ar.customercenter AND em.id = ar.customerid AND ar.state NOT IN (4)
        WHERE
                ar.balance != 0
                AND ar.ar_type = 5
),
condition_9 AS
(
        SELECT
                DISTINCT
                em.*,
                ar.balance
        FROM eligible_members em 
        JOIN account_receivables ar ON em.center = ar.customercenter AND em.id = ar.customerid AND ar.state NOT IN (4)
        WHERE
                ar.balance != 0
                AND ar.ar_type = 6
),
condition_10 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN employees emp ON em.center = emp.personcenter AND em.id = emp.personid
        WHERE
                emp.blocked = false
),
condition_11 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN relatives r ON em.center = r.relativecenter AND em.id = r.relativeid
        WHERE
                em.persontype = 2
                AND r.rtype = 1
                AND r.relativesubid IS NULL
                AND r.status NOT IN (3)
),
condition_12 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN participations part ON em.center = part.participant_center AND em.id = part.participant_id
        JOIN params par ON part.center = par.id
        WHERE
                part.start_time > par.currentdatetime
                AND part.state NOT IN ('CANCELLED')
),
condition_13 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN cashcollectioncases ccc ON em.center = ccc.personcenter AND em.id = ccc.personid
        WHERE
                ccc.closed = false
),
condition_14 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN cashcollectioncases ccc ON em.center = ccc.personcenter AND em.id = ccc.personid
        JOIN cashcollection_requests ccr ON ccr.center = ccc.center AND ccr.id = ccc.id
        WHERE
                ccr.state = 0
),
condition_15 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN account_receivables ar ON em.center = ar.customercenter AND em.id = ar.customerid
        JOIN payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
        JOIN payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
        WHERE
                ar.ar_type = 4
                AND pag.state NOT IN (3,5,6,7,8,9,10)
),
condition_16 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN account_receivables ar ON em.center = ar.customercenter AND em.id = ar.customerid
        JOIN payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
        JOIN payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
        JOIN payment_requests pr ON pag.center = pr.center AND pag.id = pr.id AND pag.subid = pr.agr_subid
        WHERE
                ar.ar_type = 4
                AND pr.state IN (1,20)
),
condition_17 AS
(
        SELECT
                DISTINCT
                em.*
        FROM eligible_members em 
        JOIN relatives r ON em.center = r.relativecenter AND em.id = r.relativeid
        WHERE
                r.rtype = 7
                AND r.relativesubid IS NULL
                AND r.status NOT IN (3)
)
SELECT
        em.PersonId,
        (CASE WHEN c1.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS SUB_NOT_ENDED,
        (CASE WHEN c2.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS SUB_NO_BUD,
        (CASE WHEN c3.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS SUB_NEEDS_BILLING,
        (CASE WHEN c4.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS ACTIVE_CLIPCARD,
        (CASE WHEN c5.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS IS_A_PAYER,
        (CASE WHEN c6.PersonId IS NOT NULL THEN c6.balance ELSE NULL END) AS CASH_ACC_BALANCE,
        (CASE WHEN c7.PersonId IS NOT NULL THEN c7.balance ELSE NULL END) AS PAYMENT_ACC_BALANCE,
        (CASE WHEN c8.PersonId IS NOT NULL THEN c8.balance ELSE NULL END) AS DEBTCOLL_ACC_BALANCE,
        (CASE WHEN c9.PersonId IS NOT NULL THEN c9.balance ELSE NULL END) AS INSTALLMENT_ACC_BALANCE,
        (CASE WHEN em.blacklisted > 0 THEN 'X' ELSE NULL END) AS BLACKLISTED,
        (CASE WHEN c10.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS UNBLOCKED_STAFF,
        (CASE WHEN c11.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS STAFF_WITH_FRIEND,
        (CASE WHEN c12.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS HAS_PARTICIPATION,
        (CASE WHEN c13.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS OPEN_CCC,
        (CASE WHEN c14.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS UNEXPORTED_CCR,
        (CASE WHEN c15.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS NO_ENDED_AGREEMENT,
        (CASE WHEN c16.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS UNEXPORTED_PPR,
        (CASE WHEN c17.PersonId IS NOT NULL THEN 'X' ELSE NULL END) AS CONTACT_PERSON
FROM eligible_members em
LEFT JOIN condition_1 c1 ON em.PersonId = c1.PersonId
LEFT JOIN condition_2 c2 ON em.PersonId = c2.PersonId
LEFT JOIN condition_3 c3 ON em.PersonId = c3.PersonId
LEFT JOIN condition_4 c4 ON em.PersonId = c4.PersonId
LEFT JOIN condition_5 c5 ON em.PersonId = c5.PersonId
LEFT JOIN condition_6 c6 ON em.PersonId = c6.PersonId
LEFT JOIN condition_7 c7 ON em.PersonId = c7.PersonId
LEFT JOIN condition_8 c8 ON em.PersonId = c8.PersonId
LEFT JOIN condition_9 c9 ON em.PersonId = c9.PersonId
LEFT JOIN condition_10 c10 ON em.PersonId = c10.PersonId
LEFT JOIN condition_11 c11 ON em.PersonId = c11.PersonId
LEFT JOIN condition_12 c12 ON em.PersonId = c12.PersonId
LEFT JOIN condition_13 c13 ON em.PersonId = c13.PersonId
LEFT JOIN condition_14 c14 ON em.PersonId = c14.PersonId
LEFT JOIN condition_15 c15 ON em.PersonId = c15.PersonId
LEFT JOIN condition_16 c16 ON em.PersonId = c16.PersonId
LEFT JOIN condition_17 c17 ON em.PersonId = c17.PersonId
