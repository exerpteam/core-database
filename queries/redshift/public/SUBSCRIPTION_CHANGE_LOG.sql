SELECT
    "ID",
    "SUBSCRIPTION_ID",
    "TYPE",
    "FROM_DATETIME",
    "VALUE",
    "EFFECT_DATE",
    "CANCEL_DATETIME",
    "CENTER_ID",
    "ETS"
FROM
    (
        SELECT
            s.center||'ss'||s.id||'sc'||0 AS "ID",
            s.center||'ss'||s.id          AS "SUBSCRIPTION_ID",
            CAST('ASSIGNED_EMPLOYEE'      AS VARCHAR(255))  AS "TYPE",
            s.creation_time               AS "FROM_DATETIME",
            CASE
                WHEN sc.id IS NULL
                THEN
                    CASE
                        WHEN (p1.CENTER != p1.TRANSFERS_CURRENT_PRS_CENTER
                                OR p1.id != p1.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = p1.TRANSFERS_CURRENT_PRS_CENTER
                                    AND ID = p1.TRANSFERS_CURRENT_PRS_ID)
                        ELSE p1.EXTERNAL_ID
                    END
                ELSE
                    CASE
                        WHEN (p2.CENTER != p2.TRANSFERS_CURRENT_PRS_CENTER
                                OR p2.id != p2.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = p2.TRANSFERS_CURRENT_PRS_CENTER
                                    AND ID = p2.TRANSFERS_CURRENT_PRS_ID)
                        ELSE p2.EXTERNAL_ID
                    END
            END                                                                   AS "VALUE",
            sc.effect_date                                                        AS "EFFECT_DATE",
            sc.cancel_time       											      AS "CANCEL_DATETIME",
            s.center                                                              AS "CENTER_ID",
            s.creation_time                                                       AS "ETS",
            rank() over (partition BY s.center, s.id ORDER BY sc.change_time ASC) AS rnk
        FROM
            subscriptions s
        LEFT JOIN
            subscription_change sc
        ON
            sc.type = 'ASSIGNED_EMPLOYEE'
            AND sc.old_subscription_center = s.center
            AND sc.old_subscription_id = s.id
        LEFT JOIN
            persons p1
        ON
            p1.center = s.assigned_staff_center
            AND p1.id = s.assigned_staff_id
        LEFT JOIN
            persons p2
        ON
            p2.center = sc.prev_change_center
            AND p2.id = sc.prev_change_id ) first_entries
WHERE
    rnk = 1
	AND "ETS" BETWEEN @param_from_ets AND @param_to_ets

UNION ALL

SELECT
    sc.old_subscription_center||'ss'||sc.old_subscription_id||'sc'||sc.ID AS "ID",
    sc.old_subscription_center||'ss'||sc.old_subscription_id              AS "SUBSCRIPTION_ID",
    sc.type                                                               AS "TYPE" ,
    sc.change_time                                                        AS "ENTRY_DATETIME",
    CASE WHEN sc.TYPE = 'ASSIGNED_EMPLOYEE' THEN
		CASE
			WHEN (p2.CENTER != p2.TRANSFERS_CURRENT_PRS_CENTER
					OR p2.id != p2.TRANSFERS_CURRENT_PRS_ID )
			THEN
				(
					SELECT
						EXTERNAL_ID
					FROM
						PERSONS
					WHERE
						CENTER = p2.TRANSFERS_CURRENT_PRS_CENTER
						AND ID = p2.TRANSFERS_CURRENT_PRS_ID)
			ELSE p2.EXTERNAL_ID
		END
    END                         AS "VALUE",
    sc.effect_date              AS "EFFECT_DATE",
    sc.cancel_time              AS "CANCEL_DATETIME",
    sc.old_subscription_center  AS "CENTER_ID",
    sc.change_time              AS "ETS"
FROM
    subscription_change sc
LEFT JOIN
    persons p2
ON
    p2.center = sc.new_change_center
    AND p2.id = sc.new_change_id
WHERE
    sc.TYPE in ('ASSIGNED_EMPLOYEE','END_DATE')