-- The extract is extracted from Exerp on 2026-02-08
--  

        SELECT
            t.person_center,
            t.person_id,
            t.ss_center,
            t.ss_id,
            t.or_binding_end_date,
            t.extenstion_days,
            new_binding_endate,
            new_last_modified
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
                    s.owner_center                                   AS person_center,
                    s.owner_id                                       AS person_id,
                    s.center                                         AS ss_center,
                    s.id                                             AS ss_id,
                    s.binding_end_date                             AS or_binding_end_date ,
                    (spp.to_date-spp.from_date)                      AS extenstion_days,
                    s.binding_end_date + (spp.to_date-spp.from_date) AS new_binding_endate,
                    FLOOR(extract(epoch FROM now())*1000)            AS new_last_modified
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
                    invoices i
                ON
                    i.center = ilm.center
                AND i.id = ilm.id
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
                and st.st_type = 2
                WHERE
                    ilm.reason = 9
                AND s.binding_end_date IS NOT NULL
                AND s.binding_end_date >=now() )t
    
