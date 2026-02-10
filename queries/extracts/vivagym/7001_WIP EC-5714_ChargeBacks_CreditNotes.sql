-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        r1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        TO_CHAR(current_timestamp,'YYYY-MM-DD HH24:MI:SS.MS') AS batch_id,
                        c.id AS center_id
                FROM
                        vivagym.centers c
                WHERE
                        c.country = 'PT'
        )
        SELECT
                DISTINCT
                cn.center,
                cn.id,
                cn.payer_center || 'p' || cn.payer_id AS "PERSONKEY",
                CAST('NCE' AS TEXT) AS TipoDoc,
                (CASE
                        WHEN altnif.txtvalue IS NOT NULL THEN concat(cp.external_id,'|',altnif.txtvalue)
                        ELSE concat(cp.external_id,'|',cp.national_id)
                END) AS Entidade,
                TO_CHAR(pr.xfr_date,'YYYY-MM-DD') || ' 00:00:00' AS DataRes,
                CAST('Fitness' AS TEXT) AS Empresa,
                cn.fiscal_export_token AS CDU_ExerpID,
                cn.fiscal_reference AS RefDocumentNumDoc,
                par.batch_id,
                prs.ref,
                pr.rejected_reason_code
        FROM 
                vivagym.payment_requests pr
        JOIN
                params par ON pr.center = par.center_id
        JOIN
                vivagym.payment_request_specifications prs ON  prs.center = pr.inv_coll_center AND prs.id = pr.inv_coll_id AND prs.subid = pr.inv_coll_subid
        JOIN
                vivagym.ar_trans art ON prs.center = art.payreq_spec_center AND prs.id = art.payreq_spec_id AND prs.subid = art.payreq_spec_subid
        JOIN 
                vivagym.credit_notes cn ON art.ref_center = cn.center AND art.ref_id = cn.id AND art.ref_type = 'CREDIT_NOTE'
        JOIN 
                vivagym.credit_note_lines_mt cnl ON cnl.center = cn.center AND cnl.id = cn.id 
        JOIN 
                vivagym.persons p ON p.center = cn.payer_center AND p.id = cn.payer_id
        JOIN 
                vivagym.persons cp ON p.current_person_center = cp.center AND p.current_person_id = cp.id
        LEFT JOIN 
                vivagym.person_ext_attrs altnif ON cp.center = altnif.personcenter AND cp.id = altnif.personid AND altnif.name = 'ALTNIFNBR'
        WHERE
                pr.state = 17
                AND cnl.total_amount != 0
                AND cn.fiscal_reference IS NOT NULL
                AND cn.fiscal_reference != 'REVOKED'
                AND pr.rejected_reason_code IN ('CHARGEBACK','') 
                AND cn.center IN (:center) --(716)  
) r1