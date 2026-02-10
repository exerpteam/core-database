-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/issues/EC-8358
WITH params AS MATERIALIZED
(
        SELECT
                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS todaysdate,
                c.id,
                c.shortname
        FROM centers c
),
eligible_members AS
(
        SELECT
                DISTINCT
                p.center,
                p.id
        FROM persons p
        JOIN params par
                ON p.center = par.id
        JOIN account_receivables ar
                ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
        JOIN AR_TRANS art
                ON art.center = ar.center AND art.id = ar.id
        WHERE
                p.persontype = 2
                AND p.status NOT IN (4,5,7,8)
                AND ar.balance < 0
                AND art.status NOT IN ('CLOSED')
                AND art.due_date < todaysdate
        GROUP BY
                p.center,
                p.id
        UNION 
        SELECT
                DISTINCT
                p.center,
                p.id
        FROM persons p 
        JOIN CASHCOLLECTIONCASES cc
                ON cc.personcenter = p.center AND cc.personid = p.id 
        WHERE
                p.persontype = 2
                AND p.status NOT IN (4,5,7,8)
                AND cc.missingpayment = true 
                AND cc.CLOSED = false  
) 
SELECT
        t2.center||'p'||t2.id AS MemberID,
        par.Shortname AS Club,
        p.fullname AS Member_Name,
        t2.Subscription_Names,
        cc.amount AS debt_amount,
        CASE pag.state
                WHEN 1 THEN 'Created'
                WHEN 2 THEN 'Sent'
                WHEN 3 THEN 'Failed'
                WHEN 4 THEN 'OK'
                WHEN 5 THEN 'Ended, bank'
                WHEN 6 THEN 'Ended, clearing house'
                WHEN 7 THEN 'Ended, debtor'
                WHEN 8 THEN 'Cancelled, not sent'
                WHEN 9 THEN 'Cancelled, sent'
                WHEN 10 THEN 'Ended, creditor'
                WHEN 11 THEN 'No agreement'
                WHEN 12 THEN 'Cash payment (deprecated)'
                WHEN 13 THEN 'Agreement not needed (invoice payment)'
                WHEN 14 THEN 'Agreement information incomplete'
                WHEN 15 THEN 'Transfer'
                WHEN 16 THEN 'Agreement Recreated'
                WHEN 17 THEN 'Signature missing'
                ELSE 'UNDEFINED'
        END AS Current_Payment_Agreement_State,
        pea_email.txtvalue AS email,
        pea_mobile.txtvalue AS mobile,
        longtodatec(t2.maxcheckin, p.center) AS Last_Checkin_Date,
        t2.Last_Open_Dates,
        t2.art_unsettled,
        cc.amount AS cc_amount,
		ar.balance
FROM
(
        SELECT
                t1.center,
                t1.id,
                t1.Subscription_Names,
                t1.Last_Open_Dates,
                t1.art_unsettled,
                MAX(c.checkin_time) AS maxcheckin
        FROM
        (
                SELECT 
                        em.center,
                        em.id,
                        string_agg(DISTINCT pd.Name,' ; ') AS Subscription_Names,
                        string_agg(TO_CHAR(longtodateC(art.trans_time,art.center),'YYYY-MM-DD'), ' ; ' ORDER BY em.center, em.id) AS Last_Open_Dates,
                        sum(art.unsettled_amount) AS art_unsettled
                FROM eligible_members em
                LEFT JOIN subscriptions s
                        ON s.owner_center = em.center AND s.owner_id = em.id AND s.state IN (2,4,8)
                LEFT JOIN products pd
                        ON pd.center = s.subscriptiontype_center AND pd.id = s.subscriptiontype_id
                LEFT JOIN account_receivables ar
                        ON ar.customercenter = em.center AND ar.customerid = em.id
                LEFT JOIN ar_trans art
                        ON art.center = ar.center AND art.id = ar.id AND art.STATUS NOT IN ('CLOSED')
                GROUP BY
                        em.center,
                        em.id
        ) t1
        LEFT JOIN checkins c
                ON c.person_center = t1.center AND c.person_id = t1.id
        GROUP BY
                t1.center,
                t1.id,
                t1.Subscription_Names,
                t1.Last_Open_Dates,
                t1.art_unsettled
) t2
JOIN params par ON t2.center = par.id
JOIN persons p ON p.center = t2.center AND p.id = t2.id
JOIN account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
LEFT JOIN person_ext_attrs pea_email ON pea_email.PERSONCENTER = p.center AND pea_email.PERSONID = p.id  AND pea_email.NAME = '_eClub_Email'
LEFT JOIN person_ext_attrs pea_mobile ON pea_mobile.PERSONCENTER = p.center AND pea_mobile.PERSONID = p.id AND pea_mobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN cashcollectioncases cc ON cc.personcenter = p.center AND cc.personid = p.id AND cc.missingpayment = true AND cc.CLOSED = false