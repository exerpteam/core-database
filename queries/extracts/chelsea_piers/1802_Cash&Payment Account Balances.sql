-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
SELECT 
                :cutDate + (24*60*60*1000) AS cut_date,
                c.id AS center_id
        FROM
                centers c
),
payment_balance AS
(
        SELECT
                t1.center,
                t1.id,
                t1.payment_account_balance
        FROM
        (
                SELECT 
                        p.center,
                        p.id,
                        SUM(art.amount) AS payment_account_balance
                FROM chelseapiers.persons p
                JOIN chelseapiers.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
                JOIN chelseapiers.ar_trans art ON ar.center = art.center AND ar.id = art.id
                JOIN params par ON art.center = par.center_id AND art.entry_time < par.cut_date
                WHERE p.center IN (:Scope)
                GROUP BY 
                        p.center,
                        p.id
        ) t1
        WHERE
                t1.payment_account_balance != 0
),
cash_balance AS
(
        SELECT
                t1.center,
                t1.id,
                t1.cash_account_balance
        FROM
        (
                SELECT 
                        p.center,
                        p.id,
                        SUM(art.amount) AS cash_account_balance
                FROM chelseapiers.persons p
                JOIN chelseapiers.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 1
                JOIN chelseapiers.ar_trans art ON ar.center = art.center AND ar.id = art.id
                JOIN params par ON art.center = par.center_id AND art.entry_time < par.cut_date
                WHERE p.center IN (:Scope)
                GROUP BY 
                        p.center,
                        p.id
        ) t1
        WHERE
                t1.cash_account_balance != 0
),
list_of_members AS
(
        SELECT 
                p.center,
                p.id,
                pb.payment_account_balance,
                cb.cash_account_balance
        FROM
                chelseapiers.persons p
        LEFT JOIN payment_balance pb ON p.center = pb.center AND p.id = pb.id
        LEFT JOIN cash_balance cb ON p.center = cb.center AND p.id = cb.id
        WHERE
                (pb.center IS NOT NULL OR cb.center IS NOT NULL)
)
SELECT
        t1.MemberID                                 AS "Member ID",
        t1.MemberFirstName                                             AS "Member First Name",
        t1.MemberLastName                                              AS "Member Last Name",
        t1.payment_account_balance                                             AS "Payment Account Balance",
        t1.cash_account_balance                                             AS "Cash Account Balance",
        t1.MemberStatus AS "Member Status",
        TO_CHAR(t1.CheckinTime, 'MM-DD-YYYY HH24:MI') AS "CheckinTime"
FROM
(
        SELECT
                p.center || 'p' || p.id                                 AS MemberID,
                p.firstname                                             AS MemberFirstName,
                p.lastname                                              AS MemberLastName,
                lom.payment_account_balance,
                lom.cash_account_balance,
                (CASE p.status 
                        WHEN 0 THEN 'LEAD' 
                        WHEN 1 THEN 'ACTIVE' 
                        WHEN 2 THEN 'INACTIVE' 
                        WHEN 3 THEN 'TEMPORARYINACTIVE' 
                        WHEN 4 THEN 'TRANSFERRED' 
                        WHEN 5 THEN 'DUPLICATE' 
                        WHEN 6 THEN 'PROSPECT' 
                        WHEN 7 THEN 'DELETED' 
                        WHEN 8 THEN 'ANONYMIZED' 
                        WHEN 9 THEN 'CONTACT' 
                        ELSE 'Undefined' 
                END) AS MemberStatus,
                longtodatec(c.checkin_time, c.checkin_center) AS CheckinTime,
                rank() over (partition BY p.center, p.id ORDER BY c.checkin_time DESC, c.id) AS rnk  
        FROM list_of_members lom
        JOIN persons p ON lom.center = p.center AND lom.id = p.id
        LEFT JOIN chelseapiers.checkins c ON c.person_center = lom.center AND c.person_id = lom.id
) t1
        WHERE rnk = 1