WITH params AS MATERIALIZED
(
   SELECT
    TO_CHAR(current_timestamp, 'YYYY-MM-DD HH24:MI:SS.MS') AS batch_id,
    CAST(dateToLongC('2025-12-08', c.id) AS BIGINT) AS fromDate,
    CAST(dateToLongC('2025-12-12', c.id) AS BIGINT) AS toDate,
    c.id AS center_id
        FROM
                CENTERS c
        WHERE
                c.country = 'PT'
)
SELECT
        i.center,
        i.id,
        i.payer_center || 'p' || i.payer_id AS "PERSONKEY",
        CAST('NCE' AS TEXT) AS TipoDoc,
        (CASE
                WHEN altnif.txtvalue IS NOT NULL THEN concat(cp.external_id,'|',altnif.txtvalue)
                ELSE concat(cp.external_id,'|',cp.national_id)
        END) AS Entidade,
        TO_CHAR(longToDateC(artm.cancelled_time, i.center),'YYYY-MM-DD') || ' 00:00:00' AS DataRes,
        CAST('Fitness' AS TEXT) AS Empresa,
        i.fiscal_export_token AS CDU_ExerpID,
        TO_CHAR(longToDateC(i.entry_time, i.center),'YYYY-MM-DD') || ' 00:00:00' AS OriginalDocumentDate,
        i.center || 'inv' || i.id AS OriginalDocumentReference,
        i.fiscal_export_token AS OriginalDocumentExerpID,
        artm.amount AS chargedback_amount,
        par.batch_id,
        i.fiscal_reference
FROM vivagym.invoices i
JOIN params par
        ON par.center_id = i.center
JOIN vivagym.ar_trans art
        ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
JOIN vivagym.account_receivables ar 
        ON art.center = ar.center AND art.id = ar.id
JOIN vivagym.persons p 
        ON ar.customercenter = p.center AND ar.customerid = p.id
JOIN vivagym.art_match artm 
        ON art.center = artm.art_paid_center AND art.id = artm.art_paid_id AND art.subid = artm.art_paid_subid
JOIN vivagym.ar_trans art2 
        ON art2.center = artm.art_paying_center AND art2.id = artm.art_paying_id AND art2.subid = artm.art_paying_subid
JOIN vivagym.persons cp 
        ON p.current_person_center = cp.center AND p.current_person_id = cp.id
LEFT JOIN vivagym.person_ext_attrs altnif 
        ON cp.center = altnif.personcenter AND cp.id = altnif.personid AND altnif.name = 'ALTNIFNBR'
WHERE
        p.sex != 'C'
        AND artm.cancelled_time between par.fromDate AND par.toDate
        AND art.amount != 0
