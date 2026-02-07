SELECT DISTINCT
    comp.FULLNAME                                                                                                                                                                   AS company,
    ca.NAME                                                                                                                                                                         AS Company_Agreement,
    p.FULLNAME                                                                                                                                                                      AS Member_name,
    p.center||'p'||p.id                                                                                                                                                            AS "Member ID",
    s.center||'ss'||s.id                                                                                                                                                            AS "Subscription ID",
    pea.TXTVALUE                                                                                                                                                                    AS Employee_number,
    c.SHORTNAME                                                                                                                                                                     AS Center,
    pr.NAME                                                                                                                                                                         AS Subscription,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                        AS PERSONTYPE,
    c.COUNTRY,
    a.NAME                                 AS Region,
--    comp.FULLNAME                          AS company,
	ca.CENTER||'p'||ca.id AS "Company ID",
    ca.CENTER||'p'||ca.id||'rpt'||ca.SUBID AS "Agreement ID",
    s.SUBSCRIPTION_PRICE,
    il.TOTAL_AMOUNT           AS "Joining fee",
    p.FIRST_ACTIVE_START_DATE AS "Join date",
    s.START_DATE
FROM
    PERSONS P
JOIN
    SUBSCRIPTIONS S
ON
    P.CENTER = S.OWNER_CENTER
    AND P.ID = S.OWNER_ID
    AND s.STATE IN (2,4,8)
JOIN
    VA.PRODUCTS pr
ON
    pr.center = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    centers c
ON
    p.center = c.id
JOIN
    VA.AREA_CENTERS ac
ON
    ac.center = c.id
JOIN
    VA.AREAS a
ON
    a.id = ac.area
    AND a.ROOT_AREA = 1
JOIN
    relatives r
ON
    p.center = r.relativecenter
    AND p.id = r.relativeid
    AND r.rtype = 2
    AND r.status = 1
JOIN
    relatives r2
ON
    p.center = r2.center
    AND p.id = r2.id
    AND r2.rtype = 3
    AND r2.status = 1
JOIN
    VA.PERSONS comp
ON
    comp.center = r.center
    AND comp.id = r.id
JOIN
    VA.COMPANYAGREEMENTS ca
ON
    ca.center = r2.RELATIVECENTER
    AND ca.id =r2.RELATIVEID
    AND ca.SUBID = r2.RELATIVESUBID
LEFT JOIN
    VA.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
    AND pea.PERSONID =p.id
    AND pea.NAME='EMPLOYEE_NUMBER'
LEFT JOIN
    VA.INVOICELINES il
ON
    il.center = s.INVOICELINE_CENTER
    AND il.id = s.INVOICELINE_ID
    AND il.SUBID = s.INVOICELINE_SUBID
WHERE
    (
        (s.CREATION_TIME BETWEEN $$from_date$$ AND $$to_date$$
        AND $$date_type$$ = 'Join')
        OR (s.START_DATE BETWEEN longtodatetz($$from_date$$,'Europe/London') AND longtodatetz($$to_date$$,'Europe/London')
        AND $$date_type$$ = 'Start'))
    AND s.center IN ($$scope$$)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            VA.PERSONS p2
        JOIN
            VA.SUBSCRIPTIONS s2
        ON
            s2.OWNER_CENTER = p2.center
            AND s2.OWNER_ID = p2.id
        WHERE
            (
                s2.END_DATE > add_months(longtodatetz(s.CREATION_TIME,'Europe/London'),-1)
                OR s2.END_DATE IS NULL)
            AND s2.CREATION_TIME<s.CREATION_TIME
            AND (
                s2.END_DATE >=s2.START_DATE
                OR s2.END_DATE IS NULL)
            AND p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
            AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID ) 