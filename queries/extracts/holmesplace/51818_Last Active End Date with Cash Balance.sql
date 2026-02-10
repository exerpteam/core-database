-- The extract is extracted from Exerp on 2026-02-08
-- with name and Cash account balance
WITH pmp_xml AS (
        SELECT 
                m.id, 
                CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml 
        FROM 
                hp.masterproductregister m 
),
binding_period_temp AS 
(
        SELECT
                mpr.ID,
                CAST(UNNEST(xpath('//subscriptionType/bindingPeriod/period/text()', pmp.pxml)) AS TEXT) AS bindingPeriod
        FROM
                hp.masterproductregister mpr
        JOIN 
                pmp_xml pmp
                ON
                        pmp.ID = mpr.ID
),
PARAMS AS
    (
        SELECT
            TO_CHAR(CAST($$minOSDDate$$ AS DATE),'YYYY-MM-DD')   AS minOSDDate,
            TO_CHAR(CAST($$maxOSDDate$$ AS DATE) + interval '1 day','YYYY-MM-DD') AS maxOSDDate
    )
SELECT
    co.name                                       AS "Country",
    c.SHORTNAME                                   AS "Short Club Name",
    cp.center||'p'||cp.id                         AS "Person ID",
	cp.fullname									AS "Name",
    TO_CHAR(cp.LAST_ACTIVE_END_DATE,'DD-MM-YYYY') AS "Last Active End Date",
    peaOSD.TXTVALUE                               AS "Original Start Date",
    CASE cp.PERSONTYPE
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
        ELSE NULL
    END AS "Person Type",
    CASE cp.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE NULL
    END             AS "Current Status",
    latest_sub.name AS "Last Active Sub Name",
    CASE latest_sub.SUB_STATE
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
        ELSE NULL
    END                           AS "Last Active Sub_state",
    latest_sub.SUBSCRIPTION_PRICE AS "Last Active Subs Price",
    CASE
                WHEN mpr2.PRODUCT IS NOT NULL
                        THEN bp2.bindingPeriod
                WHEN mpr2.PRODUCT IS NULL AND mpr.PRODUCT IS NOT NULL
                        THEN bp1.bindingPeriod
                ELSE NULL
    END "Last Active BindingPeriod",

	ar.balance AS "Cash Balance", 
  			
    TO_CHAR(cp.BIRTHDATE,'DD-MM-YYYY') AS "Date of Birth",
    CASE
        WHEN cp.SEX = 'M'
        THEN 'Male'
        WHEN cp.SEX = 'F'
        THEN 'Female'
        ELSE cp.SEX
    END                         AS "Gender",
    peaEmail.TXTVALUE           AS "Email",
    peaChannelEmail.TXTVALUE    AS "Allow Channel Email",
    peaGDPROPTIN.TXTVALUE       AS "Gdpr Opt-in",
    peaGDPRDOUBLEOPTIN.TXTVALUE AS "Gdpr Double Opt-in",
  --  (xpath('//question[id/text()='|| 2 || ']/options/option[id/text()='||             quest.number_answer ||']/optionText/text()',xml_q))[0] AS "Reason for Leaving 1",
regexp_replace(xpath('//question[id/text()='|| 2 || ']/options/option[id/text()='|| quest.number_answer ||']/optionText/text()',xml_q)::text, '[{}]', '', 'g')       AS "Reason for Leaving 1",
    quest.text_answer AS "Reason for Leaving 2"
FROM
    PARAMS,
    PERSONS cp
JOIN
    centers c
ON
    c.ID = cp.CENTER
JOIN
    countries co
ON
    co.ID = c.country
LEFT JOIN
    (
        SELECT
            row_number() over (partition BY cp.CENTER, cp.ID ORDER BY s.END_DATE DESC ) AS lastone,
            s.OWNER_CENTER,
            s.OWNER_ID,
            s.center,
            s.id,
            s.sub_state,
            s.subscription_price,
            pr.name,
            pr.globalid,
            pr.center prcenter,
            s.end_date
        FROM
            SUBSCRIPTIONS s
        JOIN
            PRODUCTS pr
        ON
            s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
        AND s.SUBSCRIPTIONTYPE_ID = pr.ID
        JOIN
            PERSONS cp
        ON
            cp.center = s.OWNER_CENTER
        AND cp.ID = s.OWNER_ID
        WHERE
            s.STATE IN (3,7)
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                WHERE
                    pr.center = ppg.PRODUCT_CENTER
                AND pr.id = ppg.PRODUCT_ID
                AND ppg.PRODUCT_GROUP_ID = 1605) ) latest_sub
