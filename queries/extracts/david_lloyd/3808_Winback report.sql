-- The extract is extracted from Exerp on 2026-02-08
-- Product Configuration - Extract - Winback report - EC-10721
WITH
    params AS
    (   SELECT
            c.name                          AS center,
            c.id                            AS CENTER_ID,
            TO_DATE(:StopDate,'YYYY-MM-DD') AS STOP_DATE
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
    ,
    leave_quest AS
    (   SELECT
            * ,
            CAST(CAST((xpath('//question/id/text()',xml_element))[1] AS TEXT) AS INTEGER) AS qqid ,
            CAST(CAST((xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))
            [ 1] AS TEXT) AS INTEGER) AS AID ,
            CAST((xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element)
            ) ))[1 ] AS TEXT) AS ANSWER_TEXT
        FROM
            (   SELECT
                    Q.id ,
                    Q.name ,
                    q.CREATION_TIME ,
                    q.externalid ,
                    unnest(xpath('//question',XMLPARSE(DOCUMENT convert_from(q.QUESTIONS, 'UTF-8'))
                    )) AS xml_element
                FROM
                    QUESTIONNAIRES q
                WHERE
                    q.name = 'Reason for Leaving'-- Reason for Leaving
            ) t
    )
    ,
    leave_reason_answer AS
    (   SELECT
            *
        FROM
            (   SELECT
                    QUN.CENTER ,
                    QUN.ID ,
                    qun.LOG_TIME ,
                    leave_quest.ANSWER_TEXT ,
                    ROW_NUMBER() over (
                                   PARTITION BY
                                       qun.center ,
                                       qun.id
                                   ORDER BY
                                       qun.LOG_TIME DESC) AS rnk
                FROM
                    QUESTION_ANSWER QA
                JOIN
                    QUESTIONNAIRE_ANSWER QUN
                ON
                    QA.ANSWER_CENTER = QUN.CENTER
                AND QA.ANSWER_ID = QUN.ID
                AND QA.ANSWER_SUBID = QUN.SUBID
                JOIN
                    QUESTIONNAIRE_CAMPAIGNS QC
                ON
                    QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
                JOIN
                    leave_quest
                ON
                    leave_quest.ID = QC.QUESTIONNAIRE
                AND qa.QUESTION_ID = leave_quest.qqid
                AND qa.NUMBER_ANSWER = leave_quest.AID
                WHERE
                    qun.COMPLETED)
        WHERE
            rnk = 1
    )
    ,
    scStop AS
    (   SELECT
            *
        FROM
            (   SELECT
                    scStop.* ,
                    ROW_NUMBER() over (
                                   PARTITION BY
                                       scStop.OLD_SUBSCRIPTION_CENTER ,
                                       scStop.OLD_SUBSCRIPTION_ID
                                   ORDER BY
                                       scStop.CHANGE_TIME DESC) AS rnk
                FROM
                    SUBSCRIPTION_CHANGE scStop -- The newly introduced join to fetch lesser rows
                WHERE
                    scStop.TYPE = 'END_DATE' )
        WHERE
            rnk =1
    )
SELECT
    * ,
    CASE
        WHEN "Reason For Cancellation" IN ('Banned',
                                           'Cool Off - Product/Service/Facility',
                                           'Cool Off - Travel Time to Club',
                                           'Cool Off - Other',
                                           'Deceased',
                                           'Insolvency',
                                           'Loss of Job',
                                           'Personal - Medical',
                                           'Personal - Relocation',
                                           'HOBADDEBT')
        THEN 'No'
        WHEN (
                "Organization"='Gymflex'
            OR  "Subscription" LIKE '%Gymflex%'
            OR  "Payer Subscription" LIKE '%Gymflex%')
        THEN 'No'
        WHEN "Cancellation Label" = 'immediate leaver'
        THEN 'No'
        ELSE 'Yes'
    END AS Included
