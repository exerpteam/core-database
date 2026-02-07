WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval
            ' 6 months', 'YYYY-MM-DD'), c.id) AS BIGINT) AS cutDate,
            c.id                                         AS centerID,
c.name AS centerName
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
    ,
    visits AS MATERIALIZED
    (
        SELECT DISTINCT
            c.PERSON_CENTER,
            c.PERSON_ID,
            COUNT(*) AS total_visits
        FROM
            CHECKINS c
        JOIN
            params
        ON
            params.centerid = c.person_center
        WHERE
            c.checkout_time != c.checkin_time
        AND NOT c.checkout_time - c.checkin_time < 1000
        AND c.CHECKIN_TIME > params.cutDate
        AND c.person_id IS NOT NULL
        GROUP BY
            person_id,
            person_center
    )
SELECT
    CASE r2.RTYPE WHEN 12 THEN r2.center||'p'||r2.id ELSE NULL END           AS MyPayerID,
    p.center ||'p'|| p.id                       AS           "MemberID",
    p.external_id                               AS           "MemberExternalID",
    par.centerName                              AS           "Club",
CASE 
                WHEN CanEmail.TXTVALUE = 'true' THEN 'Yes'
                WHEN CanEmail.TXTVALUE = 'false' THEN 'No'
                ELSE 'No'
         END AS "CanEmail",
    ROUND(((CURRENT_DATE - p.birthdate)/365),0) AS           "Age",
    ROUND(((CURRENT_DATE - p.FIRST_ACTIVE_START_DATE)/30),1) "Tenure",
    COALESCE(vi.total_visits,0) AS                           "TotalVisits",
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        ELSE 'UNKNOWN'
    END                    AS "PersonType",
    comp.Fullname          AS "CompanyName",
            CASE s.state
        WHEN 2
        THEN 'ACTIVE'
        WHEN 4
        THEN 'FROZEN'
        ELSE 'Not frozen or Active sub state'
    END                                         AS "Sub_State",
        CASE s.sub_state
        WHEN 1
        THEN 'NONE'
        WHEN 3
        THEN 'UPGRADED'
                WHEN 4
        THEN 'DOWNGRADED'
                WHEN 5
        THEN 'EXTENDED'
                WHEN 6
        THEN 'TRANSFERRED'
                WHEN 7
        THEN 'REGRETTED'
                WHEN 8
        THEN 'CANCELLED'
                WHEN 9
        THEN 'BLOCKED'
                WHEN 10
        THEN 'CHANGED'
        ELSE 'N/A'
    END                                         AS "Sub_State",
    s.center ||'ss'|| s.id AS "SubscriptionID",
    pr.name                AS "Subscription",
    s.subscription_price   AS "SubscriptionPrice",
    s.binding_end_date     AS "BindingEndDate"
FROM
    persons p
LEFT JOIN --Family relation / Friend
             RELATIVES r
         ON
             r.CENTER = p.CENTER
             AND r.id = p.ID
             AND r.RTYPE IN (4,1,3)
             AND r.STATUS =1
         LEFT JOIN --Other Payer
             RELATIVES r2
         ON
             r2.RELATIVECENTER = p.CENTER
             AND r2.RELATIVEID = p.ID
             AND r2.RTYPE IN (2,12)
             AND r2.STATUS = 1
JOIN
    params par
ON
    par.centerID = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
LEFT JOIN
    PERSON_EXT_ATTRS CanEmail
 ON
      p.center=CanEmail.PERSONCENTER
      AND p.id=CanEmail.PERSONID
      AND CanEmail.name='eClubIsAcceptingEmailNewsLetters'
      AND CanEmail.TXTVALUE IS NOT NULL
LEFT JOIN
    visits vi
ON
    vi.person_center = p.center
AND vi.person_id = p.id
LEFT JOIN
    RELATIVES r3
ON
    r3.RTYPE = 3
AND r3.CENTER = p.CENTER
AND r3.ID = p.ID
AND r3.STATUS < 2
LEFT JOIN
    persons comp
ON
    comp.CENTER = r3.RELATIVECENTER
AND comp.ID = r3.RELATIVEID
WHERE
    s.state IN (2,4)
-- AND 
        -- s.sub_state <> 9
AND pr.name IN ('12 Month DD',
                '12 Month DD Club Only',
                '12 Month Off Peak',
                '18-21 12 Month DD',
                '22-25 12 Month DD',
                '65+ 12 Month DD',
                'Multi Access Corporate 12 Month',
                'Reciprocal Access Corporate 12 Month',
                'Multi Access 12 Month Staff Buddy 50% Off',
                'Reciprocal Access 12 Month Staff Buddy 50% Off',
                'Recommitment: 12 Month',
                'Recommitment: 12 Month Age Related',
                'Recommitment: 12 Month Corporate',
                'Recommitment: 12 Month Off Peak',
                'Recommitment: 6/12 month',
                'Recommitment: 6/12 month age related',
                'Recommitment: 6/12 month corporate',
                'Recommitment: 6/12 month off peak')
AND s.binding_end_date BETWEEN :fromDate AND :toDate