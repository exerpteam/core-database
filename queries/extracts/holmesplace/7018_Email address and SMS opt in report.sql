-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    club_name,
    area,
    "MEMBER TYPE",
    COUNT(center) AS "Total Number",
    SUM(opt_both+email_opt+mobile_opt) AS "Number Opted-In",
    ROUND(100 * (SUM(opt_both+email_opt+mobile_opt) / COUNT(center) ),2) AS "% Opted In",
    SUM(opt_none) AS "Number none opted-In",
    ROUND(100 * (SUM(opt_none) / COUNT(center) ),2) AS "% none opted In",
    sum(email) as "Has email",
    sum(email_opt) as "Opted in",
    ROUND(100 * (sum(email_opt) / COUNT(CENTER)),2) "% Opted in",
    sum(mobile) as "Has mobile",
    sum(mobile_opt) as "Opted in",
    ROUND(100 * (sum(mobile_opt) / COUNT(CENTER)),2) "% Opted in",
    sum(has_both) as "Has mobile & email",
    sum(opt_both) as "Opted in",
    ROUND(100 * (sum(opt_both) / COUNT(CENTER)),2) "% Opted in",
    sum(has_none) as "None email & mobile",
    ROUND(100 * (sum(has_none) / COUNT(CENTER)),2) as "% based on total number"
FROM
    (
        SELECT
            c.NAME club_name,
            a.NAME area ,
            CASE
                WHEN DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') IN ('LEAD',
                                                                                                                                                                                                        'PROSPECT' )
                THEN 'PROSPECT / LEAD'
                WHEN p.STATUS = 2
                THEN 'INACTIVE'
                ELSE 'MEMBER'
            END AS "MEMBER TYPE",
            p.CENTER,
            case when email.TXTVALUE is not null and mobile.TXTVALUE is null then 1 else 0 end as    email,
            case when allow_email.TXTVALUE is not null and mobile.TXTVALUE is null then 1 else 0 end as    email_opt,
            case when mobile.TXTVALUE is not null and email.TXTVALUE is null then 1 else 0 end as    mobile,
            case when allow_sms.TXTVALUE is not null and email.TXTVALUE is null then 1 else 0 end as    mobile_opt,
            case when mobile.TXTVALUE is not null and email.TXTVALUE is not null then 1 else 0 end as    has_both,
            case when allow_sms.TXTVALUE is not null and allow_email.TXTVALUE is not null and mobile.TXTVALUE is not null and email.TXTVALUE is not null then 1 else 0 end as    opt_both,
            case when mobile.TXTVALUE is  null and email.TXTVALUE is  null then 1 else 0 end as    has_none,
            case when allow_sms.TXTVALUE is  null and allow_email.TXTVALUE is  null then 1 else 0 end as    opt_none
        FROM
            PERSONS p
        JOIN
            CENTERS c
        ON
            c.id = p.CENTER
        JOIN
            AREA_CENTERS ac
        ON
            ac.CENTER = c.id
        JOIN
            AREAS a
        ON
            a.id = ac.AREA
            AND a.ROOT_AREA = 1
        LEFT JOIN
            PERSON_EXT_ATTRS email
        ON
            email.PERSONCENTER = p.CENTER
            AND email.PERSONID = p.ID
            AND email.NAME = '_eClub_Email'
            and email.TXTVALUE is not null
        LEFT JOIN
            PERSON_EXT_ATTRS allow_email
        ON
            allow_email.PERSONCENTER = p.CENTER
            AND allow_email.PERSONID = p.ID
            AND allow_email.NAME = '_eClub_AllowedChannelEmail'
            AND allow_email.TXTVALUE = 'true'
        LEFT JOIN
            PERSON_EXT_ATTRS mobile
        ON
            p.center=mobile.PERSONCENTER
            AND p.id=mobile.PERSONID
            AND mobile.name='_eClub_PhoneSMS'
            AND mobile.TXTVALUE is not null
        LEFT JOIN
            PERSON_EXT_ATTRS allow_sms
        ON
            allow_sms.PERSONCENTER = p.CENTER
            AND allow_sms.PERSONID = p.ID
            AND allow_sms.NAME = '_eClub_AllowedChannelSMS'
            AND allow_sms.TXTVALUE = 'true'
        WHERE
            p.STATUS IN (0,1,2,3,6)
            AND p.CENTER IN ($$scope$$)
            AND p.sex NOT IN ('C',
                              'c'))
GROUP BY
    club_name,
    area,
    "MEMBER TYPE"
    order by 1,3 desc