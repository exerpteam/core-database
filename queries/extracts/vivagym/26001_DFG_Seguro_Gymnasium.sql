-- SOCIOS MIGRADOS DE GYMNASIUM CON FECHA DE RENOVACIÓN DE SEGURO INFORMADA
SELECT 
    TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD') AS "TODAY",
    pea_date.personcenter                AS "pea_center",
    (p.id)::text                         AS "pea_personid",            -- a texto
    p.external_id                        AS "external_id",
    pea_date.txtvalue                    AS "insurance_renewal_date",
    CASE 
        WHEN NULLIF(pea_amount.txtvalue, '') IS NULL THEN NULL
        ELSE CAST(REPLACE(pea_amount.txtvalue, ',', '.') AS NUMERIC)          -- a NUMERIC
    END                                  AS "insurance_renewal_amount",
    p.fullname                           AS "Full Name"
FROM persons p
JOIN person_ext_attrs AS pea_date
    ON pea_date.personcenter = p.center
   AND pea_date.personid     = p.id
   AND pea_date.name         = 'insurancerenewaldate'
   AND pea_date.txtvalue     IS NOT NULL
   AND pea_date.txtvalue     <> ''
LEFT JOIN person_ext_attrs AS pea_amount
    ON pea_amount.personcenter = p.center
   AND pea_amount.personid     = p.id
   AND pea_amount.name         = 'insurancerenewalamount'
   AND pea_amount.txtvalue     IS NOT NULL
   AND pea_amount.txtvalue     <> '';



	-- Check that today we are between the migration date and the insurance renewal date for the member
	-- Specify the Migration Date here to check it is in the past
--	AND TO_DATE('2025-11-20', 'YYYY-MM-DD') < CURRENT_DATE
	-- Renewal Date in the future (already paid)
--	AND TO_DATE(pea.txtvalue, 'YYYY-MM-DD') > CURRENT_DATE
--	AND p.external_id = '103342805'