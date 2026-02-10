-- The extract is extracted from Exerp on 2026-02-08
-- This report returns members who were granted the PT Comp Session clipcard and used it for a booking. From & To date paramerter goes by entry time of invoice line, therefore this is filtered on when the clipcard was created/sold from MMS.
WITH
    params AS
    (
        SELECT
            c.id AS CENTERID,
            datetolongc(TO_CHAR(to_date($$from_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE

        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    cen.name                         AS booking_service_Center,
    c.owner_center ||'p'||c.owner_id AS memberid,
    per.external_id,
    per.fullname                        AS member_fullname,
    c.center||'cc'||c.id||'cc'||c.subid AS CLIPID,
    p.name,
    --ccu.description                     AS usage_description,
    b.name                            AS booking_Name,
    b.center||'book'||b.id            AS booking_ID,
    emp.external_id                   AS staff_external_ID,
    emp.fullname                      AS staff_fullname,
    b.state                           AS booking_State,
    TO_CHAR(longtodatec(b.STARTTIME,b.center), 'YYYY-MM-DD HH24:MI') AS booking_Starttime

FROM
    clipcards c
JOIN
    params
ON
    centerid = c.center
JOIN
    persons per
ON
    c.owner_center = per.center
AND c.owner_id = per.id
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
    products p
ON
    p.center = ilm.productcenter
AND p.id = ilm.productid
AND p.globalid = 'PT_PRIVATE_COMP_SESSION'
JOIN
    lifetime.card_clip_usages ccu
ON
    c.center = ccu.card_center
AND c.id = ccu.card_id
AND c.subid = ccu.card_subid
JOIN
    privilege_usages pu
ON
    pu.id = ccu.ref
JOIN
    participations pa
ON
    pu.target_center = pa.center
AND pu.target_id = pa.id
JOIN
    bookings b
ON
    b.center = pa.booking_center
AND b.id =pa.booking_id
JOIN
    lifetime.staff_usage su
ON
    su.booking_center = b.center
AND su.booking_id = b.id
JOIN
    lifetime.persons emp
ON
    su.person_center = emp.center
AND su.person_id = emp.id

join centers cen on b.center = cen.id

WHERE
    i.entry_time BETWEEN FROM_DATE AND TO_DATE
AND i.employee_center =13
AND i.employee_id =2
AND ccu.description NOT IN('ESR Expire',
                           'Expire')
    --limit 5