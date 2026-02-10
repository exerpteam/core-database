-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            -- March  - Corona Virus
            datetolongTZ(TO_CHAR(to_date(:fromdate,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),
            c.time_zone) AS fromDateCorona,

            c.id         AS centerid
        FROM
            centers c
    )
SELECT
    pe.external_id,
    pe.center||'p'||pe.id                 AS memberid,
    longtodateC(i.entry_time,c.center)    AS invoice_entry,
    longtodateC(i.trans_time,c.center)    AS transtime,
    longtodateC(c.valid_from,c.center)    AS clipvalidfrom,
    sub.center ||'ss'||sub.id             AS subscriptionid,
    sub.billed_until_date                 AS subscription_BUD,
    sub.start_date                        AS subscription_startdate,
    sub.end_date                          AS subscription_enddate,
    c.center ||'cc'||c.id ||'cc'||c.subid AS clipid,
    c.finished,
    c.clips_initial,
    c.clips_left,
    ilm.total_amount,
        i.text
--,ilm.*
FROM
                    clipcards c
                JOIN
                    params
                ON
                    params.centerid = c.center
                JOIN
                    invoice_lines_mt ilm
                ON
                    c.invoiceline_center=ilm.center
                AND c.invoiceline_id = ilm.id
                AND c.invoiceline_subid = ilm.subid
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
                    subscriptions sub
                ON
                    sub.center = spp.center
                AND sub.id = spp.id
                JOIN
                    subscriptiontypes st
                ON
                    st.center = sub.subscriptiontype_center
                AND st.id = sub.subscriptiontype_id
                LEFT JOIN
                    products p
                ON
                    p.center = ilm.productcenter
                AND p.id = ilm.productid
                AND p.ptype = 10
                JOIN
                    persons pe
                ON
                    pe.center = c.owner_center
                AND pe.id = c.owner_id
WHERE
    i.entry_time>=fromDateCorona
AND ilm.reason = 9
AND clips_left !=0
AND sub.center in (:scope)