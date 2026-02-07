SELECT
        longtodatec(el.time_stamp, el.reference_center) AS Sync_date,
        i.payer_center || 'p' || i.payer_id AS PersonId,
        cp.external_id,
        i.center || 'inv' || i.id AS Referencia,
        SUM(il.total_amount) AS TotalAmount,
        i.fiscal_reference
FROM
        vivagym.event_type_config etc
JOIN
        vivagym.event_log el ON el.event_configuration_id = etc.id
JOIN
        vivagym.invoices i ON el.reference_center = i.center AND el.reference_id = i.id
JOIN
        vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
LEFT JOIN 
        vivagym.persons p ON i.payer_center = p.center AND i.payer_id = p.id
LEFT JOIN 
        vivagym.persons cp ON p.current_person_center = cp.center AND p.current_person_id = cp.id
WHERE
        etc.id = 6002
GROUP BY
        el.time_stamp,
        el.reference_center,
        i.payer_center,
        i.payer_id,
        cp.external_id,
        i.center,
        i.id,
        i.fiscal_reference
UNION 
SELECT
        longtodatec(el.time_stamp, el.reference_center) AS Sync_date,
        cn.payer_center || 'p' || cn.payer_id AS PersonId,
        cp.external_id,
        cn.center || 'cred' || cn.id AS Referencia,
        SUM(cnl.total_amount) AS TotalAmount,
        cn.fiscal_reference
FROM
        vivagym.event_type_config etc
JOIN
        vivagym.event_log el ON el.event_configuration_id = etc.id
JOIN
        vivagym.credit_notes cn ON el.reference_center = cn.center AND el.reference_id = cn.id
JOIN
        vivagym.credit_note_lines_mt cnl ON cn.center = cnl.center AND cn.id = cnl.id
LEFT JOIN 
        vivagym.persons p ON cn.payer_center = p.center AND cn.payer_id = p.id
LEFT JOIN 
        vivagym.persons cp ON p.current_person_center = cp.center AND p.current_person_id = cp.id
WHERE
        etc.id = 6201
GROUP BY
        el.time_stamp,
        el.reference_center,
        cn.payer_center,
        cn.payer_id,
        cp.external_id,
        cn.center,
        cn.id,
        cn.fiscal_reference
ORDER BY 1