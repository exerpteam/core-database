SELECT
    a.ID                                                        AS "ID",
    a.NAME                                                      AS "NAME",
    a.STATE                                                     AS "STATE",
	CASE 
		WHEN a.ACTIVITY_TYPE = 1 THEN 'GENERAL'
		WHEN a.ACTIVITY_TYPE = 2 THEN 'CLASS_BOOKING'
		WHEN a.ACTIVITY_TYPE = 3 THEN 'RESOURCE_BOOKING'
		WHEN a.ACTIVITY_TYPE = 4 THEN 'STAFF_BOOKING'
		WHEN a.ACTIVITY_TYPE = 5 THEN 'MEETING'
		WHEN a.ACTIVITY_TYPE = 6 THEN 'STAFF_AVAILABILITY'
		WHEN a.ACTIVITY_TYPE = 7 THEN 'RESOURCE_AVAILABILITY'
		WHEN a.ACTIVITY_TYPE = 8 THEN 'CHILD_CARE'
		WHEN a.ACTIVITY_TYPE = 9 THEN 'COURSES'
		WHEN a.ACTIVITY_TYPE = 10 THEN 'TASK'
		WHEN a.ACTIVITY_TYPE = 11 THEN 'CAMP'
		WHEN a.ACTIVITY_TYPE = 12 THEN 'CAMP_ELECTIVE'
		ELSE 'UNKNOWN'
	END AS "TYPE",
    a.ACTIVITY_GROUP_ID                                         AS "ACTIVITY_GROUP_ID",
    cg.NAME                                                     AS "COLOR",
    CASE
        WHEN COALESCE(a.MAX_PARTICIPANTS,0) <= 0
        THEN 0
        ELSE a.MAX_PARTICIPANTS
    END AS "MAX_PARTICIPANTS",
    CASE
        WHEN COALESCE(a.MAX_WAITING_LIST_PARTICIPANTS,0) <= 0
        THEN 0
        ELSE a.MAX_WAITING_LIST_PARTICIPANTS
    END                AS "MAX_WAITING_LIST_PARTICIPANTS",
    a.EXTERNAL_ID      AS "EXTERNAL_ID",
    pc.ACCESS_GROUP_ID AS "ACCESS_GROUP_ID",
    LEFT(a.DESCRIPTION, 2048)    AS "DESCRIPTION",
    a.time_config_id   AS "TIME_CONFIGURATION_ID",
    CASE
        WHEN a.course_schedule_type = 0
        THEN 'FIXED'
        WHEN a.course_schedule_type = 1
        THEN 'CONTINUOUS'
        ELSE ''
    END AS "COURSE_SCHEDULE_TYPE",
    CASE
        WHEN a.age_group_id = -1
        THEN NULL
        ELSE a.age_group_id
    END AS "AGE_GROUP_ID",
    CAST(
        CASE
            WHEN a.energy_consumption_kcal_hour = -1
            THEN NULL
            ELSE a.energy_consumption_kcal_hour
        END AS INTEGER) AS "ENERGY_CONSUMPTION",
    asco.staff_group_id AS "STAFF_GROUP_ID",
    a.documentation_setting_id as "DOCUMENTATION_SETTING_ID",
    a.ADDITIONAL_INFO AS "ADDITIONAL_INFO",
    a.DURATION_LIST   AS "DURATION",
    a.LAST_MODIFIED     AS "ETS",
    a.TOP_NODE_ID       AS "TOP_NODE_ID",
    a.SCOPE_TYPE        AS "SCOPE_TYPE",
    a.SCOPE_ID          AS "SCOPE_ID"
FROM
    ACTIVITY a
LEFT JOIN
    COLOUR_GROUPS cg
ON
    a.COLOUR_GROUP_ID = cg.ID
AND a.COLOUR_GROUP_ID IS NOT NULL
LEFT JOIN
    participation_configurations pc
ON
    a.id = pc.activity_id
AND pc.ACCESS_GROUP_ID IS NOT NULL
LEFT JOIN
    ACTIVITY_GROUP ag
ON
    a.ACTIVITY_GROUP_ID = ag.ID
AND a.ACTIVITY_GROUP_ID IS NOT NULL
LEFT JOIN
    activity_staff_configurations asco
ON
    asco.activity_id = a.id
WHERE
    a.STATE != 'DRAFT'

