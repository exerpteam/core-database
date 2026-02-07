WITH
    params AS
    (
        SELECT
            to_date(TO_CHAR(now(),'yyyy-mm-dd'),'yyyy-mm-dd') AS today,
            CAST(datetolongTZ(TO_CHAR(to_date($$start_date$$,'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS' ),c.time_zone) AS BIGINT) AS fromdate,
            CAST(datetolongTZ(TO_CHAR(to_date($$to_date$$,'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)+ (24*3600*1000) -1 AS BIGINT) AS todate,

            c.id AS centerid
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
            --where c.id in ()
    )
SELECT
    i.center||'inv'||i.id              AS invoice_id,
    longtodateC(i.trans_time,centerid) AS transaction_time,
    pr.globalid,
    pr.name,
    ilm.person_center||'p'||ilm.person_id   AS memberid,
    i.employee_center||'emp'||i.employee_id AS employee_id,
    '$'||ilm.net_amount                     AS price
FROM
    clipcards c
JOIN
    params
ON
    c.center = params.centerid
JOIN
    persons p
ON
    c.owner_center=p.center
AND c.owner_id=p.id
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
    products pr
ON
    pr.center = ilm.productcenter
AND pr.id = ilm.productid
WHERE
    ilm.net_amount=0
AND i.trans_time BETWEEN fromdate AND todate