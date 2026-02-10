-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cols."SOURCE_NAME",
    defs."DEST_NAME",
    defs."EXPORT_TYPE",
    defs."EXPORT_FREQUENCY",
    cols."COLUMN_NAME",
    cols."COLUMN_TYPE",
    CASE
        WHEN POSITION('['||cols."COLUMN_NAME"||']' IN defs."PRIMARY_KEYS") != 0
        THEN true
        ELSE false
    END AS "IS_PRIMARY",
    "ORDINAL_POSITION"
FROM
    (
        SELECT
            CAST('BI2_CLIPCARD' AS text) AS "SOURCE_NAME",
            'CLIPCARD'                   AS "DEST_NAME",
            'ENTITY'                     AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'REALTIME'                   AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ACCEPTED_MATERIAL' AS text) AS "SOURCE_NAME",
            'ACCEPTED_MATERIAL'                   AS "DEST_NAME",
            'ENTITIES'                            AS "EXPORT_TYPE",
            '[PERSON_ID],[TYPE]'                  AS "PRIMARY_KEYS",
            'HOURLY'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ACCESS_PRIVILEGE_USAGE' AS text) AS "SOURCE_NAME",
            'ACCESS_PRIVILEGE_USAGE'                   AS "DEST_NAME",
            'ENTITIES'                                 AS "EXPORT_TYPE",
            '[ID]'                                     AS "PRIMARY_KEYS",
            'REALTIME'                                 AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ACTIVITY' AS text) AS "SOURCE_NAME",
            'ACTIVITY'                   AS "DEST_NAME",
            'ENTITIES'                   AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'REALTIME'                   AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ACTIVITY_GROUP' AS text) AS "SOURCE_NAME",
            'ACTIVITY_GROUP'                   AS "DEST_NAME",
            'ENTITIES'                         AS "EXPORT_TYPE",
            '[ID]'                             AS "PRIMARY_KEYS",
            'REALTIME'                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_AGREEMENT_CASE' AS text) AS "SOURCE_NAME",
            'AGREEMENT_CASE'                   AS "DEST_NAME",
            'ENTITIES'                         AS "EXPORT_TYPE",
            '[ID]'                             AS "PRIMARY_KEYS",
            'REALTIME'                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ANSWER_SUBMISSION' AS text) AS "SOURCE_NAME",
            'ANSWER_SUBMISSION'                   AS "DEST_NAME",
            'EVENTS'                              AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'HOURLY'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_AREA_CENTER' AS text) AS "SOURCE_NAME",
            'AREA_CENTER'                   AS "DEST_NAME",
            'FULL'                          AS "EXPORT_TYPE",
            '[CENTER_ID],[AREA_ID]'         AS "PRIMARY_KEYS",
            'DAILY'                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_AREA' AS text) AS "SOURCE_NAME",
            'AREA'                   AS "DEST_NAME",
            'FULL'                   AS "EXPORT_TYPE",
            '[ID]'                   AS "PRIMARY_KEYS",
            'DAILY'                  AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ATTEND' AS text) AS "SOURCE_NAME",
            'ATTEND'                   AS "DEST_NAME",
            'EVENTS'                   AS "EXPORT_TYPE",
            '[ID]'                     AS "PRIMARY_KEYS",
            'REALTIME'                 AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_BOOKING_RESOURCE_USAGE' AS text)                             AS "SOURCE_NAME",
            'BOOKING_RESOURCE_USAGE'                                                 AS "DEST_NAME",
            'ENTITIES'                                                             AS "EXPORT_TYPE",
            '[RESOURCE_ID],[BOOKING_ID], [BOOKING_START_DATETIME], [BOOKING_STOP_DATETIME]' AS
                          "PRIMARY_KEYS",
            'REALTIME' AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_BOOKING' AS text) AS "SOURCE_NAME",
            'BOOKING'                   AS "DEST_NAME",
            'ENTITIES'                  AS "EXPORT_TYPE",
            '[ID]'                      AS "PRIMARY_KEYS",
            'REALTIME'                  AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CAMPAIGN' AS text) AS "SOURCE_NAME",
            'CAMPAIGN'                   AS "DEST_NAME",
            'FULL'                       AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'DAILY'                      AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CENTER_EXT_ATTR' AS text) AS "SOURCE_NAME",
            'CENTER_EXT_ATTR'                   AS "DEST_NAME",
            'ENTITY'                            AS "EXPORT_TYPE",
            '[ID]'                              AS "PRIMARY_KEYS",
            'DAILY'                             AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CENTER' AS text) AS "SOURCE_NAME",
            'CENTER'                   AS "DEST_NAME",
            'FULL'                     AS "EXPORT_TYPE",
            '[ID]'                     AS "PRIMARY_KEYS",
            'DAILY'                    AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CLIPCARD_USAGE' AS text) AS "SOURCE_NAME",
            'CLIPCARD_USAGE'                   AS "DEST_NAME",
            'ENTITY'                           AS "EXPORT_TYPE",
            '[ID]'                             AS "PRIMARY_KEYS",
            'REALTIME'                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_COMPANY' AS text) AS "SOURCE_NAME",
            'COMPANY'                   AS "DEST_NAME",
            'ENTITIES'                  AS "EXPORT_TYPE",
            '[ID]'                      AS "PRIMARY_KEYS",
            'REALTIME'                  AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_COMPANY_AGREEMENT' AS text) AS "SOURCE_NAME",
            'COMPANY_AGREEMENT'                   AS "DEST_NAME",
            'FULL'                                AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'DAILY'                               AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_COMPANY_EXT_ATTR' AS text) AS "SOURCE_NAME",
            'COMPANY_EXT_ATTR'                   AS "DEST_NAME",
            'ENTITIES'                           AS "EXPORT_TYPE",
            '[COMPANY_ID],[NAME]'                AS "PRIMARY_KEYS",
            'HOURLY'                             AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_COUNTRY' AS text) AS "SOURCE_NAME",
            'COUNTRY'                   AS "DEST_NAME",
            'FULL'                      AS "EXPORT_TYPE",
            '[ID]'                      AS "PRIMARY_KEYS",
            'DAILY'                     AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CRM_ACTION' AS text) AS "SOURCE_NAME",
            'CRM_ACTION'                   AS "DEST_NAME",
            'EVENTS'                       AS "EXPORT_TYPE",
            '[ID]'                         AS "PRIMARY_KEYS",
            'HOURLY'                       AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CRM_TASK' AS text) AS "SOURCE_NAME",
            'CRM_TASK'                   AS "DEST_NAME",
            'ENTITIES'                   AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'HOURLY'                     AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_DAILY_MEMBER_STATE' AS text) AS "SOURCE_NAME",
            'DAILY_MEMBER_STATE'                   AS "DEST_NAME",
            'EVENTS'                               AS "EXPORT_TYPE",
            '[ID]'                                 AS "PRIMARY_KEYS",
            'HOURLY'                               AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_DEBT_CASE' AS text) AS "SOURCE_NAME",
            'DEBT_CASE'                   AS "DEST_NAME",
            'ENTITIES'                    AS "EXPORT_TYPE",
            '[ID]'                        AS "PRIMARY_KEYS",
            'HOURLY'                      AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_FREEZE_PERIOD' AS text) AS "SOURCE_NAME",
            'FREEZE_PERIOD'                   AS "DEST_NAME",
            'ENTITIES'                        AS "EXPORT_TYPE",
            '[ID]'                            AS "PRIMARY_KEYS",
            'HOURLY'                          AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_HOME_CENTER_LOG' AS text) AS "SOURCE_NAME",
            'HOME_CENTER_LOG'                   AS "DEST_NAME",
            'EVENTS'                            AS "EXPORT_TYPE",
            '[ID]'                              AS "PRIMARY_KEYS",
            'HOURLY'                            AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_INVENTORY_TRANSACTION_LOG' AS text) AS "SOURCE_NAME",
            'INVENTORY_TRANSACTION_LOG'                   AS "DEST_NAME",
            'EVENTS'                                      AS "EXPORT_TYPE",
            '[ID]'                                        AS "PRIMARY_KEYS",
            'HOURLY'                                      AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_KPI_LOG' AS text)             AS "SOURCE_NAME",
            'KPI_LOG'                               AS "DEST_NAME",
            'EVENTS'                                AS "EXPORT_TYPE",
            '[EXTERNAL_ID],[CENTER_ID], [FOR_DATE]' AS "PRIMARY_KEYS",
            'REALTIME'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_MASTER_PRODUCT' AS text) AS "SOURCE_NAME",
            'MASTER_PRODUCT'                   AS "DEST_NAME",
            'FULL'                             AS "EXPORT_TYPE",
            '[ID]'                             AS "PRIMARY_KEYS",
            'DAILY'                            AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_MEMBER_STATE_LOG' AS text) AS "SOURCE_NAME",
            'MEMBER_STATE_LOG'                   AS "DEST_NAME",
            'EVENTS'                             AS "EXPORT_TYPE",
            '[ID]'                               AS "PRIMARY_KEYS",
            'HOURLY'                             AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PARTICIPATION' AS text) AS "SOURCE_NAME",
            'PARTICIPATION'                   AS "DEST_NAME",
            'ENTITIES'                        AS "EXPORT_TYPE",
            '[ID]'                            AS "PRIMARY_KEYS",
            'REALTIME'                        AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PERSON_ATTRIBUTE_LOG' AS text) AS "SOURCE_NAME",
            'PERSON_ATTRIBUTE_LOG'                   AS "DEST_NAME",
            'EVENTS'                                 AS "EXPORT_TYPE",
            '[ID]'                                   AS "PRIMARY_KEYS",
            'HOURLY'                                 AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PERSON_EXT_ATTR' AS text) AS "SOURCE_NAME",
            'PERSON_EXT_ATTR'                   AS "DEST_NAME",
            'ENTITIES'                          AS "EXPORT_TYPE",
            '[PERSON_ID],[NAME]'                AS "PRIMARY_KEYS",
            'HOURLY'                            AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PERSON_STATUS_LOG' AS text) AS "SOURCE_NAME",
            'PERSON_STATUS_LOG'                   AS "DEST_NAME",
            'EVENTS'                              AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'HOURLY'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PERSON_TYPE_LOG' AS text) AS "SOURCE_NAME",
            'PERSON_TYPE_LOG'                   AS "DEST_NAME",
            'EVENTS'                            AS "EXPORT_TYPE",
            '[ID]'                              AS "PRIMARY_KEYS",
            'HOURLY'                            AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PERSON' AS text) AS "SOURCE_NAME",
            'PERSON'                   AS "DEST_NAME",
            'ENTITIES'                 AS "EXPORT_TYPE",
            '[ID]'                     AS "PRIMARY_KEYS",
            'REALTIME'                 AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PERSON_STAFF_GROUP' AS text)     AS "SOURCE_NAME",
            'PERSON_STAFF_GROUP'                       AS "DEST_NAME",
            'FULL'                                     AS "EXPORT_TYPE",
            '[PERSON_ID],[STAFF_GROUP_ID],[CENTER_ID]' AS "PRIMARY_KEYS",
            'DAILY'                                    AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PRODUCT_GROUP' AS text) AS "SOURCE_NAME",
            'PRODUCT_GROUP'                   AS "DEST_NAME",
            'FULL'                            AS "EXPORT_TYPE",
            '[ID]'                            AS "PRIMARY_KEYS",
            'DAILY'                           AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PRODUCT_PRIVILEGE_USAGE' AS text) AS "SOURCE_NAME",
            'PRODUCT_PRIVILEGE_USAGE'                   AS "DEST_NAME",
            'ENTITIES'                                  AS "EXPORT_TYPE",
            '[ID]'                                      AS "PRIMARY_KEYS",
            'REALTIME'                                  AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PRODUCT_PRODUCT_GROUP' AS text) AS "SOURCE_NAME",
            'PRODUCT_PRODUCT_GROUP'                   AS "DEST_NAME",
            'FULL'                                    AS "EXPORT_TYPE",
            '[PRODUCT_ID],[PRODUCT_GROUP_ID]'         AS "PRIMARY_KEYS",
            'DAILY'                                   AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PRODUCT' AS text) AS "SOURCE_NAME",
            'PRODUCT'                   AS "DEST_NAME",
            'ENTITIES'                  AS "EXPORT_TYPE",
            '[ID]'                      AS "PRIMARY_KEYS",
            'HOURLY'                    AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_QUESTIONNAIRE' AS text) AS "SOURCE_NAME",
            'QUESTIONNAIRE'                   AS "DEST_NAME",
            'FULL'                            AS "EXPORT_TYPE",
            '[]'                              AS "PRIMARY_KEYS",
            'DAILY'                           AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_RESOURCE' AS text) AS "SOURCE_NAME",
            'RESOURCE'                   AS "DEST_NAME",
            'ENTITIES'                   AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'REALTIME'                   AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SALE_LOG' AS text) AS "SOURCE_NAME",
            'SALE_LOG'                   AS "DEST_NAME",
            'EVENTS'                     AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'REALTIME'                   AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_STAFF_GROUP' AS text) AS "SOURCE_NAME",
            'STAFF_GROUP'                   AS "DEST_NAME",
            'FULL'                          AS "EXPORT_TYPE",
            '[ID]'                          AS "PRIMARY_KEYS",
            'DAILY'                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_STAFF_USAGE' AS text) AS "SOURCE_NAME",
            'STAFF_USAGE'                   AS "DEST_NAME",
            'ENTITIES'                      AS "EXPORT_TYPE",
            '[ID]'                          AS "PRIMARY_KEYS",
            'REALTIME'                      AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SUBSCRIPTION_ADDON' AS text) AS "SOURCE_NAME",
            'SUBSCRIPTION_ADDON'                   AS "DEST_NAME",
            'ENTITIES'                             AS "EXPORT_TYPE",
            '[ID]'                                 AS "PRIMARY_KEYS",
            'HOURLY'                               AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SUBSCRIPTION_PERIOD' AS text) AS "SOURCE_NAME",
            'SUBSCRIPTION_PERIOD'                   AS "DEST_NAME",
            'ENTITIES'                              AS "EXPORT_TYPE",
            '[ID],[SALE_LOG_ID]'                    AS "PRIMARY_KEYS",
            'HOURLY'                                AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SUBSCRIPTION_SALE' AS text) AS "SOURCE_NAME",
            'SUBSCRIPTION_SALE'                   AS "DEST_NAME",
            'ENTITIES'                            AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'REALTIME'                            AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SUBSCRIPTION_STATE_LOG' AS text) AS "SOURCE_NAME",
            'SUBSCRIPTION_STATE_LOG'                   AS "DEST_NAME",
            'ENTITIES'                                 AS "EXPORT_TYPE",
            '[ID]'                                     AS "PRIMARY_KEYS",
            'REALTIME'                                 AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SUBSCRIPTION' AS text) AS "SOURCE_NAME",
            'SUBSCRIPTION'                   AS "DEST_NAME",
            'ENTITIES'                       AS "EXPORT_TYPE",
            '[ID]'                           AS "PRIMARY_KEYS",
            'REALTIME'                       AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_VISIT_LOG' AS text) AS "SOURCE_NAME",
            'VISIT_LOG'                   AS "DEST_NAME",
            'EVENTS'                      AS "EXPORT_TYPE",
            '[ID]'                        AS "PRIMARY_KEYS",
            'REALTIME'                    AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_VISIT' AS text) AS "SOURCE_NAME",
            'VISIT'                   AS "DEST_NAME",
            'ENTITIES'                AS "EXPORT_TYPE",
            '[ID]'                    AS "PRIMARY_KEYS",
            'REALTIME'                AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SUBSCRIPTION_PRICE' AS text) AS "SOURCE_NAME",
            'SUBSCRIPTION_PRICE'                   AS "DEST_NAME",
            'ENTITIES'                             AS "EXPORT_TYPE",
            '[ID]'                                 AS "PRIMARY_KEYS",
            'HOURLY'                               AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_DW_CONSTRAINT_TEST' AS text) AS "SOURCE_NAME",
            'DW_CONSTRAINT_TEST'                   AS "DEST_NAME",
            'FULL'                                 AS "EXPORT_TYPE",
            '[]'                                   AS "PRIMARY_KEYS",
            'DAILY'                                AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_DOCUMENT' AS text) AS "SOURCE_NAME",
            'DOCUMENT'                   AS "DEST_NAME",
            'ENTITIES'                   AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'HOURLY'                     AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SALE_EMPLOYEE_LOG' AS text) AS "SOURCE_NAME",
            'SALE_EMPLOYEE_LOG'                   AS "DEST_NAME",
            'EVENTS'                              AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'REALTIME'                            AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_MESSAGE' AS text) AS "SOURCE_NAME",
            'MESSAGE'                   AS "DEST_NAME",
            'ENTITIES'                  AS "EXPORT_TYPE",
            '[ID]'                      AS "PRIMARY_KEYS",
            'HOURLY'                    AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_RESOURCE_AVAILABILITY' AS text)                       AS "SOURCE_NAME",
            'RESOURCE_AVAILABILITY'                                         AS "DEST_NAME",
            'ENTITIES'                                                      AS "EXPORT_TYPE",
            '[RESOURCE_ID],[RESOURCE_GROUP_ID],[AVAILABILITY_TYPE],[VALUE]' AS "PRIMARY_KEYS",
            'REALTIME'                                                      AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_BOOKING_RECURRENCE' AS text) AS "SOURCE_NAME",
            'BOOKING_RECURRENCE'                   AS "DEST_NAME",
            'FULL'                                 AS "EXPORT_TYPE",
            '[]'                                   AS "PRIMARY_KEYS",
            'DAILY'                                AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PERSON_DETAIL' AS text) AS "SOURCE_NAME",
            'PERSON_DETAIL'                   AS "DEST_NAME",
            'ENTITIES'                        AS "EXPORT_TYPE",
            '[PERSON_ID]'                     AS "PRIMARY_KEYS",
            'REALTIME'                        AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_RESOURCE_GROUP' AS text) AS "SOURCE_NAME",
            'RESOURCE_GROUP'                   AS "DEST_NAME",
            'ENTITIES'                         AS "EXPORT_TYPE",
            '[ID]'                             AS "PRIMARY_KEYS",
            'REALTIME'                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_RESOURCE_RESOURCE_GROUP' AS text) AS "SOURCE_NAME",
            'RESOURCE_RESOURCE_GROUP'                   AS "DEST_NAME",
            'ENTITIES'                                  AS "EXPORT_TYPE",
            '[RESOURCE_ID],[RESOURCE_GROUP_ID]'         AS "PRIMARY_KEYS",
            'REALTIME'                                  AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ACCESS_PRIVILEGE' AS text) AS "SOURCE_NAME",
            'ACCESS_PRIVILEGE'                   AS "DEST_NAME",
            'FULL'                               AS "EXPORT_TYPE",
            '[ID]'                               AS "PRIMARY_KEYS",
            'DAILY'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PRIVILEGE_SET' AS text) AS "SOURCE_NAME",
            'PRIVILEGE_SET'                   AS "DEST_NAME",
            'FULL'                            AS "EXPORT_TYPE",
            '[ID]'                            AS "PRIMARY_KEYS",
            'DAILY'                           AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PRIVILEGE_GRANT' AS text) AS "SOURCE_NAME",
            'PRIVILEGE_GRANT'                   AS "DEST_NAME",
            'FULL'                              AS "EXPORT_TYPE",
            '[ID]'                              AS "PRIMARY_KEYS",
            'DAILY'                             AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ENTITY_IDENTIFIER' AS text) AS "SOURCE_NAME",
            'ENTITY_IDENTIFIER'                   AS "DEST_NAME",
            'ENTITIES'                            AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'HOURLY'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_RELATION_STATE_LOG' AS text) AS "SOURCE_NAME",
            'RELATION_STATE_LOG'                   AS "DEST_NAME",
            'ENTITIES'                             AS "EXPORT_TYPE",
            '[ID]'                                 AS "PRIMARY_KEYS",
            'HOURLY'                               AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_ACTIVITY_OVERRIDE' AS text) AS "SOURCE_NAME",
            'ACTIVITY_OVERRIDE'                   AS "DEST_NAME",
            'FULL'                                AS "EXPORT_TYPE",
            '[ID],[CENTER_ID]'                    AS "PRIMARY_KEYS",
            'HOURLY'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_TIME_CONFIGURATION' AS text) AS "SOURCE_NAME",
            'TIME_CONFIGURATION'                   AS "DEST_NAME",
            'FULL'                                 AS "EXPORT_TYPE",
            '[ID]'                                 AS "PRIMARY_KEYS",
            'HOURLY'                               AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_AGE_GROUP' AS text) AS "SOURCE_NAME",
            'AGE_GROUP'                   AS "DEST_NAME",
            'FULL'                        AS "EXPORT_TYPE",
            '[ID]'                        AS "PRIMARY_KEYS",
            'DAILY'                       AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_EMPLOYEE' AS text) AS "SOURCE_NAME",
            'EMPLOYEE'                   AS "DEST_NAME",
            'FULL'                       AS "EXPORT_TYPE",
            '[ID]'                       AS "PRIMARY_KEYS",
            'DAILY'                      AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PRODUCT_PRIVILEGE' AS text) AS "SOURCE_NAME",
            'PRODUCT_PRIVILEGE'                   AS "DEST_NAME",
            'FULL'                                AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'HOURLY'                              AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_AR_TRANSACTION' AS text) AS "SOURCE_NAME",
            'AR_TRANSACTION'                   AS "DEST_NAME",
            'ENTITIES'                         AS "EXPORT_TYPE",
            '[ID]'                             AS "PRIMARY_KEYS",
            'REALTIME'                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CAMPAIGN_AVAILABILITY_SCOPE' AS text) AS "SOURCE_NAME",
            'CAMPAIGN_AVAILABILITY_SCOPE'                   AS "DEST_NAME",
            'FULL'                                          AS "EXPORT_TYPE",
            '[CAMPAIGN_ID],[SCOPE_TYPE],[SCOPE_ID]'         AS "PRIMARY_KEYS",
            'DAILY'                                         AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_SUBSCRIPTION_CHANGE_LOG' AS text) AS "SOURCE_NAME",
            'SUBSCRIPTION_CHANGE_LOG'                   AS "DEST_NAME",
            'EVENTS'                                    AS "EXPORT_TYPE",
            '[ID]'                                      AS "PRIMARY_KEYS",
            'REALTIME'                                  AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_PAYMENT_AGREEMENT' AS text) AS "SOURCE_NAME",
            'PAYMENT_AGREEMENT'                   AS "DEST_NAME",
            'EVENTS'                              AS "EXPORT_TYPE",
            '[ID]'                                AS "PRIMARY_KEYS",
            'REALTIME'                            AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_CAMPAIGN_AVAILABILITY' AS text) AS "SOURCE_NAME",
            'CAMPAIGN_AVAILABILITY'                   AS "DEST_NAME",
            'FULL'                                    AS "EXPORT_TYPE",
            '[CAMPAIGN_ID],[SCOPE_TYPE],[SCOPE_ID]'   AS "PRIMARY_KEYS",
            'DAILY'                                   AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_BUNDLE_CAMPAIGN_PRODUCT' AS text) AS "SOURCE_NAME",
            'BUNDLE_CAMPAIGN_PRODUCT'                   AS "DEST_NAME",
            'FULL'                                      AS "EXPORT_TYPE",
            '[ID]'                                      AS "PRIMARY_KEYS",
            'DAILY'                                     AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_BOOKING_PROGRAM' AS text) AS "SOURCE_NAME",
            'BOOKING_PROGRAM'                   AS "DEST_NAME",
            'FULL'                              AS "EXPORT_TYPE",
            '[ID]'                              AS "PRIMARY_KEYS",
            'DAILY'                             AS "EXPORT_FREQUENCY"
        UNION ALL
        SELECT
            CAST('BI2_BOOKING_PROGRAM_TYPE_OVERRIDE' AS text) AS "SOURCE_NAME",
            'BOOKING_PROGRAM_TYPE_OVERRIDE'                   AS "DEST_NAME",
            'FULL'                                            AS "EXPORT_TYPE",
            '[ID],[CENTER_ID]'                                AS "PRIMARY_KEYS",
            'DAILY'                                           AS "EXPORT_FREQUENCY" 
		UNION ALL
        SELECT
            CAST('BI2_FREE_PERIOD' AS text) 				  AS "SOURCE_NAME",
            'FREE_PERIOD'              					      AS "DEST_NAME",
            'ENTITIES'                                        AS "EXPORT_TYPE",
            '[ID]' 				                              AS "PRIMARY_KEYS",
            'HOURLY'                                          AS "EXPORT_FREQUENCY"
		
		) defs
