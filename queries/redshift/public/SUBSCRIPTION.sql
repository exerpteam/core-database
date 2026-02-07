WITH
    PARAMS AS
    (
        SELECT
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                    OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            persons
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END AS                                               "PERSON_ID",
            s.CENTER || 'ss' || s.ID                             "ID",
            s.CENTER                                             "CENTER_ID",
			CASE 
				WHEN s.STATE = 2 THEN 'ACTIVE'
				WHEN s.STATE = 3 THEN 'ENDED'
				WHEN s.STATE = 4 THEN 'FROZEN'
				WHEN s.STATE = 7 THEN 'WINDOW'
				WHEN s.STATE = 8 THEN 'CREATED'
				ELSE 'UNKNOWN'
			END AS "STATE",
			CASE 
				WHEN s.SUB_STATE = 1 THEN 'NONE'
				WHEN s.SUB_STATE = 2 THEN 'AWAITING_ACTIVATION'
				WHEN s.SUB_STATE = 3 THEN 'UPGRADED'
				WHEN s.SUB_STATE = 4 THEN 'DOWNGRADED'
				WHEN s.SUB_STATE = 5 THEN 'EXTENDED'
				WHEN s.SUB_STATE = 6 THEN 'TRANSFERRED'
				WHEN s.SUB_STATE = 7 THEN 'REGRETTED'
				WHEN s.SUB_STATE = 8 THEN 'CANCELLED'
				WHEN s.SUB_STATE = 9 THEN 'BLOCKED'
				WHEN s.SUB_STATE = 10 THEN 'CHANGED'
				 ELSE 'UNKNOWN'
			END AS "SUB_STATE",
			CASE 
				WHEN st.ST_TYPE = 0 THEN 'PREPAID'
				WHEN st.ST_TYPE = 1 THEN 'RECURRING'
				WHEN st.ST_TYPE = 2 THEN 'CLIPCARD'
				WHEN st.ST_TYPE = 3 THEN 'COURSE'
				ELSE 'UNKNOWN'
			END AS "RENEWAL_TYPE",
            s.SUBSCRIPTIONTYPE_CENTER || 'prod' || s.SUBSCRIPTIONTYPE_ID "PRODUCT_ID",
            s.START_DATE                                                 "START_DATE",
            --    scStop.STOP_DATETIME AS                                      "STOP_DATETIME",
            s.END_DATE          "END_DATE",
            s.BILLED_UNTIL_DATE "BILLED_UNTIL_DATE",
            s.BINDING_END_DATE  "BINDING_END_DATE",
            s.CREATION_TIME     "CREATION_DATETIME",
            CASE
                WHEN s.INVOICELINE_CENTER IS NOT NULL
                THEN s.INVOICELINE_CENTER||'inv'||s.INVOICELINE_ID
                ELSE NULL
            END AS "SALE_ID",
            CASE
                WHEN s.INVOICELINE_CENTER IS NOT NULL
                THEN s.INVOICELINE_CENTER||'inv'||s.INVOICELINE_ID||'ln'||s.INVOICELINE_SUBID
                ELSE NULL
            END                                                AS "JF_SALE_LOG_ID",
            s.SUBSCRIPTION_PRICE                                     AS "PRICE",
            s.BINDING_PRICE                                          AS "BINDING_PRICE",
            CAST(CAST (st.IS_ADDON_SUBSCRIPTION AS INT) AS SMALLINT)    AS "REQUIRES_MAIN",
            CAST(CAST (s.IS_PRICE_UPDATE_EXCLUDED AS INT) AS SMALLINT)  AS "PRICE_UPDATE_EXCLUDED",
            CAST(CAST (st.IS_PRICE_UPDATE_EXCLUDED AS INT) AS SMALLINT) AS
            "TYPE_PRICE_UPDATE_EXCLUDED",
            CASE
                WHEN FREEZEPERIODPRODUCT_CENTER IS NOT NULL
                THEN st.FREEZEPERIODPRODUCT_CENTER || 'prod' || st.FREEZEPERIODPRODUCT_ID
                ELSE NULL
            END "FREEZE_PERIOD_PRODUCT_ID",
            CASE
                WHEN s.TRANSFERRED_CENTER IS NOT NULL
                THEN s.TRANSFERRED_CENTER || 'ss' || s.TRANSFERRED_ID
                ELSE NULL
            END "TRANSFER_SUBSCRIPTION_ID",
            CASE
                WHEN s.EXTENDED_TO_CENTER IS NOT NULL
                THEN s.EXTENDED_TO_CENTER || 'ss' || s.EXTENDED_TO_ID
                ELSE NULL
            END "EXTENSION_SUBSCRIPTION_ID",
            CASE
                WHEN st.PERIODUNIT = 0
                THEN 'WEEK'
                WHEN st.PERIODUNIT =1
                THEN 'DAY'
                WHEN st.PERIODUNIT = 2
                THEN 'MONTH'
                WHEN st.PERIODUNIT = 3
                THEN 'YEAR'
                WHEN st.PERIODUNIT =4
                THEN 'HOUR'
                WHEN st.PERIODUNIT = 5
                THEN 'MINUTE'
                WHEN st.PERIODUNIT = 6
                THEN 'SECOND'
                ELSE 'UNKNOWN'
            END            AS "PERIOD_UNIT",
            st.PERIODCOUNT AS "PERIOD_COUNT",
            CASE
                WHEN s.REASSIGNED_CENTER IS NOT NULL
                THEN s.REASSIGNED_CENTER || 'ss' || s.REASSIGNED_ID
                ELSE NULL
            END "REASSIGN_SUBSCRIPTION_ID",
            --    scStop.STOP_PERSON_ID       AS "STOP_PERSON_ID",
            --    scStop.STOP_CANCEL_DATETIME AS "STOP_CANCEL_DATETIME",
            CASE
                WHEN s.payment_agreement_center IS NOT NULL
                THEN s.payment_agreement_center||'ar'||s.payment_agreement_id||'agr'||
                    s.payment_agreement_subid
                ELSE ''
            END             "PAYMENT_AGREEMENT_ID",
            CASE
                WHEN s.changed_to_center IS NOT NULL
                THEN s.changed_to_center||'ss'||s.changed_to_id
                ELSE NULL
            END "CHANGE_SUBSCRIPTION_ID",
            s.LAST_MODIFIED "ETS",
			s.center AS "RAW_CENTER",
			s.id	 AS "RAW_ID",
            s.is_change_restricted AS "IS_CHANGE_RESTRICTED"
        FROM
            SUBSCRIPTIONS s
        JOIN
            persons p
        ON
            p.center = s.OWNER_CENTER
        AND p.ID = s.OWNER_ID
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND st.ID = s.SUBSCRIPTIONTYPE_ID
    )
    ,
    scStop AS
    (
    (
        SELECT
            "OLD_SUBSCRIPTION_CENTER",
            "OLD_SUBSCRIPTION_ID",
            "STOP_DATETIME",
            "STOP_CANCEL_DATETIME",
            "STOP_PERSON_ID"
        FROM
            (
                SELECT
                    scStop.OLD_SUBSCRIPTION_CENTER AS "OLD_SUBSCRIPTION_CENTER",
                    scStop.OLD_SUBSCRIPTION_ID     AS "OLD_SUBSCRIPTION_ID",
                    scStop.CHANGE_TIME             AS "STOP_DATETIME",
                    scStop.CANCEL_TIME             AS "STOP_CANCEL_DATETIME",
                    scStopstaff.CENTER,
                    CASE
                        WHEN (scStopstaff.CENTER != scStopstaff.TRANSFERS_CURRENT_PRS_CENTER
                            OR  scStopstaff.id != scStopstaff.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    persons
                                WHERE
                                    CENTER = scStopstaff.TRANSFERS_CURRENT_PRS_CENTER
                                AND ID = scStopstaff.TRANSFERS_CURRENT_PRS_ID)
                        ELSE scStopstaff.EXTERNAL_ID
                    END AS "STOP_PERSON_ID",
                    row_number() over (partition BY scStop.OLD_SUBSCRIPTION_CENTER,
                    scStop.OLD_SUBSCRIPTION_ID ORDER BY scStop.CHANGE_TIME DESC) AS rnk
                FROM
                    params par
                JOIN
                    SUBSCRIPTION_CHANGE scStop  -- The newly introduced join to fetch lesser rows
                ON
                    par."RAW_CENTER" = scStop.old_subscription_center
					AND par."RAW_ID" = scStop.old_subscription_id
                LEFT JOIN
                    employees escStopEmp
                ON
                    escStopEmp.center = scStop.EMPLOYEE_CENTER
                AND escStopEmp.id = scStop.EMPLOYEE_ID
                LEFT JOIN
                    persons scStopstaff
                ON
                    escStopEmp.PERSONCENTER = scStopstaff.center
                AND escStopEmp.PERSONID =scStopstaff.id
                WHERE
                    scStop.TYPE = 'END_DATE' ) x
        WHERE
            rnk = 1
    )
    )


