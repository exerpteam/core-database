-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS cutdate,
            c.id                                       AS center_id
        FROM
            centers c
    )
SELECT
    pr.name            AS subscription_name,
    s.start_date       AS subscription_start_date,
    s.end_date         AS subscription_end_date,
    s.binding_end_date AS subscription_binding_end_date,
    prg.name           AS product_group_name,
    p.external_id      AS member_externalID,
    p.firstname        AS member_firstname,
    p.lastname         AS member_lastname,
    email.txtvalue     AS email,
    mob.txtvalue       AS mobile_number
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
    par.center_id = s.center
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
    product_and_product_group_link prgl
ON
    prgl.product_center = pr.center
AND prgl.product_id = pr.id
JOIN
    product_group prg
ON
    prg.id = prgl.product_group_id
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
    (
        s.end_date IS NULL
    OR  s.end_date >= par.cutdate)
AND prg.name LIKE '%Loyalty%'
AND p.external_id IN (:externalID)