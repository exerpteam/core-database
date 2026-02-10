-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')-interval '1 days',
            'YYYY-MM-DD'), c.id) AS BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'), 'YYYY-MM-DD'),
            c.id) AS BIGINT) AS toDate,
            c.id             AS CenterID
        FROM
            centers c
        WHERE
            c.country = 'PT'
    )
SELECT
    p.external_id AS "Member External ID",
    p.fullname    AS "Member full name",
    p.center      AS "Member center ID",
    p.national_id AS "Member NIF",
    pno.txtvalue  AS "Member Passport number",
    p.address1    AS "Member Address line 1",
    p.address2    AS "Member Address line 2",
    p.country     AS "Member Country",
    p.zipcode     AS "Member Zip code",
    p.city        AS "Member City",
    alt.txtvalue  AS "NIF customer name",
    aal.txtvalue  AS "NIF fiscal number",
    nia1.txtvalue AS "NIF address 1",
    nia2.txtvalue AS "NIF address 2",
    niz.txtvalue  AS "NIF postcode",
    nic.txtvalue  AS "NIF city"
FROM
    persons p
LEFT JOIN
    vivagym.person_ext_attrs pno
ON
    pno.personcenter = p.center
AND pno.personid = p.id
AND pno.name = '_eClub_PassportNumber'
LEFT JOIN
    vivagym.person_ext_attrs alt
ON
    alt.personcenter = p.center
AND alt.personid = p.id
AND alt.name = 'ALTNIFNAME'
LEFT JOIN
    vivagym.person_ext_attrs aal
ON
    aal.personcenter = p.center
AND aal.personid = p.id
AND aal.name = 'AALTNIFNBR'
LEFT JOIN
    vivagym.person_ext_attrs nia1
ON
    nia1.personcenter = p.center
AND nia1.personid = p.id
AND nia1.name = 'NIFADD1'
LEFT JOIN
    vivagym.person_ext_attrs nia2
ON
    nia2.personcenter = p.center
AND nia2.personid = p.id
AND nia2.name = 'NIFADD2'
LEFT JOIN
    vivagym.person_ext_attrs niz
ON
    niz.personcenter = p.center
AND niz.personid = p.id
AND niz.name = 'NIFZIP'
LEFT JOIN
    vivagym.person_ext_attrs nic
ON
    nic.personcenter = p.center
AND nic.personid = p.id
AND nic.name = 'NIFCITY'
WHERE
    p.center IN (:scope)
AND p.status IN (1,3)
AND EXISTS
    (
        SELECT
            1
        FROM
            vivagym.person_change_logs pcl
        JOIN
            params
        ON
            params.centerID = pcl.person_center
        WHERE
            pcl.change_attribute IN ('FIRST_NAME',
                                     'LAST_NAME',
                                     'NATIONAL_ID',
                                     '_eClub_PassportNumber',
                                     'ADDRESS_1',
                                     'ADDRESS_2',
                                     'COUNTRY',
                                     'ZIP_CODE',
                                     'CITY',
                                     'ALTNIFNAME',
                                     'AALTNIFNBR',
                                     'NIFADD1',
                                     'NIFADD2',
                                     'NIFZIP',
                                     'NIFCITY')
        AND pcl.entry_time BETWEEN params.fromDate AND params.toDate
        AND pcl.person_center = p.center
        AND pcl.person_id = p.id

UNION ALL
        
        SELECT
            1
        FROM
            vivagym.state_change_log scl
        JOIN
            params
        ON
            params.centerID = scl.center
        WHERE
            scl.entry_type = 1
        AND scl.entry_start_time BETWEEN params.fromDate AND params.toDate
        AND scl.center = p.center
        AND scl.id = p.id)