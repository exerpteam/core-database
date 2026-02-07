-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')-interval '7 days',
            'YYYY-MM-DD'), c.id) AS BIGINT) AS cutDate,
            c.id                            AS centerid,
            c.name                          AS centerName
            --c.email                               AS centeremail,
            --c.manager_center ||'p'|| c.manager_id AS managerId,
            --staff.fullname                        AS managerName,
            --staff.external_id                     AS managerExternalId
        FROM
            centers c
            /*JOIN
            persons staff
            ON
            staff.center = c.manager_center
            AND staff.id = c.manager_id */
        WHERE
            c.id IN (:scope)
    )
SELECT
    p.external_id  AS "Member ID",
    op.txtvalue    AS "GUID",
    p.firstname    AS "Firstname",
    p.lastname     AS "Lastname",
    email.txtvalue AS "Email",
    par.centername AS "Center name",
    --par.centeremail       AS "Center email",
    --par.managerExternalId AS "General Manager ID",
    --par.managerName       AS "General Manager name",
    p.center ||'p'|| p.id AS "Member p-number",
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END             AS "Persontype",
    cl.name         AS "Clearinghouse",
    pag.creditor_id AS "Creditor",
    CASE pag.state
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END                                                                AS "Payment agreement state",
    TO_CHAR(longtodateC(agl.entry_time, pag.center), 'DD/MM/YYYY HH:MI AM') AS "Cancellation time" 
    ,
    emp.center ||'emp'|| emp.id AS "Staff Employee ID",
    sta.fullname                AS "Staff Fullname",
    sub.name                    AS "Subscription name",
    sub.subscription_state      AS "Subscription state",
    sub.billed_until_date       AS "Subscription billed until",
    sub.end_date                AS "Subscription end date",
    fusub.name                  AS "Future subscriptions",
    com.center ||'p'|| com.id   AS "Company ID",
    com.fullname                AS "Company name",
    sub.price AS "Subscription normal price",
    CASE
    WHEN sub.subscription_price < sub.price
    THEN sub.subscription_price
    ELSE NULL
    END AS "Subscription discount price"
FROM
    persons p
JOIN
    params par
ON
    par.centerID = p.center
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    payment_accounts pa
ON
    pa.center = ar.center
AND pa.id = ar.id
JOIN
    payment_agreements pag
ON
    pag.center = pa.active_agr_center
AND pag.id = pa.active_agr_id
AND pag.subid = pa.active_agr_subid
JOIN
    (   SELECT
            acl.agreement_center,
            acl.agreement_id,
            acl.agreement_subid,
            acl.entry_time,
            acl.employee_center,
            acl.employee_id,
            RANK() over (
                     PARTITION BY
                         acl.agreement_center,
                         acl.agreement_id,
                         acl.agreement_subid
                     ORDER BY
                         acl.entry_time DESC) AS ranking
        FROM
            agreement_change_log acl ) agl
ON
    agl.agreement_center = pag.center
AND agl.agreement_id = pag.id
AND agl.agreement_subid = pag.subid
AND agl.ranking = 1
JOIN
    clearinghouses cl
ON
    cl.id = pag.clearinghouse
LEFT JOIN
    employees emp
ON
    emp.center = agl.employee_center
AND emp.id = agl.employee_id
JOIN
    persons sta
ON
    sta.center = emp.personcenter
AND sta.id = emp.personid
LEFT JOIN
    person_ext_attrs op
ON
    op.personcenter = p.center
AND op.personid = p.id
AND op.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
LEFT JOIN
    (   SELECT
            s.owner_center,
            s.owner_id,
            pr.name,
            s.billed_until_date,
            CASE s.STATE 
                WHEN 2 
                THEN 'ACTIVE' 
                WHEN 3 
                THEN 'ENDED' 
                WHEN 4 
                THEN 'FROZEN' 
                WHEN 7 
                THEN 'WINDOW' 
                WHEN 8 
                THEN 'CREATED' 
                ELSE 'Undefined' 
            END AS subscription_state,
            s.start_date,
            s.end_date,
            s.subscription_price,
            pr.price,
            RANK() over (
                     PARTITION BY
                         s.owner_center,
                         s.owner_id
                     ORDER BY
                         s.start_date DESC) ranking
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        WHERE
            s.state NOT IN (8)) sub
ON
    sub.owner_center = p.center
AND sub.owner_id = p.id
AND sub.ranking = 1
LEFT JOIN
    (   SELECT
            fus.owner_center,
            fus.owner_id,
            fupr.name,
            RANK() over (
                     PARTITION BY
                         fus.owner_center,
                         fus.owner_id
                     ORDER BY
                         fus.start_date ASC) ranking
        FROM
            subscriptions fus
        JOIN
            subscriptiontypes fust
        ON
            fust.center = fus.subscriptiontype_center
        AND fust.id = fus.subscriptiontype_id
        JOIN
            products fupr
        ON
            fupr.center = fust.center
        AND fupr.id = fust.id
        WHERE
            fus.state = 8) fusub
ON
    fusub.owner_center = p.center
AND fusub.owner_id = p.id
AND fusub.ranking = 1
LEFT JOIN
    (   SELECT
            rel.center AS per_center,
            rel.id AS per_id,
            co.center,
            co.id,
            co.fullname
        FROM
            relatives rel
        JOIN
            persons co
        ON
            co.center = rel.relativecenter
        AND co.id = rel.relativeid
        WHERE
            rel.rtype = 3
        AND rel.status = 1
        AND co.sex = 'C') com
ON
    com.per_center = p.center
AND com.per_id = p.id
AND p.persontype = 4
WHERE
    pag.state NOT IN (1,2,4,13)
AND agl.entry_time >= par.cutDate
AND p.status NOT IN (4,5,7,8)
ORDER BY
    p.center