JOIN
    (
        SELECT
            UPPER(columns.table_name)  AS "SOURCE_NAME",
            UPPER(columns.column_name) AS "COLUMN_NAME",
            CASE
                WHEN columns.data_type = 'numeric'
                AND columns.column_name NOT IN ('LATITUDE',
                                                'LONGITUDE')
                THEN 'DECIMAL(16,2)'
                WHEN columns.data_type = 'numeric'
                AND columns.column_name IN ('LATITUDE',
                                            'LONGITUDE')
                THEN 'DECIMAL(16,6)'
                WHEN columns.udt_name = 'int4'
                THEN 'INTEGER'
                WHEN columns.udt_name = 'int8'
                AND columns.column_name = 'ETS'
                THEN 'BIGINT'
                WHEN columns.udt_name = 'int8'
                AND columns.column_name != 'ETS'
                THEN 'TIMESTAMP'
                WHEN columns.data_type IN ('text',
                                           'character varying',
                                           'xml')
                THEN 'VARCHAR'
                WHEN columns.data_type = 'date'
                THEN 'DATE'
                WHEN columns.data_type IN ('boolean',
                                           'smallint')
                THEN 'BOOLEAN'
                ELSE columns.udt_name
            END||
            CASE
                WHEN columns.data_type IN ('text',
                                           'character varying',
                                           'xml')
                THEN
                    CASE
                        WHEN columns.character_octet_length <= 50
                        THEN '(50)'
                        WHEN columns.character_octet_length > 50
                            AND columns.character_octet_length <= 80
                        THEN '(80)'
                        WHEN columns.character_octet_length >80
                            AND columns.character_octet_length <= 200
                        THEN '(200)'
                        WHEN columns.character_octet_length >200
                            AND columns.character_octet_length<= 1020
                        THEN '(1020)'
                        ELSE '(MAX)'
                    END
                ELSE ''
            END                      AS "COLUMN_TYPE",
            columns.ordinal_position AS "ORDINAL_POSITION"
        FROM
            information_schema.columns
        WHERE
            UPPER(columns.table_name) LIKE 'BI2_%'
        AND columns.table_schema = current_schema()) cols
ON
    defs."SOURCE_NAME" = cols."SOURCE_NAME"