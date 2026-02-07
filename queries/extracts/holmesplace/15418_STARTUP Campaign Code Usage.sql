SELECT
    pu.PERSON_CENTER||'p'||pu.PERSON_ID                 AS member_id,
    longtodatec(pu.USE_TIME, pu.PERSON_CENTER)          AS campaign_use_time,
    longtodatec(pu.TARGET_START_TIME, pu.PERSON_CENTER) AS privilege_start_time,
    pu.STATE                                            AS privilege_usage_state,
    sc.NAME                                             AS campaign_name,
    longtodatec(sc.STARTTIME, pu.PERSON_CENTER) AS campaign_start_time,
        longtodatec(sc.ENDTIME, pu.PERSON_CENTER) AS campaign_end_time

FROM
    PRIVILEGE_USAGES pu
JOIN
    CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
AND cc.CAMPAIGN_TYPE = 'STARTUP'
JOIN
    HP.STARTUP_CAMPAIGN sc
ON
    sc.ID = cc.CAMPAIGN_ID
WHERE
    cc.CODE = :code AND pu.PERSON_CENTER IN (:scope)