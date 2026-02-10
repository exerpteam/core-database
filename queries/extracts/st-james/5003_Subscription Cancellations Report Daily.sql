-- The extract is extracted from Exerp on 2026-02-08
-- To be scheduled for daily run. Grabs until until of current month
WITH
    params AS
    (
        SELECT
            c.name                             AS center,
            c.id                               AS CENTER_ID,
            TO_DATE('2026-01-01','YYYY-MM-DD') AS FROMDATE,
            TO_DATE( (date_trunc('month', CURRENT_DATE) + interval '1 month' - interval '1 day')::
            text, 'YYYY-MM-DD') AS TODATE,
            CAST(datetolongc(TO_CHAR(to_date('2026-01-01','YYYY-MM-DD'),'YYYY-MM-DD'),id) AS BIGINT
            ) AS from_Date_ts,
            CAST( datetolongc( TO_CHAR( (date_trunc('month', CURRENT_DATE) + interval '1 month')::
            DATE, 'YYYY-MM-DD' ), id ) AS BIGINT ) AS to_Date_ts
        FROM
            centers c
        WHERE
            c.id IN (:Scope)
    )
    ,
    cancellation_quest AS
    (
        SELECT
            "ID",
            (xpath('//question/id/text()',xml_element))[1]:: TEXT AS "QQID",
            (xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))[1]::TEXT
            AS "AID",
            (xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element))))[
            1] AS "ANSWER_TEXT"
        FROM
            (
                SELECT
                    Q.id            AS "ID",
                    Q.name          AS "NAME",
                    q.CREATION_TIME AS "CREATION_DATE",
                    q.externalid    AS "EXTERNAL_ID" ,
                    unnest(xpath('//question',XMLPARSE(DOCUMENT convert_from(q.QUESTIONS, 'UTF-8')
                    ) )) AS xml_element
                FROM
                    QUESTIONNAIRES q
                WHERE
                    q.id = 2 ) t
        WHERE
            btrim(CAST(xpath('//ques/options/option',xml_element) AS VARCHAR),'{}') = ''
    )
SELECT
    params.center AS "Center",
    CASE
        WHEN per.PERSONTYPE = 0
        THEN 'PRIVATE'
        WHEN per.PERSONTYPE = 1
        THEN 'STUDENT'
        WHEN per.PERSONTYPE = 2
        THEN 'STAFF'
        WHEN per.PERSONTYPE = 3
        THEN 'FRIEND'
        WHEN per.PERSONTYPE = 4
        THEN 'CORPORATE'
        WHEN per.PERSONTYPE = 5
        THEN 'ONEMANCORPORATE'
        WHEN per.PERSONTYPE = 6
        THEN 'FAMILY'
        WHEN per.PERSONTYPE = 7
        THEN 'SENIOR'
        WHEN per.PERSONTYPE = 8
        THEN 'GUEST'
        WHEN per.PERSONTYPE = 9
        THEN 'CHILD'
        WHEN per.PERSONTYPE = 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END                                                             AS "Person Type",
    s.subscription_price                                            AS "Monthly Price",
    prd.name                                                        AS "Subscription Name",
    CAST(NOW() AS DATE)- s.start_date ||' Days'                     AS "Subscription Days",
    TO_CHAR(longtodatec(je.creation_time,je.p_center),'mm/dd/yyyy') AS "Cancellation Request Date",
    s.center||'ss'||s.id                                            AS "Subscription ID",
    TO_CHAR(s.end_date,'mm/dd/yyyy')                                AS "Subscription End Date",
    s.owner_center||'p'||s.owner_id                                 AS "Person ID",
    per.firstname                                                   AS "First Name",
    per.lastname                                                    AS "Last Name",
    CASE s.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'Undefined'
    END AS "Subscription State",
    CASE s.SUB_STATE
        WHEN 1
        THEN 'NONE'
        WHEN 2
        THEN 'AWAITING_ACTIVATION'
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
        ELSE 'Undefined'
    END                             AS "Subscription Sub State",
    per.address1                    AS "Street Address 1",
    per.address2                    AS "Street Address 2",
    per.city                        AS "City",
    per.zipcode                     AS "Zip",
    email.txtvalue                  AS "Email",
    phone.txtvalue                  AS "Phone",
    company.center||'p'||company.id AS "Company Key",
    company.fullname                AS "Company",
    ca.name                         AS "Company Agreement",
    company.address1                AS "Company Address 1",
    company.address2                AS "Company Address 2",
    company.zipcode                 AS "Company Zip",
    company.city                    AS "Company City",
    cq."ANSWER_TEXT"                AS "Cancelleation Reason"
