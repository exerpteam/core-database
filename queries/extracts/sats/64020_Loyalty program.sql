SELECT
    *
FROM
    (
        SELECT DISTINCT
            p.CENTER ,
            p.ID ,
            p.FIRSTNAME,
            p.LASTNAME,
            DECODE(p.SEX, 'M','Male','F','Female')           AS Gender,
            floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12)    age,
            p.ZIPCODE,
            DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                        AS PersonType,
            DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
            TRUNC(exerpsysdate() - p.LAST_ACTIVE_START_DATE) + 1                                                                                                                                       RealMemberdays,
            decode(ext.TXTVALUE,null,'NONE',ext.TXTVALUE) as current_group,
            CASE
                WHEN (( TRUNC(exerpsysdate() - p.LAST_ACTIVE_START_DATE) + 1 BETWEEN 0 AND 299) 
                        AND ( ppg.PRODUCT_GROUP_ID = 38202))
                THEN 'Level1'
                WHEN ((TRUNC(exerpsysdate() - p.LAST_ACTIVE_START_DATE) + 1 BETWEEN 300 AND 549)
                        AND ( ppg.PRODUCT_GROUP_ID = 38202))
                THEN 'Level2'
                WHEN ((TRUNC(exerpsysdate() - p.LAST_ACTIVE_START_DATE) + 1 BETWEEN 550 AND 1094)
                        AND ( ppg.PRODUCT_GROUP_ID = 38202))
                THEN 'Level3'
                WHEN ((TRUNC(exerpsysdate() - p.LAST_ACTIVE_START_DATE) + 1 > 1095)
                        AND ( ppg.PRODUCT_GROUP_ID = 38202))
                THEN 'Level4'
            END AS state_group
            
        FROM
            persons p
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4)
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
            AND s.SUBSCRIPTIONTYPE_ID = st.ID
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppg
        ON
            ppg.PRODUCT_CENTER = st.CENTER
            AND ppg.PRODUCT_ID = st.ID
            AND ppg.PRODUCT_GROUP_ID IN (38202)
        LEFT JOIN
            PERSON_EXT_ATTRS ext
        ON
            ext.PERSONCENTER = p.CENTER
            AND ext.PERSONID = p.ID
            AND ext.NAME = 'UNBROKENMEMBERSHIPGROUPSE'
        WHERE
            p.center in (:center)
            AND p.status IN (1,3)) results
HAVING
    results.state_group = :state_group
 --   and results.current_group<>results.state_group
GROUP BY
    results.CENTER ,
    results.ID ,
    results.FIRSTNAME,
    results.LASTNAME,
    results.Gender,
    results.age,
    results.ZIPCODE,
    results.PersonType,
    results.STATUS,
    results.RealMemberdays,
    results.current_group,
    results.state_group