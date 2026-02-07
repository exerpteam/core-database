WITH
    params AS materialized
    (
        SELECT
            getstartofday((:date_from)::DATE::text, c.id) AS date_from,
            getendofday((:date_to)::DATE::text, c.id)     AS date_to,
            c.id
        FROM
            centers c
               WHERE
               c.id IN (:scope)
    )
SELECT
    c.name                                               AS "Club",
    c.id                                                                           AS "Club Number",
    p.center||'p'||p.id                                                          AS "Member number",
    p.external_id                                                           AS "Member external ID",
    pea_sal.txtvalue                                                 AS "Title",
    p.firstname                                                                     AS "First Name",
    p.lastname                                                                       AS "Last Name",
    pem.fullname                                                  AS "Operator",
    longtodateC(sc.change_time, c.id)::DATE                        AS "Cancellation Requested Date",
    (CURRENT_DATE at TIME zone c.time_zone)::DATE - longtodateC(sc.change_time, c.id)::DATE AS
    "Days Since Requested",
    s.end_date                                                 AS "Cancellation Scheduled Date",
    (CURRENT_DATE at TIME zone c.time_zone)::DATE - s.end_date AS "Days Since Cancelled",
    CASE
        WHEN pea_channel.txtvalue = 'email'
        THEN 'Yes'
        ELSE 'No'
    END           AS "Is Email Preferred",
    pea4.txtvalue AS "Email Address",
    CASE
        WHEN pcl.change_attribute = 'cancellationjourney3'
        THEN 'Cancellation confirmed'
        WHEN pcl.new_value ='2'
        THEN 'Cancellation confirmed'
        ELSE NULL
    END AS "Action",
    CASE
        WHEN pcl.new_value ='1'
        THEN 'No Answer'
        WHEN pcl.new_value ='2'
        THEN 'Do not call back'
        WHEN pcl.new_value ='3'
        THEN 'Call back'
        WHEN pcl.new_value ='4'
        THEN 'Saved'
        ELSE NULL
    END                                                               AS "Reason",
    longtodateC(pcl.entry_time ,c.id)::DATE AS "Action Date"
FROM
    subscriptions s
JOIN
    params
ON
    params.id=s.center
JOIN
    evolutionwellness.subscriptiontypes st
ON
    s.subscriptiontype_center=st.center
AND s.subscriptiontype_id=st.id
JOIN
    evolutionwellness.subscription_change sc
ON
    sc.old_subscription_center=s.center
AND sc.old_subscription_id=s.id
JOIN
    persons p
ON
    s.owner_center=p.center
AND s.owner_id=p.id
JOIN
    centers c
ON
    p.center=c.id
LEFT JOIN
    evolutionwellness.person_ext_attrs pea_sal
ON
    p.center=pea_sal.personcenter
AND p.id=pea_sal.personid
AND pea_sal.name = '_eClub_Salutation'
LEFT JOIN
    evolutionwellness.person_ext_attrs pea_channel
ON
    p.center=pea_channel.personcenter
AND p.id=pea_channel.personid
AND pea_channel.name = '_eClub_DefaultMessaging'
LEFT JOIN
    PERSON_EXT_ATTRS pea4
ON
    pea4.name ='_eClub_Email'
AND pea4.PERSONCENTER = p.center
AND pea4.PERSONID =p.id
JOIN
    employees em
ON
    sc.employee_center=em.center
AND sc.employee_id=em.id
JOIN
    persons pem
ON
    pem.center=em.personcenter
AND pem.id=em.personid
LEFT JOIN
    Lateral
    (
        SELECT
            pcl.entry_time,
            pcl.change_attribute,
            pcl.new_value
        FROM
            evolutionwellness.person_change_logs pcl
        WHERE
            pcl.change_attribute LIKE 'cancellationjourney%'
        AND pcl.person_center=p.center
        AND pcl.person_id=p.id
        AND pcl.entry_time > sc.change_time
        ORDER BY
            pcl.entry_time DESC limit 1 ) AS pcl
ON
    true
WHERE
    sc.TYPE = 'END_DATE'
