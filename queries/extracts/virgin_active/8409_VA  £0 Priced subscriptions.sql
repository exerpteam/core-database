SELECT
    c.name                                                                                                                                                                          AS "Club name",
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS Person_STATUS,
    DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')                                                                                          AS Subscription_STATE,
    DECODE(ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect')                                                                                                                             AS Subscription_TYPE,
    s.OWNER_CENTER||'p'||s.OWNER_ID                                                                                                                                                 AS MemberID,
    s.center||'ss'||s.id "eClub subscription ID",
    pr.name AS subscription,
    s.START_DATE,
    s.END_DATE,
    s.SUBSCRIPTION_PRICE,
    pr.PRICE AS Product_Price
FROM
    VA.SUBSCRIPTIONS s
JOIN
    VA.SUBSCRIPTIONTYPES st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    VA.PRODUCTS pr
ON
    pr.center = st.center
    AND pr.id = st.id
JOIN
    VA.CENTERS c
ON
    c.id = s.center
JOIN
    VA.PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            VA.SUBSCRIPTION_PRICE sp
        WHERE
            sp.SUBSCRIPTION_CENTER = s.CENTER
            AND sp.SUBSCRIPTION_ID = s.id
            AND sp.FROM_DATE >=SYSDATE
            AND sp.PRICE != 0)
	AND S.Start_Date > TO_DATE('2015-01-01','YYYY-MM-DD')
	AND s.STATE IN ($$state$$)
    AND st.ST_TYPE IN ($$type$$)
    AND s.center IN ($$scope$$)
    AND s.SUBSCRIPTION_PRICE = 0
    AND pr.name NOT IN('Ancillary by DD base subscription',
                       'Academy Level One 1 Month',
                       'Academy Level Four 1 Month',
                       'Deployment PT',
                       'Junior Complimentary',
						'Titolare',
						'Nuoto Legacy',
						'Accompagnatore Junior',
						'Speciale Junior',
						'Freelance')
	

