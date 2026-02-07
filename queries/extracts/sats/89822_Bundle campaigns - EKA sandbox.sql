WITH
    params AS
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE(:FROM_DATE, 'YYYY-MM-dd'),'YYYY-MM-dd')) AS bigint) AS from_date,
            CAST(datetolong(TO_CHAR(TO_DATE(:TO_DATE, 'YYYY-MM-dd'),'YYYY-MM-dd')) AS bigint)+1000*60 *60*24 AS to_date,
            c.id AS centerid
        FROM
            centers c
    )
    SELECT
    bc.name AS campaign_name,
    p.center ||'p'|| p.id AS member_id,
    p.fullname AS member_name,
    TO_CHAR(longtodate(inv.trans_time), 'dd-MM-YYYY HH24:MI') AS usage_time,
	invl.center AS usage_centerid,
	c.shortname AS usage_centername,
    invl.quantity,
    invl.total_amount AS amount,
    invl.total_amount / invl.quantity AS price_per_unit
    FROM
    bundle_campaign_usages bcu
    JOIN
    params par
    ON
    par.centerid = bcu.invoice_line_center
    JOIN
    bundle_campaign bc
    ON
    bc.id = bcu.campaign_id
    JOIN
    invoice_lines_mt invl
    ON
    invl.center = bcu.invoice_line_center
    AND invl.id = bcu.invoice_line_id
    AND invl.subid = bcu.invoice_line_sub_id
    JOIN
    invoices inv
    ON
    inv.center = invl.center
    AND inv.id = invl.id
	JOIN
    centers c
    ON
    inv.center = c.id
    LEFT JOIN
    persons p
    ON
    p.center = inv.payer_center
    AND p.id = inv.payer_id
	
    WHERE
    invl.center IN (:scope)
    AND inv.trans_time BETWEEN par.from_date AND par.to_date
    --AND bc.name = (campaign_name)