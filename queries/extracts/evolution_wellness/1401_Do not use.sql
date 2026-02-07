WITH
    params AS MATERIALIZED
    (
        SELECT
            DATE_TRUNC('month',(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'))) AS cut_date,
            c.id                                                             AS center_Id,
            c.name                                                           AS center_name
        FROM
            centers c
    )
SELECT
    ss.subscription_center ||'ss'|| ss.subscription_id AS subscription_id,
    par.center_name                                    AS club_name,
    emp.fullname                                       AS sales_person,
    pea.txtvalue                                       AS marketing_source,
    ss.sales_date                                      AS commisionable_join_date,
    pr.name                                            AS access_type,
    CASE
        WHEN ss.subscription_type_type = 1
        THEN EXTRACT(YEAR FROM age((ss.start_date + ss.binding_days), ss.start_date))*12 + extract
            (MONTH FROM age((ss.start_date + ss.binding_days), ss.start_date))
        WHEN ss.subscription_type_type = 0
        THEN EXTRACT(YEAR FROM age(ss.end_date, ss.start_date))*12 + extract(MONTH FROM age
            (ss.end_date, ss.start_date))
    END AS membership_length,
    CASE
        WHEN ss.subscription_type_type = 1
        THEN 'Pay Monthly'
        WHEN ss.subscription_type_type = 0
        THEN 'Pay Lump Sum'
        ELSE 'Unknown'
    END AS plan_payment_type,
    CASE
        WHEN agr.clearinghouse IN (601,
                                   605,
                                   801,
                                   602,
                                   603,
                                   604,
                                   802,
                                   804,
                                   803)
        THEN 'Credit Card'
        ELSE 'Cash'
    END             AS payment_type,
    ss.price_period AS plan_dues
FROM
    subscription_sales ss
JOIN
    params par
ON
    par.center_id = ss.subscription_center
JOIN
    employees em
ON
    em.center = ss.employee_center
AND em.id = ss.employee_id
JOIN
    persons emp
ON
    emp.center = em.personcenter
AND emp.id = em.personid
JOIN
    subscriptiontypes st
ON
    st.center = ss.subscription_type_center
AND st.id = ss.subscription_type_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
LEFT JOIN
    (
        SELECT
            ar.customercenter,
            ar.customerid,
            pag.clearinghouse
        FROM
            account_receivables ar
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
        AND pag.subid = pa.active_agr_subid ) agr
ON
    agr.customercenter = ss.owner_center
AND agr.customerid = ss.owner_id
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = ss.owner_center
AND pea.personid = ss.owner_id
AND pea.name = 'Source'
WHERE
    ss.cancellation_date IS NULL
AND ss.type = 1
AND ss.sales_date >= par.cut_date
AND ss.subscription_center IN (:scope)
ORDER BY
ss.sales_date,
ss.subscription_center