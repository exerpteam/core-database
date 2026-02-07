WITH
    params AS
    (
        SELECT
            c.id   AS CENTER_ID,
            c.name AS center_name,
            datetolongc(TO_CHAR(to_date($$fromdate$$, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
            , c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date($$todate$$, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
            , c.id) + (24*3600*1000) - 1 AS TO_DATE
        FROM
            centers c
             WHERE
            c.id IN ($$scope$$)
    )
SELECT DISTINCT
    params.center_name                                        AS "Center",
    b.center||'book'||b.id                                    AS "Booking ID",
    TO_CHAR(longtodatec(b.STARTTIME,b.center) , 'MM/DD/YYYY') AS "Date of Booking",
    TO_CHAR(longtodatec(b.STARTTIME,b.center) , 'Day')   AS "Day of Week",
    TO_CHAR(longtodatec(b.STARTTIME,b.center) , 'HH24:MI')    AS "Time",
    (b.stoptime-b.starttime)/(60*1000)                        AS "Duration",
    mem.external_id                                           AS "Person External ID",
    mem.firstname                                             AS "Person First Name",
    mem.lastname                                              AS "Person Last Name",
   -- f.id                                                      AS "Family -- ID",
    ag.NAME                                                   AS "Activity Group",
    a.id                                                      AS "Activity ID",
    a.name                                                    AS "Activity",
    per.fullname                                              AS "Staff Name",
    staff_id.txtvalue                                         AS "Staff External ID",
    /* part.state              AS PARTICIPATION_STATE,
    part.cancelation_reason AS CANCELLATION_REASON,
    CASE
    WHEN part.state = 'BOOKED'
    THEN 'N/A'
    WHEN part.state = 'PARTICIPATION'
    THEN 'Show-up'
    WHEN part.state = 'CANCELLED'
    AND part.cancelation_reason = 'NO_SHOW'
    THEN 'No-Show'
    WHEN part.state = 'CANCELLED'
    AND part.cancelation_reason = 'BOOKING'
    THEN 'Booking cancelled'
    WHEN part.state = 'CANCELLED'
    AND part.cancelation_reason = 'NO_PRIVILEGE'
    THEN 'Cancelled (No privilege)'
    WHEN part.state = 'CANCELLED'
    AND part.cancelation_reason IN ('USER',
    'CENTER')
    THEN 'Cancelled by staff or user'
    ELSE 'Other'
    END            AS SHOWUP_STATUS,
    email.txtvalue AS memEmail,
    phone.txtvalue AS memPhone*/
    br.name                                                       AS "Resource",
    TO_CHAR(longtodatec(b.creation_time,b.center) , 'MM/DD/YYYY') AS "Booking Creation Date",
    CASE
        WHEN ccu.type = 'SANCTION'
        THEN 'Sanctioned'
        WHEN ccu.type = 'PRIVILEGE'
        AND part.state = 'PARTICIPATION'
        THEN 'Shown Up'
    END                                                          AS "Clip Redeemed Method",
    ROUND((-1*il.total_amount / cc.clips_initial) * ccu.clips,2) AS "Revenue",
    acc.external_id                                              AS "G/L External ID",
    card_center.name                                             AS "Club Purchased"
FROM
    chelseapiers.bookings b
JOIN
    params
ON
    b.center = center_id
JOIN
    chelseapiers.activity a
ON
    a.id = b.ACTIVITY
JOIN
    chelseapiers.activity_group ag
ON
    ag.id = a.ACTIVITY_GROUP_ID
LEFT JOIN
    chelseapiers.staff_usage su
ON
    su.BOOKING_CENTER = b.center
AND su.BOOKING_ID = b.id
AND su.state = 'ACTIVE'
LEFT JOIN
    chelseapiers.persons per
ON
    per.CENTER = su.PERSON_CENTER
AND per.ID = su.PERSON_ID
JOIN
    chelseapiers.participations part
ON
    b.center = part.BOOKING_CENTER
AND b.id = part.BOOKING_ID
JOIN
    chelseapiers.persons mem
ON
    mem.center = part.participant_center
AND mem.id = part.participant_id
LEFT JOIN
    chelseapiers.zipcodes province
ON
    mem.zipcode = province.zipcode
AND province.country = 'US'
AND province.province IS NOT NULL
LEFT JOIN
    chelseapiers.person_ext_attrs email
ON
    email.personcenter=mem.center
AND email.personid=mem.id
AND email.name = '_eClub_Email'
LEFT JOIN
    chelseapiers.person_ext_attrs phone
ON
    phone.personcenter=mem.center
AND phone.personid=mem.id
AND phone.name = '_eClub_PhoneHome'
LEFT JOIN
    chelseapiers.person_ext_attrs staff_id
ON
    staff_id.personcenter=per.center
AND staff_id.personid=per.id
AND staff_id.name = '_eClub_StaffExternalId'
LEFT JOIN
    chelseapiers.relatives fr
ON
    fr.center = mem.center
AND fr.id = mem.id
AND fr.rtype = 19
AND fr.status < 2
LEFT JOIN
    chelseapiers.families f
ON
    f.center = fr.relativecenter
AND f.id = fr.relativeid
LEFT JOIN
    chelseapiers.booking_resource_usage bru
ON
    bru.booking_center= b.center
AND bru.booking_id = b.id
AND bru.state = 'ACTIVE'
LEFT JOIN
    chelseapiers.booking_resources br
ON
    br.center = bru.booking_resource_center
AND br.id = bru.booking_resource_id
LEFT JOIN
    chelseapiers.privilege_usages pu
ON
    pu.target_center = part.center
AND pu.target_id = part.id
AND pu.target_service = 'Participation'
LEFT JOIN
    chelseapiers.privilege_grants pg
ON
    pg.ID = pu.GRANT_ID
LEFT JOIN
    chelseapiers.card_clip_usages ccu
ON
    ccu.ref= pu.id
    and ccu.state != 'CANCELLED'
AND pg.granter_service = 'GlobalCard'
LEFT JOIN
    chelseapiers.clipcards cc
ON
    cc.center =ccu.card_center
AND cc.id = ccu.card_id
AND cc.subid = ccu.card_subid
LEFT JOIN
    chelseapiers.centers card_center
    on cc.center = card_center.id
LEFT JOIN
    chelseapiers.invoice_lines_mt il
ON
    il.center = cc.invoiceline_center
AND il.id = cc.invoiceline_id
AND il.subid = cc.invoiceline_subid
LEFT JOIN
    chelseapiers.account_trans act
ON
    act.center = il.account_trans_center
AND act.id = il.account_trans_id
AND act.subid = il.account_trans_subid
LEFT JOIN
    chelseapiers.accounts acc
ON
    acc.center = act.credit_accountcenter
AND acc.id = act.credit_accountid
WHERE
    b.state = 'ACTIVE'
AND
    CASE (($$serviceProvider$$) || '')
        WHEN 'Enter the first few letters or full name of the Service Provider'
        THEN PER.fullname ILIKE ('%')
        WHEN 'none'
        THEN PER.fullname ILIKE ('%')
        WHEN 'None'
        THEN PER.fullname ILIKE ('%')
        ELSE PER.fullname ILIKE (($$serviceProvider$$) || '%')
    END
AND
    CASE (($$serviceType$$) || '')
        WHEN 'Enter the first few letters or full name of the Service Type'
        THEN ag.name ILIKE ('%')
        WHEN 'none'
        THEN ag.name ILIKE ('%')
        WHEN 'None'
        THEN ag.name ILIKE ('%')
        ELSE ag.name ILIKE (($$serviceType$$) || '%')
    END
AND
    CASE (($$service$$) || '')
        WHEN 'Enter the first few letters or full name of the Service'
        THEN a.name ILIKE ('%')
        WHEN 'none'
        THEN a.name ILIKE ('%')
        WHEN 'None'
        THEN a.name ILIKE ('%')
        ELSE a.name ILIKE (($$service$$) || '%')
    END
AND b.STARTTIME BETWEEN params.FROM_DATE AND params.TO_DATE
ORDER BY
    TO_CHAR(longtodatec(b.STARTTIME,b.center) , 'MM/DD/YYYY'),
    per.fullname,
    mem.firstname
    --where member_exID='1638'