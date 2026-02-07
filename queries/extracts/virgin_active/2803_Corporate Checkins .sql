SELECT
    p.center,
    p.id ,
    p.FULLNAME,
    p.SSN,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    p.ADDRESS2,
    ca.NAME                                                      AS "Company Agreement",
    DECODE(s.center||'ss'||s.id ,'ss',NULL,s.center||'ss'||s.id) AS SubscriptionID,
    s.START_DATE,
    s.END_DATE,
    comp.FULLNAME company,
    SUM(
        CASE
            WHEN atts.att_date BETWEEN TRUNC($$check_date$$ - 31) AND TRUNC($$check_date$$ -21)
            THEN 1
            ELSE 0
        END) AS "Last 22 to 31 days",
    SUM(
        CASE
            WHEN atts.att_date BETWEEN TRUNC($$check_date$$ - 21) AND TRUNC($$check_date$$ -14)
            THEN 1
            ELSE 0
        END) AS "Last 15 to 21 days",
    SUM(
        CASE
            WHEN atts.att_date BETWEEN TRUNC($$check_date$$ -14) AND TRUNC($$check_date$$ -7)
            THEN 1
            ELSE 0
        END) AS "Last 8 to 14 days",
    SUM(
        CASE
            WHEN atts.att_date BETWEEN TRUNC($$check_date$$ -7) AND TRUNC($$check_date$$)
            THEN 1
            ELSE 0
        END) AS "Last 1 to 7 days"
FROM
    PERSONS p
JOIN
    PERSONS p2 --all the transferred members and the current member
ON
    p2.CURRENT_PERSON_CENTER = p.CENTER
    AND p2.CURRENT_PERSON_ID = p.ID
JOIN
    (
        SELECT DISTINCT
            p.center ,
            p.id,
            longtodatetz(ch.CHECKIN_TIME,'Europe/London') AS att_date
        FROM
            PERSONS p
        LEFT JOIN
            CHECKINS ch
        ON
            ch.PERSON_CENTER = p.CENTER
            AND ch.PERSON_ID = p.ID
            AND ch.CHECKIN_TIME > dateToLong(TO_CHAR(TRUNC($$check_date$$ - 21), 'YYYY-MM-dd HH24:MI'))
        LEFT JOIN
            CHECKINS ch1
        ON
            ch.PERSON_CENTER = ch1.PERSON_CENTER
            AND ch.PERSON_ID = ch1.PERSON_ID
            AND ch1.CHECKIN_TIME BETWEEN ch.CHECKIN_TIME+1 AND ch.CHECKIN_TIME +1000*60*60*2
        WHERE
            p.PERSONTYPE = 4
            AND ((
                    ch.id IS NOT NULL
                    AND ch1.id IS NULL)
                OR (
                    ch.ID IS NULL)) ) atts
ON
    atts.center = p.center
    AND atts.id = p.id
JOIN
    RELATIVES r
ON
    r.RELATIVECENTER = p.CENTER
    AND r.RELATIVEID = p.id
    AND r.RTYPE = 2
LEFT JOIN
    RELATIVES rca
ON
    rca.CENTER = p.CENTER
    AND rca.ID = p.id
    AND rca.RTYPE = 3
    AND rca.STATUS = 1
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rca.RELATIVECENTER
    AND ca.id = rca.RELATIVEID
    AND ca.SUBID = rca.RELATIVESUBID
JOIN
    (
        SELECT
            op.CURRENT_PERSON_CENTER,
            op.CURRENT_PERSON_ID,
            MAX(s.START_DATE) START_DATE
        FROM
            SUBSCRIPTIONS s
        JOIN
            PERSONS op
        ON
            op.CENTER = s.OWNER_CENTER
            AND op.id = s.OWNER_ID
        WHERE
            s.STATE != 5
        GROUP BY
            op.CURRENT_PERSON_CENTER,
            op.CURRENT_PERSON_ID) last_sub
ON
    last_sub.CURRENT_PERSON_CENTER = p.CENTER
    AND last_sub.CURRENT_PERSON_ID = p.id
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p2.CENTER
    AND s.OWNER_ID = p2.id
    AND s.START_DATE = last_sub.START_DATE
JOIN
    PERSONS comp
ON
    comp.center = r.CENTER
    AND comp.id = r.id
WHERE
    p.PERSONTYPE = 4
    AND ( (
            p.STATUS IN (1,
                         3)
            AND r.STATUS = 1 )
        OR (
            p.LAST_ACTIVE_END_DATE > SYSDATE - 22 ) )
GROUP BY
    p.CENTER,
    p.id,
    p.FULLNAME,
    p.SSN,
    p.STATUS,
    p.ADDRESS2,
    ca.NAME,
    s.START_DATE,
    s.END_DATE,
    s.center,
    s.id,
    comp.FULLNAME