SELECT
    par."PERSON_ID",
    par."ID",
    par."CENTER_ID",
    par."STATE",
    par."SUB_STATE",
    par."RENEWAL_TYPE",
    par."PRODUCT_ID",
    par."START_DATE",
    scStop."STOP_DATETIME",
    par."END_DATE",
    par."BILLED_UNTIL_DATE",
    par."BINDING_END_DATE",
    par."CREATION_DATETIME",
	par."SALE_ID",
    par."JF_SALE_LOG_ID",
    par."PRICE",
    par."BINDING_PRICE",
    par."REQUIRES_MAIN",
    par."PRICE_UPDATE_EXCLUDED",
    par."TYPE_PRICE_UPDATE_EXCLUDED",
    par."FREEZE_PERIOD_PRODUCT_ID",
    par."TRANSFER_SUBSCRIPTION_ID",
    par."EXTENSION_SUBSCRIPTION_ID",
    par."PERIOD_UNIT",
    par."PERIOD_COUNT",
    par."REASSIGN_SUBSCRIPTION_ID",
    scStop."STOP_PERSON_ID",
    scStop."STOP_CANCEL_DATETIME",
    par."PAYMENT_AGREEMENT_ID",
    par."CHANGE_SUBSCRIPTION_ID",
    par."IS_CHANGE_RESTRICTED",
    par."ETS"
FROM
    params par
LEFT JOIN
    scStop
ON
    par."RAW_CENTER" = scStop."OLD_SUBSCRIPTION_CENTER"
	AND par."RAW_ID" = scStop."OLD_SUBSCRIPTION_ID"