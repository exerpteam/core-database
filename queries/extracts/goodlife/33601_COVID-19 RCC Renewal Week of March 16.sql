WITH
    params AS
    (
        SELECT
            to_date('2020-03-16','yyyy-mm-dd') AS spp_clubclose_date,
            datetolongTZ(TO_CHAR(to_date('2020-03-14','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS fromDateCorona,
            datetolongTZ(TO_CHAR(to_date('2020-03-20','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'),
            c.time_zone)-1 AS toDateCorona,
            c.id           AS centerid,
            c.time_zone    AS time_zone
            --
        FROM
            centers c
    )
SELECT
    centerid,
    i.payer_center||'p'||i.payer_id     AS payer_person_id,
    longtodateC(i.entry_time,i.center)  AS invoice_entry_time,
    ar.balance                          AS account_balance,
    sub.owner_center||'p'||sub.owner_id AS subscription_owner_id,
    ilm.product_normal_price,
    sub.center ||'ss'|| sub.id AS subscription_id,
    ilm.text
    --p.center AS prodcenter,
    --p.id     AS prodid,
FROM
    invoices i
JOIN
    params
ON
    i.center = params.centerid
JOIN
    goodlife.invoice_lines_mt ilm
ON
    i.center = ilm.center
AND i.id = ilm.id
AND ilm.reason = 9 --get renewal only
AND ilm.product_normal_price >0
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
AND spp.spp_state = 1 --period parts which are active only
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
AND st.st_type IN (2) -- only EFT subscriptions
JOIN
    products p
ON
    p.center = ilm.productcenter
AND p.id = ilm.productid
AND p.ptype IN (10) -- only subscription product types
left JOIN
    account_receivables ar
ON
    ar.customercenter = i.payer_center
AND ar.customerid = i.payer_id
AND ar.balance !=0
WHERE
    i.entry_time BETWEEN fromDateCorona AND toDateCorona