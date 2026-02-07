SELECT
        r1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        TO_CHAR(current_timestamp,'YYYY-MM-DD HH24:MI:SS.MS') AS batch_id,
                        TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 days' AS cutDate,
                        c.id AS center_id
                FROM
                        vivagym.centers c
                WHERE
                        c.country = 'PT'
        )
        SELECT
                DISTINCT
                i.center,
                i.id,
                i.payer_center || 'p' || i.payer_id AS "PERSONKEY",
                CAST('NCE' AS TEXT) AS TipoDoc,
                (CASE
                        WHEN altnif.txtvalue IS NOT NULL THEN concat(cp.external_id,'|',altnif.txtvalue)
                        ELSE concat(cp.external_id,'|',cp.national_id)
                END) AS Entidade,
                TO_CHAR(pr.xfr_date,'YYYY-MM-DD') || ' 00:00:00' AS DataRes,
                CAST('Fitness' AS TEXT) AS Empresa,
                i.fiscal_export_token AS CDU_ExerpID,
                TO_CHAR(longToDateC(i.entry_time, i.center),'YYYY-MM-DD') || ' 00:00:00' AS OriginalDocumentDate,
                i.center || 'inv' || i.id AS OriginalDocumentReference,
                i.fiscal_export_token AS OriginalDocumentExerpID,
                par.batch_id,
                prs.ref,
                pr.rejected_reason_code,
                i.fiscal_reference
        FROM 
                vivagym.payment_requests pr
        JOIN
                params par ON pr.center = par.center_id
        JOIN
                vivagym.payment_request_specifications prs ON  prs.center = pr.inv_coll_center AND prs.id = pr.inv_coll_id AND prs.subid = pr.inv_coll_subid
        JOIN
                vivagym.ar_trans art ON prs.center = art.payreq_spec_center AND prs.id = art.payreq_spec_id AND prs.subid = art.payreq_spec_subid
        JOIN 
                vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
        JOIN 
                vivagym.invoice_lines_mt il ON il.center = i.center AND il.id = i.id 
        JOIN 
                vivagym.persons p ON p.center = i.payer_center AND p.id = i.payer_id
        JOIN 
                vivagym.persons cp ON p.current_person_center = cp.center AND p.current_person_id = cp.id
        LEFT JOIN 
                vivagym.person_ext_attrs altnif ON cp.center = altnif.personcenter AND cp.id = altnif.personid AND altnif.name = 'ALTNIFNBR'
        LEFT JOIN
                vivagym.clearing_in cin ON pr.xfr_delivery = cin.id
        WHERE
                pr.state = 17
                AND il.total_amount != 0
                --AND i.fiscal_reference IS NOT NULL
                --AND i.fiscal_reference != 'REVOKED'
                AND pr.rejected_reason_code IN ('CHARGEBACK','') -- FIX TO BE ADDED
                AND i.center IN (:center) --(716)  
                AND
                (
                        cin.generated_date IS NULL
                        OR
                        cin.generated_date = par.cutDate
                )
AND i.text NOT IN ('Rejeição DD PT')
) r1
        