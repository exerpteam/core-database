WITH
    params AS materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
            AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
            +90000000 -1 AS todate,
            c.id         AS centerid
        FROM
            centers c
    )
SELECT
    p.center||'p'||p.id                                               AS "Member ID (friend)",
    p.external_id                                                     AS "External ID (friend)",
    c.name                                                            AS "Home Center (friend)",
    date_part('year', age(p.birthdate))                               AS "Age (friend)",
    p.address1 || ' '|| p.address2 || ' '|| p.city || ' '|| p.zipcode AS "Address (friend)",
    pea_phone.txtvalue                                                AS "Phone (friend)",
    pea.txtvalue                                                      AS "Email (friend)",
    longtodateC(cc.valid_from, c.id)                                  AS
    "BAF Clip Received Timestamp (friend)",
    longtodateC(ccu.time, c.id)          AS "BAF Clip Used Timestamp (friend)",
    p_member.center || 'p'|| p_member.id AS "Member ID (member)",
    p_member.external_id                 AS "External ID (member)"
FROM
    clipcards cc
JOIN
    products prod
ON
    cc.center = prod.center
AND cc.id = prod.id
JOIN
    centers c
ON
    c.id = cc.center
JOIN
    params
ON
    params.centerId = c.id
JOIN
    card_clip_usages ccu
ON
    ccu.card_center = cc.center
AND ccu.card_id = cc.id
AND ccu.card_subid = cc.subid
JOIN
    persons p
ON
    p.center = cc.owner_center
AND p.id = cc.owner_id
JOIN
    relatives r
ON
    r.rtype = 13
AND r.status = 1
AND r.center = p.center
AND r.id = p.id
JOIN
    persons p_member
ON
    p_member.center = r.relativecenter
AND p_member.id = r.relativeid
LEFT JOIN
    person_ext_attrs pea
ON
    p.center = pea.personcenter
AND p.id = pea.personid
AND pea.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs pea_phone
ON
    pea_phone.personcenter = p.center
AND pea_phone.personid = p.id
AND pea_phone.name = '_eClub_PhoneSMS'
WHERE
    cc.center IN (:scope)
AND prod.globalid = 'BAF_FRIEND_CLIPCARD'
AND ccu.time BETWEEN params.fromdate AND params.todate
AND ccu.state = 'ACTIVE';


