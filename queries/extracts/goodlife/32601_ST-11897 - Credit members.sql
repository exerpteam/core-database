SELECT
    (row_number() over() / 500) + 1 AS threadgroup,
    t.person_center,
    t.person_id,
    --t.person_external_id,
    --t.ss_center,
    --t.ss_id,
    --t.or_binding_end_date,
    --t.extenstion_days,
    'PAYMENT'                                  AS accountrectype,
    t.total_amount                             AS AMOUNT,
    t.invoicetext19 ||' (Refund for COVID-19)' AS COMMENT1,
    'REFUND_PT_PAP'                            AS accountGlobalId
    --t.or_binding_end_date+t.extenstion_days AS new_binding_endate,
    --FLOOR(extract(epoch FROM now())*1000)   AS new_last_modified
FROM
    (
        WITH
            pr AS
            (
                SELECT
                    *
                FROM
                    D20200316_paymentreq
                UNION ALL
                SELECT
                    *
                FROM
                    D20200317_paymentreq
            )
        SELECT DISTINCT
            ilm.center,
            ilm.id,
            ilm.subid,
            ar.customercenter AS person_center,
            ar.customerid     AS person_id,
            ilm.total_amount,
            ilm.text AS invoicetext19
        FROM
            pr
        JOIN
            goodlife.account_receivables ar
        ON
            ar.center = pr.center
        AND ar.id = pr.id
        JOIN
            goodlife.ar_trans art
        ON
            art.payreq_spec_center = pr.inv_coll_center
        AND art.payreq_spec_id= pr.inv_coll_id
        AND art.payreq_spec_subid= pr.inv_coll_subid
        JOIN
            goodlife.invoice_lines_mt ilm
        ON
            ilm.center = art.ref_center
        AND ilm.id = art.ref_id
        AND art.ref_type = 'INVOICE'
        JOIN
            spp_invoicelines_link link
        ON
            link.invoiceline_center = ilm.center
        AND link.invoiceline_id = ilm.id
        AND link.invoiceline_subid = ilm.subid
        JOIN
            subscriptionperiodparts spp
        ON
            spp.center = link.period_center
        AND spp.id = link.period_id
        AND spp.subid = link.period_subid
        AND spp.spp_state = 1
        JOIN
            subscriptions s
        ON
            s.center = spp.center
        AND s.id = spp.id
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        AND st.st_type = 2
        WHERE
            ilm.total_amount > 0) t