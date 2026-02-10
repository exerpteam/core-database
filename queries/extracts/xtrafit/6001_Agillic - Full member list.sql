-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS currentDate,
            c.id                                       AS centerid
        FROM
            centers c
    )
    ,
    subs AS materialized
    (
        SELECT
            *
        FROM
            (
                SELECT
                    s.owner_center,
                    s.owner_id,
                    s.start_date,
                    s.end_date,
                    pr.name,
                    pr.external_id,
                    rank() over (partition BY s.owner_center, s.owner_id ORDER BY s.start_date DESC
                    ) AS ranking
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
                    s.state != 8
                AND s.sub_state NOT IN (6,7,8)) t
        WHERE
            t.ranking = 1
    )
SELECT
    p.external_id AS "PERSON_ID",
    p.center AS "CENTER_ID",
    p.firstname AS "VORNAME_MITGLIED",
    p.lastname AS "NACHNAME_MITGLIED",
    p.sex AS "GESCHLECHT",
    email.txtvalue AS "EMAIL",
    p.birthdate AS "GEBURTSDATUM",
    mob.txtvalue AS "TELEFONNUMMER",
    subs.start_date AS "SUBSCRIPTION_START_DATE",
    subs.end_date AS "SUBSCRIPTION_END_DATE",
    subs.name AS "SUBSCRIPTION_NAME",
    subs.external_id AS "SUBSCRIPTION_TYPE"
FROM
    persons p
LEFT JOIN
    person_ext_attrs mob
ON
    mob.personcenter = p.center
AND mob.personid = p.id
AND mob.name = '_eClub_PhoneSMS'
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
LEFT JOIN
    subs
ON
    subs.owner_center = p.center
AND subs.owner_id = p.id
WHERE
    p.status NOT IN (4,5,7,8)
AND p.center IN (:scope)