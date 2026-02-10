-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.external_id,
        p.center || 'p' || p.id AS personid,
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        pag.clearinghouse_ref AS token,
        pm.paymentmethod,
        (CASE WHEN pag.state = 2 THEN 'SENT' WHEN pag.state=4 THEN 'OK' END) AS pag_state,
        pag.individual_deduction_day,
        pea.txtvalue
FROM puregym_switzerland.persons p
JOIN puregym_switzerland.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN puregym_switzerland.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN puregym_switzerland.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
JOIN puregym_switzerland.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_Email'
JOIN 
(
        SELECT 
                DISTINCT 
                token, paymentmethod
        FROM public.payment_method_rollout
) pm ON pag.clearinghouse_ref = pm.token
WHERE
        pag.clearinghouse = 201
        AND pag.center NOT IN (6004)
        AND pag.state IN (2,4)
        AND length(pag.clearinghouse_ref) > 16