ON
    latest_sub.owner_center = cp.center
AND latest_sub.owner_id = cp.id
AND latest_sub.lastone = 1

LEFT JOIN
	HP.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERID = cp.id
    AND ar.CUSTOMERCENTER = cp.CENTER

LEFT JOIN
    PERSON_EXT_ATTRS peaOSD
ON
    cp.center = peaOSD.PERSONCENTER
AND cp.id = peaOSD.PERSONID
AND peaOSD.name = 'OriginalStartDate'
LEFT JOIN
    PERSON_EXT_ATTRS peaEmail
ON
    cp.center = peaEmail.PERSONCENTER
AND cp.id = peaEmail.PERSONID
AND peaEmail.name = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS peaChannelEmail
ON
    cp.center = peaChannelEmail.PERSONCENTER
AND cp.id = peaChannelEmail.PERSONID
AND peaChannelEmail.name = '_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS peaGDPROPTIN
ON
    cp.center = peaGDPROPTIN.PERSONCENTER
AND cp.id = peaGDPROPTIN.PERSONID
AND peaGDPROPTIN.name = 'GDPROPTIN'
LEFT JOIN
    PERSON_EXT_ATTRS peaGDPRDOUBLEOPTIN
ON
    cp.center = peaGDPRDOUBLEOPTIN.PERSONCENTER
AND cp.id = peaGDPRDOUBLEOPTIN.PERSONID
AND peaGDPRDOUBLEOPTIN.name = 'GDPRDOUBLEOPTIN'
LEFT JOIN
    (
        SELECT
            qaa.center,
            qaa.id,
            qa1.text_answer,
            qa2.number_answer,
            qc.questionnaire
        FROM
            questionnaire_answer qaa
        JOIN
            questionnaire_campaigns qc
        ON
            qc.id = qaa.questionnaire_campaign_id
        LEFT JOIN
            QUESTION_ANSWER qa1
        ON
            qa1.ANSWER_CENTER =qaa.CENTER
        AND qa1.ANSWER_ID=qaa.ID
        AND qa1.answer_subid = qaa.subid
        AND qa1.QUESTION_ID = 1
        LEFT JOIN
            QUESTION_ANSWER qa2
        ON
            qa2.ANSWER_CENTER =qaa.CENTER
        AND qa2.ANSWER_ID=qaa.ID
        AND qa2.answer_subid = qaa.subid
        AND qa2.QUESTION_ID = 2
        WHERE
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    questionnaire_answer qaa2
                WHERE
                    qaa2.center = qaa.center
                AND qaa2.id = qaa.id
                AND qaa2.log_time > qaa.log_time) ) quest
ON
    quest.center = cp.center
AND quest.id = cp.id
LEFT JOIN
    QUESTIONNAIRES q
ON
    q.id = quest.questionnaire
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = latest_sub.GLOBALID
AND mpr.ID = mpr.DEFINITION_KEY
LEFT JOIN
    MASTERPRODUCTREGISTER mpr2
ON
    mpr2.GLOBALID = latest_sub.GLOBALID
AND mpr2.SCOPE_TYPE = 'C'
AND mpr2.SCOPE_ID = latest_sub.prcenter 
LEFT JOIN
    binding_period_temp bp1
ON
        bp1.ID = mpr.ID
LEFT JOIN
    binding_period_temp bp2
ON
        bp2.ID = mpr2.ID ,
         xmlparse(document convert_from(q.QUESTIONS, 'UTF-8')) xml_q
WHERE
    cp.PERSONTYPE IN ($$PersonType$$)
AND cp.LAST_ACTIVE_END_DATE >= cast ($$minLastActiveDate$$ as DATE)
AND cp.LAST_ACTIVE_END_DATE < cast ($$maxLastActiveDate$$ as DATE) + interval '1 day'
AND (
        params.minOSDDate = '2000-01-01'
    OR  (
            peaOSD.TXTVALUE >= params.minOSDDate
        AND peaOSD.TXTVALUE < params.maxOSDDate))
AND (
        'Any' = $$birthMonth$$
    OR  (
            TRIM(TO_CHAR(cp.BIRTHDATE,'Month')) = $$birthMonth$$))
AND (
        'Any' = $$OSDMonth$$
    OR  peaOSD.TXTVALUE IS NULL
    OR  (
            TRIM(TO_CHAR(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'),'Month')) = $$OSDMonth$$))
AND cp.center IN ($$Scope$$)
AND cp.SEX <> 'C'
AND ar.ar_type = 1
