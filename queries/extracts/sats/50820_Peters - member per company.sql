SELECT
    ca.center                                                                                                                                        AS companycenter,
    ca.id                                                                                                                                            AS companyid,
    ca.subid                                                                                                                                         AS agreementid,
    c.lastname                                                                                                                                       AS company ,
    CASE
        WHEN s.EXTENDED_TO_CENTER IS NULL
        THEN 'false'
        ELSE 'true'
    END                                                                                                                                              AS "extended",
    ca.name                                                                                                                                          AS agreement,
    p.center                                                                                                                                         AS memberCenter,
    p.id                                                                                                                                             AS memberId,
    p.firstname                                                                                                                                      AS firstname,
    p.lastname                                                                                                                                       AS lastname,
    p.ssn                                                                                                                                            AS SSN,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS personStatus,
    prod.name                                                                                                                                        AS SubscriptionType,
    s.start_date                                                                                                                                     AS startDate,
    s.end_date                                                                                                                                       AS EndDate,
    (
        SELECT
            MIN(si.START_DATE)
        FROM
            SATS.SUBSCRIPTIONS si
        WHERE
            si.OWNER_CENTER = p.CENTER
            AND si.OWNER_ID = p.ID
            AND si.SUB_STATE NOT IN (7,8)
    )                    AS MEMBER_SINCE,
    s.subscription_price AS Price
FROM
    SATS.COMPANYAGREEMENTS ca
    /* company */
JOIN SATS.PERSONS c
ON
    ca.CENTER = c.CENTER
    AND ca.ID = c.ID
    /*company agreement relation*/
JOIN SATS.RELATIVES rel
ON
    rel.RELATIVECENTER = ca.CENTER
    AND rel.RELATIVEID = ca.ID
    AND rel.RELATIVESUBID = ca.SUBID
    AND rel.RTYPE = 3
    AND rel.status=1
JOIN SATS.STATE_CHANGE_LOG scl
ON
    scl.CENTER = rel.CENTER
    AND scl.ID = rel.ID
    AND scl.SUBID = rel.SUBID
    AND scl.STATEID = rel.STATUS
    /* persons under agreement*/
JOIN SATS.PERSONS p
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 3
    /* subscriptions active and frozen of person */
LEFT JOIN SATS.subscriptions s
ON
    s.OWNER_CENTER = rel.CENTER
    AND s.OWNER_ID = rel.ID
    AND s.STATE IN (2,4 )
    /* Link a subscription with its subscription type */
LEFT JOIN SATS.subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id
    /* Link subscription type with it's global-name */
LEFT JOIN SATS.products prod
ON
    st.center = prod.center
    AND st.id = prod.id
WHERE
p.persontype =  4 /*corporate*/
    /*corporate*/
    AND p.STATUS = 1