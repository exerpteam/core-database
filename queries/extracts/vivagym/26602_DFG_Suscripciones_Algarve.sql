-- SEGUROS PORTUGAL
SELECT 
    p.center,
    p.id,
    p.external_id,
    TO_CHAR(s.start_date, 'YYYY-MM-DD') as start_date,
    pea_date.txtvalue                    AS "insurance_renewal_date",
    CASE 
        WHEN NULLIF(pea_amount.txtvalue, '') IS NULL THEN NULL
        ELSE CAST(REPLACE(pea_amount.txtvalue, ',', '.') AS NUMERIC)          -- a NUMERIC
    END                                  AS "insurance_renewal_amount"
FROM vivagym.persons p
JOIN vivagym.subscriptions s
    ON p.center = s.owner_center AND p.id = s.owner_id
JOIN vivagym.subscriptiontypes st
    ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
JOIN person_ext_attrs AS pea_date
    ON pea_date.personcenter = p.center
   AND pea_date.personid     = p.id
   AND pea_date.name         = 'insurancerenewaldate'
   --AND pea_date.txtvalue     IS NOT NULL
   --AND pea_date.txtvalue     <> ''
LEFT JOIN person_ext_attrs AS pea_amount
    ON pea_amount.personcenter = p.center
   AND pea_amount.personid     = p.id
   AND pea_amount.name         = 'insurancerenewalamount'
   --AND pea_amount.txtvalue     IS NOT NULL
   --AND pea_amount.txtvalue     <> ''
WHERE
    p.persontype NOT IN (2)
    AND p.status NOT IN (4,5,7,8)
    AND p.center IN (800, 801, 802, 802, 803, 804)
    AND s.state IN (2,4)
    AND st.st_type NOT IN (0)
ORDER BY s.start_date