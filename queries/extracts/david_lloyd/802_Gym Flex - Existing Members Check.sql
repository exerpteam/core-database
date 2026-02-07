-- This is the version from 2026-02-05
--  
WITH
    raw_data AS
    ( SELECT
        CAST(STRING_TO_ARRAY(trim(trim(CAST(($$member_attributes$$) AS TEXT),'('),')'),E'\n') AS TEXT) AS data
    )
    , split_rows AS
    ( SELECT
        trim(trim(split_part(person, ';', 1),'{'),'"')                           AS firstname
        , split_part(person, ';', 2)                                             AS lastname
        , to_date(trim(trim(split_part(person, ';', 3),'}'),'"') , 'DD-MM-YYYY') AS birthdate
        , trim(trim(trim(person,'{'),'}'),'"')                                   AS person
    FROM
        (SELECT
            unnest(string_to_array(data, ',')) AS person
        FROM
            raw_data)
    )
SELECT
    p.center
    ,p.id
    ,split_rows.person                                AS input_value
    , split_rows.firstname                            AS "Input First Name"
    ,split_rows.lastname                              AS "Input Last Name"
    ,split_rows.birthdate                             AS "Input Birth Date"
    ,p.center IS NOT NULL                             AS "Person Exists"
    ,p.external_id                                    AS "Person External ID"
    , COALESCE(legacyPersonId.txtvalue,p.external_id) AS "Contact GUID"
    ,s.center IS NOT NULL                             AS "Package Exists"
    ,CASE s.state
        WHEN 2
        THEN 'Active'
        WHEN 4
        THEN 'Frozen'
    END           AS "Package State"
    , pr.GLOBALID AS "Package Code"
    , pr.name     AS "Package Description"
FROM
    split_rows
LEFT JOIN
    persons p
ON
    p.firstname = split_rows.firstname
AND p.lastname = split_rows.lastname
AND p.birthdate = split_rows.birthdate
AND p.current_person_center = center
AND p.current_person_id = p.id
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center=legacyPersonId.PERSONCENTER
AND p.id=legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
LEFT JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.state IN (2,4)
LEFT JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id