-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    a.person_center,
    a.person_id,
    a.inv_center,
    a.memberid,
    a.product_text,
    a.product_center, --Will be used for API free credit note
    a.product_id, --Will be used for API free credit note
    SUM(a.total_charged_to_member_less_tax) AS total_charged_to_member_less_tax, --Will be used for
    -- API free credit note
    SUM(a.total_charged_to_member_inc_tax) AS total_charged_to_member_inc_tax,
    ar.balance                             AS ar_balance
FROM
    (
        SELECT
            t.person_center,
            t.person_id,
            t.inv_center,
            SUM(t.product_normal_price) AS total_charged_to_member_less_tax,
            SUM(t.total_amount)         AS total_charged_to_member_inc_tax,
            t.text                      AS product_text,
            t.center                    AS product_center,
            t.id                        AS product_id,
            t.memberid
        FROM
            (
                WITH
                    params AS
                    (
                        SELECT
                            datetolongTZ(TO_CHAR(to_date('2020-03-16','yyyy-mm-dd'),
                            'YYYY-MM-DD HH24:MI:SS' ), c.time_zone) AS ep_fromDateCorona,
                            datetolongTZ(TO_CHAR(to_date('2020-06-09','yyyy-mm-dd'),
                            'YYYY-MM-DD HH24:MI:SS' ), c.time_zone) AS ep_toDateCorona,
                            c.id                                            AS centerid
                        FROM
                            centers c
                    )
                SELECT
                    i.payer_center AS person_center,
                    i.payer_id     AS person_id,
                    i.center       AS inv_center,
                    ilm.product_normal_price,
                    ilm.total_amount,
                    ilm.text,
                    p.center,
                    p.id,
                    i.payer_center||'p'|| i.payer_id AS memberid
                FROM
                    params
                JOIN
                    invoices i
                ON
                    i.center = params.centerid
                AND i.entry_time >=ep_fromDateCorona
                JOIN
                    invoice_lines_mt ilm
                ON
                    ilm.center = i.center
                AND ilm.id = i.id
                AND ilm.reason = 9
                JOIN
                    products p
                ON
                    p.center = ilm.productcenter
                AND p.id = ilm.productid
                AND p.ptype=7 )t
        GROUP BY
            t.person_center,
            t.person_id,
            t.inv_center,
            t.text,
            t.center,
            t.id,
            t.memberid )a
JOIN
    account_receivables ar
ON
    ar.customercenter = a.person_center
AND ar.customerid = a.person_id
AND ar.balance !=0
WHERE
    a.inv_center IN (:scope)
AND a.total_charged_to_member_less_tax >0
GROUP BY
    a.person_center,
    a.person_id,
    a.inv_center,
    a.memberid,
    a.product_text,
    a.product_center, --Will be used for API free credit note
    a.product_id, --Will be used for API free credit note
    -- a.total_charged_to_member_less_tax, --Will be used for API free credit note
    --a.total_charged_to_member_inc_tax,
    ar.balance