SELECT
    p.external_id,
    p.center || 'p' || p.id AS personid,
    (
        CASE STATUS
            WHEN 1
            THEN 'Active'
            WHEN 2
            THEN 'Inactive'
            WHEN 3
            THEN 'TemporaryInactive'
            ELSE 'Unknown'
        END)   AS PERSON_STATUS,
    s.end_date AS subscription_end_date,
    pea.txtvalue
FROM
    vivagym.event_log el
JOIN
    vivagym.subscriptions s
ON
    el.reference_center = s.center
AND el.reference_id = s.id
JOIN
    vivagym.persons p
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    vivagym.person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_Email'
JOIN
    vivagym.subscription_change sc
ON
    s.center = sc.old_subscription_center
AND s.id = sc.old_subscription_id
AND sc.type = 'END_DATE'
AND sc.employee_center = 100
AND sc.employee_id = 1
WHERE
    el.event_configuration_id = 1601
AND el.time_stamp > DATETOLONGC(TO_CHAR(TO_DATE('2021-08-13','YYYY-MM-DD'),'YYYY-MM-DD'),
    el.reference_center)