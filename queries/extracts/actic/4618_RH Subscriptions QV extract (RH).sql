-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    CAST ( S.CENTER AS VARCHAR(255)) AS CENTER,
    CAST ( S.ID AS VARCHAR(255))     AS ID,
    S.CENTER || 'ss' || S.ID AS "SUBSCRIPTION_ID",
    CASE S.STATE
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
        ELSE 'UNKNOWN'
    END AS STATE,
    CASE S.SUB_STATE
        WHEN 1
        THEN 'NONE'
        WHEN 2
        THEN 'AWAITING ACTIVATION'
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
        ELSE 'UNKNOWN'
    END                                                        AS SUBSTATE,
    CAST ( S.SUBSCRIPTIONTYPE_CENTER AS VARCHAR(255)) AS SUBSCRIPTIONTYPE_CENTER,
    CAST ( S.SUBSCRIPTIONTYPE_ID AS VARCHAR(255))     AS SUBSCRIPTIONTYPE_ID,
    CAST ( S.OWNER_CENTER AS VARCHAR(255))            AS OWNER_CENTER,
    CAST ( S.OWNER_ID AS VARCHAR(255))                AS OWNER_ID,
    CURPERS.EXTERNAL_ID       AS EXTERNAL_ID,
    S.BINDING_END_DATE                                         AS BINDING_END_DATE,
    S.BINDING_PRICE                                            AS BINDING_PRICE,
    S.INDIVIDUAL_PRICE                                         AS INDIVIDUAL_PRICE,
    S.SUBSCRIPTION_PRICE                                       AS SUBSCRIPTION_PRICE,
    S.START_DATE                                               AS START_DATE,
    S.END_DATE                                                 AS END_DATE,
    S.BILLED_UNTIL_DATE                                        AS BILLED_UNTIL_DATE,
    S.REFMAIN_CENTER                                           AS REFMAIN_CENTER,
    S.REFMAIN_ID                                               AS REFMAIN_ID,
    TO_CHAR(longtodate(S.CREATION_TIME), 'YYYY-MM-DD HH24:MI') AS "CREATIO_TIME",
    CAST ( S.CREATOR_CENTER AS VARCHAR(255))     AS CREATION_CENTER,
    CAST ( S.CREATOR_ID AS VARCHAR(255))         AS CREATION_ID,
    S.SAVED_FREE_DAYS                                          AS SAVED_FREE_DAYS,
    S.SAVED_FREE_MONTHS                                        AS SAVED_FREE_MONTHS,
    CAST ( S.INVOICELINE_CENTER AS VARCHAR(255)) AS INVOICELINE_CENTER,
    CAST ( S.INVOICELINE_ID AS VARCHAR(255))     AS INVOICELINE_ID,
    S.INVOICELINE_SUBID                          AS INVOICE_SUBID,
    CAST ( S.TRANSFERRED_CENTER AS VARCHAR(255)) AS TRANSFERRED_CENTER,
    CAST ( S.TRANSFERRED_ID AS VARCHAR(255))     AS TRANSFERRED_ID,
    S.SUB_COMMENT                                              AS SUB_COMMENT,
    CAST ( S.EXTENDED_TO_CENTER AS VARCHAR(255)) AS EXTENDED_TO_CENETER,
    CAST ( S.EXTENDED_TO_ID AS VARCHAR(255))     AS EXTENDED_TO_ID,
    S.RENEWAL_REMINDER_SENT                                    AS RENEWAL_REMINDER_SENT,
    S.RENEWAL_POLICY_OVERRIDE                                  AS RENEWAL_POLICY_OVERRIDE,
    S.ADMINFEE_INVOICELINE_SUBID                               AS ADMINFEE_INVOICELINE_SUBID,
    S.CAMPAIGN_CODE_ID                                         AS CAMPAIGN_CODE_ID,
    S.IS_PRICE_UPDATE_EXCLUDED                                 AS IS_PRICE_UPDATE_EXCLUDED,
    PR.NAME                                                    AS NAME,
    PR.GLOBALID                                                AS GLOBAL_ID
FROM
    SUBSCRIPTIONS S
LEFT JOIN
    PERSONS P
ON
    (
        P.CENTER = S.OWNER_CENTER
        AND P.ID = S.OWNER_ID)
LEFT JOIN
    PRODUCTS PR
ON
    (
        PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER
        AND PR.ID = S.SUBSCRIPTIONTYPE_ID)
LEFT JOIN
    PERSONS curpers
ON
    (
        curpers.CENTER = P.CURRENT_PERSON_CENTER
        AND curpers.ID = P.CURRENT_PERSON_ID)
WHERE
    P.CENTER IN (:Scope)