FROM
    (   SELECT
            prod.name AS "Subscription",
            CASE
                WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
                    hobaddebt.last_edit_time) = hobaddebt.last_edit_time
                AND lower(hobaddebt.txtvalue) = 'yes'
                THEN 'HOBADDEBT'
                WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
                    hobaddebt.last_edit_time) = reasonforleaving.last_edit_time
                THEN reasonforleaving.txtvalue
                ELSE leave_reason_answer.answer_text
            END                                               AS "Reason For Cancellation",
            COALESCE(payer.external_id,payer_ext_id.txtvalue) AS "Payer ID",
            COALESCE(p.external_id,person_ext_id.txtvalue)    AS "Member Cancelling ID",
            s.end_date                                        AS "Stop Date",
            params.center                                     AS "Scope",
            CASE
                WHEN date_trunc('month',longtodatec(scStop.CHANGE_TIME,p.center)) = date_trunc
                    ('month',s.end_Date)
                THEN 'immediate leaver'
                WHEN date_trunc('month',longtodatec(scStop.CHANGE_TIME,p.center)) < date_trunc
                    ('month',s.end_Date)
                THEN 'good leaver'
            END                                 AS "Cancellation Label",
            prod_payer.name                     AS "Payer Subscription",
            EXTRACT(YEAR FROM age(p.birthdate)) AS "Age",
            CASE
                WHEN p.persontype = 0
                THEN 'Private'
                WHEN p.persontype = 1
                THEN 'Student'
                WHEN p.persontype = 2
                THEN 'Staff'
                WHEN p.persontype = 3
                THEN 'Friend'
                WHEN p.persontype = 4
                THEN 'Corporate'
                WHEN p.persontype = 5
                THEN 'One Man Corporate'
                WHEN p.persontype = 6
                THEN 'Family'
                WHEN p.persontype = 7
                THEN 'Senior'
                WHEN p.persontype = 8
                THEN 'Guest'
                WHEN p.persontype = 9
                THEN 'Child'
                WHEN p.persontype = 10
                THEN 'External Staff'
            END                       AS "Member Type",
            s.subscription_price      AS "Subscription Price",
            latest_join_attr.txtvalue AS "Latest Join Date",
            CASE p.status
                WHEN 0
                THEN 'Lead'
                WHEN 1
                THEN 'Active'
                WHEN 2
                THEN 'Inactive'
                WHEN 3
                THEN 'Temporary Inactive'
                WHEN 4
                THEN 'Transferred'
                WHEN 5
                THEN 'Duplicate'
                WHEN 6
                THEN 'Prospect'
                WHEN 7
                THEN 'Deleted'
                WHEN 8
                THEN 'Anonymized'
                WHEN 9
                THEN 'Contact'
                ELSE 'Unknown'
            END AS "Status",
            CASE
                WHEN fc.total_debt>0
                THEN 0
                ELSE fc.total_debt
            END                               AS "Over Due Debt",
            COALESCE(hobaddebt.txtvalue,'No') AS "HO BAD DEBT",
            company.lastname                  AS "Organization"
        FROM
            (select distinct on (s.owner_center, s.owner_id) s.owner_center, s.owner_id, s.end_date, s.center,s.id, s.subscription_price, s.subscriptiontype_center, s.subscriptiontype_id from subscriptions s order by s.owner_center, s.owner_id, s.end_date desc) s
        JOIN
            persons p
        ON
            s.OWNER_CENTER = p.CENTER
        AND s.OWNER_ID = p.ID
        JOIN
            params
        ON
            p.CENTER=params.CENTER_ID
        AND
            (
                s.end_date + INTERVAL '1 day')
            = date_trunc('month', s.end_date) + INTERVAL '1 month'
        AND s.end_date BETWEEN params.STOP_DATE - INTERVAL '30 days' AND params.STOP_DATE +
            INTERVAL '4 months'
            
        JOIN
            products prod
        ON
            prod.center = s.subscriptiontype_center
        AND prod.id = s.subscriptiontype_id
        JOIN
            product_group pg
        ON
            prod.primary_product_group_id<>366
        AND prod.primary_product_group_id=pg.id
        AND pg.exclude_from_member_count=false --exclude gymflex primary
        JOIN
            (   SELECT
                    customerid,
                    customercenter,
                    SUM(balance) AS total_debt
                FROM
                    account_receivables
                GROUP BY
                    customerid,
                    customercenter) fc
        ON
            P.ID = fc.customerid
        AND P.CENTER = fc.customercenter
        JOIN
            scStop
        ON
            s.center= scStop.old_subscription_center
        AND s.id= scStop.old_subscription_id
        LEFT JOIN
            leave_reason_answer
        ON
            leave_reason_answer.center = p.center
        AND leave_reason_answer.id = p.id
        LEFT JOIN
            PERSON_EXT_ATTRS hobaddebt
        ON
            p.center=hobaddebt.PERSONCENTER
        AND p.id=hobaddebt.PERSONID
        AND hobaddebt.name='HOBADDEBT'
        AND lower(hobaddebt.txtvalue) ='yes'
        LEFT JOIN
            PERSON_EXT_ATTRS reasonforleaving
        ON
            p.center=reasonforleaving.PERSONCENTER
        AND p.id=reasonforleaving.PERSONID
        AND reasonforleaving.name='REASONFORLEAVING'
        AND reasonforleaving.txtvalue IS NOT NULL
        LEFT JOIN
            relatives op
        ON
            op.relativecenter = p.center
        AND op.relativeid = p.id
        AND op.rtype = 12 -- EFT_PAYER
        AND op.status = 1 -- FRIEND
        LEFT JOIN
            persons payer
        ON
            op.center = payer.center
        AND op.id = payer.id
        LEFT JOIN
            (select distinct on (s.owner_center, s.owner_id) s.owner_center, s.owner_id, s.subscriptiontype_center, s.subscriptiontype_id from subscriptions s order by s.owner_center, s.owner_id, s.end_date desc) sc_payer
        ON
            sc_payer.owner_center=payer.center
        AND sc_payer.owner_id=payer.id

        LEFT JOIN
            products prod_payer
        ON
            prod_payer.center = sc_payer.subscriptiontype_center
        AND prod_payer.id = sc_payer.subscriptiontype_id
        LEFT JOIN
            PERSON_EXT_ATTRS latest_join_attr
        ON
            p.center=latest_join_attr.PERSONCENTER
        AND p.id=latest_join_attr.PERSONID
        AND latest_join_attr.name='LATESTJOINDATE'
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            ST.ID=s.subscriptiontype_id
        AND ST.center=s.subscriptiontype_center
        AND st.st_type<>0
        LEFT JOIN
            person_ext_attrs person_ext_id
        ON
            p.id = person_ext_id.personid
        AND p.center = person_ext_id.personcenter
        AND person_ext_id.name = '_eClub_OldSystemPersonId'
        LEFT JOIN
            person_ext_attrs payer_ext_id
        ON
            payer.id = payer_ext_id.personid
        AND payer.center = payer_ext_id.personcenter
        AND payer_ext_id.name = '_eClub_OldSystemPersonId'
        LEFT JOIN
            RELATIVES com_rel
        ON
            com_rel.RELATIVECENTER = p.CENTER
        AND com_rel.RELATIVEID = p.ID
        AND com_rel.RTYPE IN (2,3,6,8,10,17)
        AND com_rel.STATUS < 3
        LEFT JOIN
            persons company
        ON
            company.CENTER = com_rel.CENTER
        AND company.ID = com_rel.ID
        WHERE
            NOT EXISTS
            (   SELECT
                    1
                FROM
                    subscriptions s2
                WHERE
                    s2.owner_center = p.center
                AND s2.owner_id = p.id
                AND s2.id <> s.id -- another subscription
                AND
                    (
                        -- still active after the report stop date OR no end date
                        s2.end_date IS NULL
                        -- or a new subscription that starts in the future
                    OR  s2.start_date > params.stop_date --+ INTERVAL '4 months'
                    ) ) );