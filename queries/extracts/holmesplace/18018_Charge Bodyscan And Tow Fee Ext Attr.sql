-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8118

SELECT
    per.center || 'p' || per.id AS PersonId,
    per.fullname,
    TO_CHAR(to_date(orgstartdate.txtvalue, 'YYYY-MM-DD'), 'YYYY-MM-DD') AS "Original Start Date",
    (CASE per.persontype
        WHEN 0 THEN 'Private'
        WHEN 1 THEN 'Student'
        WHEN 2 THEN 'Staff'
        WHEN 3 THEN 'Friend'
        WHEN 4 THEN 'Corporate'
        WHEN 5 THEN 'Onemancorporate'
        WHEN 6 THEN 'Family'
        WHEN 7 THEN 'Senior'
        WHEN 8 THEN 'Guest'
        WHEN 9 THEN 'Child'
        WHEN 10 THEN 'External_Staff'
        ELSE 'Unknown'
    END) AS "Person Type",           
    (CASE per.status
        WHEN 0 THEN 'Lead'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Inactive'
        WHEN 3 THEN 'Temporary Inactive'
        WHEN 4 THEN 'Transferred'
        WHEN 5 THEN 'Duplicate'
        WHEN 6 THEN 'Prospect'
        WHEN 7 THEN 'Deleted'
        WHEN 8 THEN 'Anonymized'
        WHEN 9 THEN 'Contact'
        ELSE 'Unknown'
    END) AS "Person status",                                                                                                                    
    chargebody.txtvalue                                                                                                                                                                          AS CHARGEBODYSCANFEE,
    chargetow.txtvalue                                                                                                                                                                           AS CHARGETOWFEEDE,
    TO_CHAR(s.start_date, 'YYYY-MM-DD')                                                                                                                                                          AS "Latest Subscription Start Date",
    prod.name                                                                                                                                                                                    AS "Latest Subscription Name",
    (CASE s.state
        WHEN 2 THEN 'Active'
        WHEN 3 THEN 'Ended'
        WHEN 4 THEN 'Frozen'
        WHEN 7 THEN 'Window'
        WHEN 8 THEN 'Created'
        ELSE 'Unknown'
    END) AS "Latest Subscription State"
FROM
    persons per
LEFT JOIN
    PERSON_EXT_ATTRS orgstartdate
ON
    per.center = orgstartdate.personcenter
    AND per.id = orgstartdate.personid
    AND orgstartdate.name = 'OriginalStartDate'
LEFT JOIN
    PERSON_EXT_ATTRS chargebody
ON
    per.center = chargebody.personcenter
    AND per.id = chargebody.personid
    AND chargebody.name = 'CHARGEBODYSCANFEE'
LEFT JOIN
    PERSON_EXT_ATTRS chargetow
ON
    per.center = chargetow.personcenter
    AND per.id = chargetow.personid
    AND chargetow.name = 'CHARGETOWFEEDE'
LEFT JOIN
    (
        SELECT
            s1.owner_center,
            s1.owner_id,
            MAX(s1.start_date) AS start_date
        FROM
            subscriptions s1
        WHERE
            s1.state IN (2,4,8)
        GROUP BY
            s1.owner_center,
            s1.owner_id )latest_sub
ON
    latest_sub.owner_center = per.center
    AND latest_sub.owner_id = per.id
LEFT JOIN
    subscriptions s
ON
    s.owner_center = per.center
    AND s.owner_id = per.id
    AND s.start_date = latest_sub.start_date
LEFT JOIN
    products prod
ON
    prod.center = s.subscriptiontype_center
    AND prod.id = s.subscriptiontype_id
WHERE
    per.center IN ($$Scope$$)
    AND ( ((
                $$OriginalStartDate$$) = to_date('1970-01-01', 'yyyy-mm-dd')
            AND orgstartdate.txtvalue IS NULL)
        OR ((
                $$OriginalStartDate$$) != to_date('1970-01-01', 'yyyy-mm-dd')
            AND to_date(orgstartdate.txtvalue, 'yyyy-mm-dd') >= ($$OriginalStartDate$$)))
    AND per.status IN ($$PersonStatus$$)
    AND ( (
            1 = $$ChargeExtAttr$$
            AND chargebody.personcenter IS NULL)
        OR (
            2 = $$ChargeExtAttr$$
            AND chargetow.personcenter IS NULL)
        OR (
            3 = $$ChargeExtAttr$$
            AND chargebody.personcenter IS NULL
            AND chargetow.personcenter IS NULL) )