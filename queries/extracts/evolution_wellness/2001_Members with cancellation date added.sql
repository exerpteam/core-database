WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS currentDate,
            c.id                                       AS centerid
        FROM
            centers c
    )
SELECT
    p.fullname                                  AS "Member name",
    mob.txtvalue                                AS "Mobile phone",
    email.txtvalue                              AS "Email",
    p.center ||'p'|| p.id                       AS "Member ID",
    pr.name                                     AS "Subscription name",
    longtodateC(sc.change_time, p.center)       AS "Cancellation date",
    s.end_date                                  AS "Stop date",
    sc.employee_center ||'emp'|| sc.employee_id AS "Stopped By Employee ID",
    sta.fullname                                AS "Stopped By Employee name"
FROM
    persons p
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    params par
ON
    par.centerid = s.center
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
JOIN
    subscription_change sc
ON
    sc.old_subscription_center = s.center
AND sc.old_subscription_id = s.id
JOIN
    employees emp
ON
    emp.center = sc.employee_center
AND emp.id = sc.employee_id
JOIN
    persons sta
ON
    sta.center = emp.personcenter
AND sta.id = emp.personid
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs mob
ON
    mob.personcenter = p.center
AND mob.personid = p.id
AND mob.name = '_eClub_PhoneSMS'
WHERE
    s.end_date = :stopDate
AND sc.type = 'END_DATE'
AND st.st_type = 1
AND s.end_date IS NOT NULL
AND s.end_date >= par.currentDate
AND s.sub_state != 8
AND sc.cancel_time IS NULL
AND p.center IN (:scope)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions sub
        WHERE
            sub.owner_center = p.center
        AND sub.owner_id = p.id
        AND (
                sub.end_date IS NULL
            OR  sub.start_date > par.currentDate) )