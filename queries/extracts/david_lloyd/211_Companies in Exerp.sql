-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    P.CENTER||'p'||P.ID                                                              AS "Exerp Id",
    P.FULLNAME                                                                       AS "Company Name",
    P.external_id,
p.ssn AS "CompanyID",
    COALESCE(active_member.total, 0)                                                 AS "Total Active Employees",
    TO_CHAR(longtodateTZ(je.CREATION_TIME,'Europe/London'),'DD/MM/YYYY')             AS "Creation Date",
    cag.center||'p'||cag.id||'rpt'||cag.subid                                       AS "Company Agreement Id",
    cag.name                                                                          AS "Company Agreement Name",
    cag.ref                                                                           AS "Company Ref"
FROM
    PERSONS P
LEFT JOIN person_ext_attrs pet
    ON p.center = pet.personcenter AND p.id = pet.personid AND pet.name = '_eClub_Comment'
JOIN ACCOUNT_RECEIVABLES ar
    ON ar.CUSTOMERCENTER = p.center AND ar.CUSTOMERID = p.id
JOIN PAYMENT_AGREEMENTS pag
    ON pag.center = ar.center AND pag.id = ar.id
JOIN PAYMENT_ACCOUNTS pa
    ON pa.active_agr_center = pag.center AND pa.active_agr_id = pag.id AND pa.active_agr_subid = pag.subid
LEFT JOIN payment_cycle_config pcc
    ON pcc.id = pag.payment_cycle_config_id
LEFT JOIN (
    SELECT
        r.center,
        r.id,
        SUM(CASE WHEN p1.status = 1 AND p1.persontype = 4 THEN 1 ELSE 0 END) AS total
    FROM persons p1
    LEFT JOIN relatives r
        ON p1.center = r.relativecenter
       AND p1.id     = r.relativeid
       AND r.rtype   = 2
       AND r.status  = 1
    GROUP BY r.center, r.id
) active_member
    ON active_member.center = p.center
   AND active_member.id     = p.id
LEFT JOIN JOURNALENTRIES je
    ON p.ID = je.PERSON_ID AND p.CENTER = je.PERSON_CENTER AND je.Name IN ('Company created')

-- NEW: one row per company-agreement
LEFT JOIN COMPANYAGREEMENTS cag
    ON cag.center = p.center
   AND cag.id     = p.id

WHERE
    P.SEX = 'C';
