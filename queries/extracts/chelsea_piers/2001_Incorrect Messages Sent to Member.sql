WITH
    params AS
    (
        SELECT
            to_date(TO_CHAR(now(),'yyyy-mm-dd'),'yyyy-mm-dd') AS today,
            CAST(datetolongTZ(TO_CHAR(to_date($$start_date$$,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone) AS BIGINT) AS fromdate,
            CAST(datetolongTZ(TO_CHAR(to_date($$to_date$$,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)+ (24*3600*1000) -1 AS BIGINT) AS todate,
            c.id AS centerid
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
            --where c.id in ()
    )
SELECT
    TO_CHAR(longtodateC(m.senttime,m.center),'yyyy-mm-dd hh12:mm:ss')              AS sent_time,
    TO_CHAR(longtodateC(m.receivedtime,m.center),'yyyy-mm-dd hh12:mm:ss') AS received_time,
    case when m.deliverymethod = 1 then 'E-mail' end as "Delivery Method",
    m.subject as "Subject",
    m.sender_ext_ref as "From",
    p.center||'p'||p.id as "Person",
    email.txtvalue AS "Email"
    
FROM
    messages m
JOIN
    persons p
    join params on centerid=p.center
ON
    m.center = p.center
AND m.id = p.id
LEFT JOIN
    person_ext_attrs email
ON
    p.center = email.personcenter
AND p.id = email.personid
AND email.name = '_eClub_Email'
WHERE
    subject ='Your Guest Passes at Chelsea Piers Fitness'
AND senttime BETWEEN fromdate AND todate