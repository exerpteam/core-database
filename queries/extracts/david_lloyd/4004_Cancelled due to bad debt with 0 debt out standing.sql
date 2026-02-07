-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/EC-10557
WITH
    subscriptions_ranked AS
    (   SELECT
            s.owner_center,
            s.owner_id,
            s.id,
            s.center,
            s.subscriptiontype_center,
            s.subscriptiontype_id,
            s.end_date,
            ROW_NUMBER() OVER (
                           PARTITION BY
                               s.owner_center,
                               s.owner_id
                           ORDER BY
                               s.end_date DESC NULLS LAST ) AS rnk,
            BOOL_OR(s.end_date IS NULL) OVER
                                              (
                                          PARTITION BY
                                              s.owner_center,
                                              s.owner_id ) AS has_active
        FROM
            SUBSCRIPTIONS s
    )
    ,
    target_members AS
    (   SELECT
            sr.owner_center,
            sr.owner_id,
            sr.id,
            sr.center,
            sr.subscriptiontype_center,
            sr.subscriptiontype_id,
            sr.end_date
        FROM
            subscriptions_ranked sr
        WHERE
            sr.rnk = 1
        AND sr.has_active = FALSE
        AND sr.end_date >= CURRENT_DATE - INTERVAL '2 month'
        AND sr.end_date <= CURRENT_DATE
    )
    ,
    ar_with_debt_fee AS
    (   SELECT
            AR.CUSTOMERID     AS customer_id,
            AR.CUSTOMERCENTER AS customer_center,
            AR.BALANCE        AS balance,
            -- how many "bad" open transactions (not Membership Debt Fee, or no product)
            SUM(
            CASE
                WHEN art.STATUS <> 'CLOSED'
                AND (
                        pd.name IS NULL
                    OR  pd.name <> 'Membership Debt Fee')
                THEN 1
                ELSE 0
            END ) AS non_debt_open_count
        FROM
            ACCOUNT_RECEIVABLES AR
        JOIN
            target_members tm
        ON
            tm.owner_center = AR.CUSTOMERCENTER
        AND tm.owner_id = AR.CUSTOMERID
        JOIN
            AR_TRANS art
        ON
            AR.CENTER = art.CENTER
        AND AR.ID = art.ID
        LEFT JOIN
            INVOICE_LINES_MT ivl
        ON
            art.REF_TYPE = 'INVOICE'
        AND art.REF_CENTER = ivl.CENTER
        AND art.REF_ID = ivl.ID
        LEFT JOIN
            PRODUCTS pd
        ON
            pd.CENTER = ivl.PRODUCTCENTER
        AND pd.ID = ivl.PRODUCTID
        WHERE
            AR.AR_TYPE = 4
        GROUP BY
            AR.CUSTOMERID,
            AR.CUSTOMERCENTER,
            AR.BALANCE
        HAVING
            SUM(
            CASE
                WHEN art.STATUS <> 'CLOSED'
                AND (
                        pd.name IS NULL
                    OR  pd.name <> 'Membership Debt Fee')
                THEN 1
                ELSE 0
            END ) = 0
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
                    qun.COMPLETED = 1)
        WHERE
            rnk = 1
    )
SELECT
    P.CENTER || 'p' || P.ID AS "Member ID",
    P.EXTERNAL_ID           AS "External ID",
    C.NAME                  AS "Club",
    fc.balance              AS "Account balance",
    tm.end_date             AS "Last stop date",
    prod.NAME               AS "Last subscription name",
    prod.GLOBALID           AS "Last subscription GLOBAL ID",
    C.COUNTRY               AS "Country",
    CASE
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
            hobaddebt.last_edit_time) = hobaddebt.last_edit_time
        AND lower(hobaddebt.txtvalue) = 'yes'
        THEN 'HOBADDEBT'
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
            hobaddebt.last_edit_time) = reasonforleaving.last_edit_time
        THEN reasonforleaving.txtvalue
        ELSE leave_reason_answer.answer_text
    END AS "Reason For Cancellation"
FROM
    target_members tm
JOIN
    PERSONS P
ON
    P.CENTER = tm.owner_center
AND P.ID = tm.owner_id
JOIN
    PERSON_EXT_ATTRS hobaddebt
ON
    P.CENTER = hobaddebt.PERSONCENTER
AND P.ID = hobaddebt.PERSONID
AND hobaddebt.NAME = 'HOBADDEBT'
AND lower(hobaddebt.TXTVALUE) = 'yes'
JOIN
    CENTERS C
ON
    P.CENTER = C.ID
JOIN
    ar_with_debt_fee fc
ON
    P.ID = fc.customer_id
AND P.CENTER = fc.customer_center
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = tm.subscriptiontype_center
AND prod.ID = tm.subscriptiontype_id
LEFT JOIN
    PERSON_EXT_ATTRS reasonforleaving
ON
    p.center=reasonforleaving.PERSONCENTER
AND p.id=reasonforleaving.PERSONID
AND reasonforleaving.name='REASONFORLEAVING'
LEFT JOIN
    leave_reason_answer
ON
    leave_reason_answer.center = p.center
AND leave_reason_answer.id = p.id;
 