FROM
    params
JOIN
    persons per
ON
    per.center = params.CENTER_ID
JOIN
    subscriptions s
ON
    s.owner_center = per.center
AND s.owner_id = per.id
JOIN
    products prd
ON
    prd.center = s.subscriptiontype_center
AND prd.id = s.subscriptiontype_id
LEFT JOIN
    person_ext_attrs email
ON
    per.center = email.personcenter
AND per.id = email.personid
AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs phone
ON
    per.center = phone.personcenter
AND per.id = phone.personid
AND phone.name = '_eClub_PhoneSMS'
LEFT JOIN
    relatives r
ON
    r.center = per.center
AND r.id = per.id
AND r.rtype = 3 -- Company agreement
AND r.status < 2
LEFT JOIN
    companyagreements ca
ON
    ca.center = r.relativecenter
AND ca.id = r.relativeid
AND ca.subid = r.relativesubid
LEFT JOIN
    persons company
ON
    company.center = ca.center
AND company.id = ca.id
JOIN
    (
        SELECT
            RANK() over ( PARTITION BY j.person_center, j.person_id, j.ref_center, j.ref_id
            ORDER BY j.creation_time DESC) AS rnk,
            j.person_center                AS p_center,
            j.person_id                    AS p_id,
            j.ref_center                   AS sub_center,
            j.ref_id                       AS sub_id,
            j.creation_time
        FROM
            journalentries j
        WHERE
            j.jetype = 18 -- 'EFT subscription termination'
        AND j.state = 'ACTIVE' ) je
ON
    je.rnk = 1
AND per.center = je.p_center
AND per.id = je.p_id
AND s.center = je.sub_center
AND s.id = je.sub_id
LEFT JOIN
    (
        SELECT
            qun.center                                                 AS person_center,
            qun.id                                                         AS person_id,
            qa.question_id::TEXT                                                   AS question_id,
            qa.number_answer::TEXT                                                 AS number_answer,
            rank() over (partition BY qun.center, qun.id ORDER BY QUN.log_time DESC) AS rnk
        FROM
            QUESTIONNAIRE_ANSWER QUN
        JOIN
            QUESTION_ANSWER QA
        ON
            QA.ANSWER_CENTER = QUN.CENTER
        AND QA.ANSWER_ID = QUN.ID
        AND QA.ANSWER_SUBID = QUN.SUBID
        AND QA.question_id = 1
        WHERE
            qun.status = 'COMPLETED') last_answer
ON
    last_answer.person_center = per.center
AND last_answer.person_id = per.id
AND last_answer.rnk = 1
LEFT JOIN
    cancellation_quest cq
ON
    cq."QQID" = last_answer.question_id
AND cq."AID" = last_answer.number_answer
WHERE
    -- s.end_date >= params.fromdate
    -- and s.end_date < params.todate
    je.creation_time >= params.from_Date_ts
AND je.creation_time < params.to_Date_ts
    -- AND s.sub_state IN (3,4,5,6)
AND prd.globalid IN ($$product_grp$$)
AND s.end_date IS NOT NULL
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions s2
        WHERE
            s2.start_date <= (date_trunc('month', longtodatec(je.creation_time,je.p_center)) +
            INTERVAL '1 month - 1 day')::DATE
        AND s2.start_date >= longtodatec(je.creation_time,je.p_center)
        AND s2.owner_center = per.center
        AND s2.owner_id = per.id )