WITH
    Active_members AS
    (
        SELECT
            p.center,
            p.id
        FROM
            PERSONS p
        JOIN
            state_change_log per_scl
        ON
            per_scl.center = p.center
        AND per_scl.id = p.id
        AND per_scl.entry_type = 1
        AND per_scl.stateid = 1
        AND (
                to_timestamp(per_scl.entry_end_time/1000) :: DATE > :from_date
            OR  per_scl.entry_end_time IS NULL)
        AND to_timestamp(per_scl.entry_start_time/1000) :: DATE <= :to_date
        WHERE
            p.center IN (:scope)
    )
    ,
    Induction_attr AS
    (
        SELECT
            pcl.person_center,
            pcl.person_id,
            pcl.new_value
        FROM
            person_change_logs pcl
        WHERE
            pcl.change_attribute = 'Induction'
        AND pcl.person_center IN (:scope)
        AND pcl.entry_time =
            (
                SELECT
                    MAX(pcl_max.entry_time)
                FROM
                    person_change_logs pcl_max
                WHERE
                    pcl_max.person_center = pcl.person_center
                AND pcl_max.person_id = pcl.person_id
                AND pcl_max.change_attribute = 'Induction'
                AND to_timestamp(pcl_max.entry_time/1000) :: DATE <= :to_date )
    )

SELECT DISTINCT
    :from_date :: DATE    AS "From_Date",
    :to_date :: DATE      AS "To_Date",
    c.name                AS Centername,
    p.center ||'p'|| p.id AS Id,
    p.external_id         AS ExternalId,
    p.firstname           AS Firstname,
    p.lastname            AS Lastname,
    email.txtvalue        AS Email,
    'ACTIVE'              AS PERSON_STATUS,
    prod.name             AS Subscription,
    'ACTIVE'              AS SUBSCRIPTION_STATE,
    longtodate(s.creation_time) AS CREATION_DATE,
    s.start_date                AS START_DATE,
    CASE ind.new_value
        WHEN '1'
        THEN 'NON ASSEGNATO'
        WHEN '2'
        THEN 'ASSEGNATO'
        WHEN '3'
        THEN 'DA PRENOTARE'
        ELSE 'Undefined'
    END AS INDUCTION_VALUE
FROM
    Active_members am
JOIN
    Persons p
ON
    p.center = am.center
AND p.id = am.id
JOIN
    centers c
ON
    c.id = am.center
AND c.country = 'IT'
JOIN
    Induction_attr ind
ON
    ind.person_center = am.center
AND ind.person_id = am.id
JOIN
    subscriptions s
ON
    s.owner_center = am.center
AND s.owner_id = am.id
AND s.start_date BETWEEN :from_date AND :to_date
AND (
        s.end_date >= :to_date
    OR  s.end_date IS NULL)
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products prod
ON
    prod.center = st.center
AND prod.id = st.id
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
ORDER BY
Id,
Subscription