AND sc.cancel_time IS NULL
AND sc.change_time >= params.date_from
AND sc.change_time <= params.date_to
AND s.end_date > (CURRENT_DATE at TIME zone c.time_zone)::DATE
AND st.st_type IN (1,2,3)
UNION ALL
-----------------------saved-------------------------------------------------------------
SELECT
    c.name                                               AS "Club",
    c.id                                                                           AS "Club Number",
    p.center||'p'||p.id                                                          AS "Member number",
    p.external_id                                                           AS "Member external ID",
    pea_sal.txtvalue                                                 AS "Title",
    p.firstname                                                                     AS "First Name",
    p.lastname                                                                       AS "Last Name",
    pem.fullname                                                  AS "Operator",
    longtodateC(sc.change_time, c.id)::DATE                        AS "Cancellation Requested Date",
    (CURRENT_DATE at TIME zone c.time_zone)::DATE - longtodateC(sc.change_time, c.id)::DATE AS
    "Days Since Requested",
    sc.effect_date                                                 AS "Cancellation Scheduled Date",
    (CURRENT_DATE at TIME zone c.time_zone)::DATE - sc.effect_date AS "Days Since Cancelled",
    CASE
        WHEN pea_channel.txtvalue = 'email'
        THEN 'Yes'
        ELSE 'No'
    END                                     AS "Is Email Preferred",
    pea4.txtvalue                           AS "Email Address",
    'Cancellation Saved'                    AS "Action",
    'Saved'                                 AS "Reason",
    longtodateC(pcl.entry_time, c.id)::DATE AS "Action Date"
FROM
    subscriptions s
JOIN
    params
ON
    params.id=s.center
JOIN
    evolutionwellness.subscriptiontypes st
ON
    s.subscriptiontype_center=st.center
AND s.subscriptiontype_id=st.id
JOIN
    persons p
ON
    s.owner_center=p.center
AND s.owner_id=p.id
JOIN
    centers c
ON
    p.center=c.id
JOIN
    lateral
    (
        SELECT
            change_time,
            effect_date,
            employee_center,
            employee_id
        FROM
            evolutionwellness.subscription_change sc
        WHERE
            sc.old_subscription_center=s.center
        AND sc.old_subscription_id=s.id
        AND sc.TYPE = 'END_DATE'
        AND sc.cancel_time IS NOT NULL
        AND sc.change_time >= params.date_from
        AND sc.change_time <= params.date_to
        AND sc.effect_date > (CURRENT_DATE at TIME zone c.time_zone)::DATE
        ORDER BY
            sc.cancel_time DESC limit 1) AS sc
ON
    true
LEFT JOIN
    evolutionwellness.person_ext_attrs pea_sal
ON
    p.center=pea_sal.personcenter
AND p.id=pea_sal.personid
AND pea_sal.name = '_eClub_Salutation'
LEFT JOIN
    evolutionwellness.person_ext_attrs pea_channel
ON
    p.center=pea_channel.personcenter
AND p.id=pea_channel.personid
AND pea_channel.name = '_eClub_DefaultMessaging'
LEFT JOIN
    PERSON_EXT_ATTRS pea4
ON
    pea4.name ='_eClub_Email'
AND pea4.PERSONCENTER = p.center
AND pea4.PERSONID =p.id
JOIN
    employees em
ON
    sc.employee_center=em.center
AND sc.employee_id=em.id
JOIN
    persons pem
ON
    pem.center=em.personcenter
AND pem.id=em.personid
JOIN
    Lateral
    (
        SELECT
            pcl.entry_time
        FROM
            evolutionwellness.person_change_logs pcl
        WHERE
            pcl.change_attribute LIKE 'cancellationjourney%'
        AND pcl.person_center=p.center
        AND pcl.person_id=p.id
        AND pcl.new_value='4'
        AND pcl.entry_time > sc.change_time
        ORDER BY
            pcl.entry_time DESC limit 1 ) AS pcl
ON
    true
WHERE
    st.st_type IN (1,2,3)
AND s.end_date IS NULL