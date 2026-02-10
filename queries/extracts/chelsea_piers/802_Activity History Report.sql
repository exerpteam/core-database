-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2393
WITH
    params AS
    (
        SELECT
            c.id   AS centerid,
            c.name AS centername,
            /*Date Range*/
            cast(datetolongTZ(TO_CHAR(to_date($$fromdate$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)as BIGINT) AS fromdate,
            cast(datetolongTZ(TO_CHAR(to_date($$todate$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)+ (24*3600*1000) -1 as BIGINT) AS todate
        FROM
            centers c
where c.id in($$scope$$)
    )
SELECT
    centername                     AS "Purchased For",
    p.external_id                  AS "Member ID",
    p.firstname                    AS "First Name",
    p.lastname                     AS "Last Name",
    pg.name                        AS "Category",
    prd.globalid                   AS "Item Code",
    prd.name                       AS "Item",
    b.center||'book'||b.id         AS "Activity ID",
    null AS "Unit #",--This is wrong....,
    ccu.type                       AS "Action",
    prd.cost_price                 AS "Amount",
    ccu.description                AS "Comment",
    EMP.fullname                   AS "Service Provider",
    TO_CHAR(to_date(TO_CHAR(longtodatec(ccu.time,b.center), 'YYYY-MM-DD HH24:MI'),'yyyy-mm-dd'),'mm-dd-yyyy') as "Action Date",
    to_char(to_TIMESTAMP(TO_CHAR(longtodatec(ccu.time,b.center), 'YYYY-MM-DD HH24:MI'),'YYYY-MM-DD HH24:MI:SS'),'FMHH12:MI am') as "Action Time", 
        CASE
        WHEN CCU.employee_center IS NULL
        AND CCU.employee_id IS NULL
        THEN 'AUTO'
        ELSE ac_per.fullname
    END                               AS "Action By",
    to_char(to_TIMESTAMP(TO_CHAR(longtodateC(b.starttime,b.center), 'YYYY-MM-DD HH24:MI'),'YYYY-MM-DD HH24:MI:SS'),'FMHH12:MI am') AS "Appointment/Service Start Time",
    to_char(to_TIMESTAMP(TO_CHAR(longtodateC(b.stoptime,b.center), 'YYYY-MM-DD HH24:MI'),'YYYY-MM-DD HH24:MI:SS'),'FMHH12:MI am') AS "Appointment/Service End Time"
FROM
    PERSONS P
JOIN
    participations pa
ON
    p.center = pa.participant_center
AND p.id = pa.participant_id
AND pa.state <>'CANCELLED'
JOIN
    bookings b
ON
    pa.booking_center=b.center
AND pa.booking_id=b.id
AND B.STATE <>'CANCELLED'
JOIN
    PARAMS
ON
    B.CENTER = CENTERID
AND B.STARTTIME BETWEEN fromdate AND TODATE
JOIN
    activity a
ON
    b.activity=a.id
JOIN
    activity_group ag
ON
    a.activity_group_id=ag.id
LEFT JOIN
    activity_group parent
ON
    ag.parent_activity_group_id=parent.id
JOIN
    privilege_usages pu
ON
    pu.target_service = 'Participation'
AND pu.target_center = pa.center
AND pu.target_id = pa.id
JOIN
    clipcards c
ON
    pu.source_center = c.center
AND pu.source_id = c.id
AND pu.source_subid = c.subid
JOIN
    CARD_CLIP_USAGES CCU
ON
    C.CENTER = CCU.CARD_CENTER
AND C.ID = CCU.CARD_ID
AND C.SUBID=CCU.CARD_SUBID
AND pu.id=ccu.ref
JOIN
    invoice_lines_mt ilm
ON
    c.invoiceline_center=ilm.center
AND c.invoiceline_id=ilm.id
AND c.invoiceline_subid=ilm.subid
JOIN
    products prd
ON
    ilm.productcenter=prd.center
AND ilm.productid=prd.id
JOIN
    product_group pg
ON
    prd.primary_product_group_id=pg.id
LEFT JOIN
    staff_usage su
ON
    su.booking_center=b.center
AND su.booking_id=b.id
AND su.state = 'ACTIVE'
LEFT JOIN
    PERSONS EMP
ON
    SU.person_center= EMP.CENTER
AND SU.person_id=EMP.ID
LEFT JOIN
    employees ac_emp
ON
    ccu.employee_center=ac_emp.center
AND ccu.employee_id=ac_emp.id
LEFT JOIN
    persons ac_per
ON
    ac_emp.personcenter=ac_per.center
AND ac_emp.personid=ac_per.id
    --WHERE ccu.employee_center IS NULL --To return auto shown up
    --AND B.CENTER||'book'||B.ID IN ('180book114487') --FIND BY BOOKING ID
    --AND P.CENTER||'p'||P.ID IN ('180p58615') --FIND BY PERSON ID
    --AND EMP.CENTER||'p'||EMP.ID IN ('100p1234) --Find by Staff Person ID
ORDER BY
    1,2,3,4