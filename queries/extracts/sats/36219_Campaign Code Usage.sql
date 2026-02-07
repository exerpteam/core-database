SELECT
    cen.Name              AS CENTER,
    NVL(prg.NAME,sc.NAME)    campaign_name,
    cc.CODE,
    priset.NAME    AS PrivilegeSetName,
	pu.person_center||'p'||pu.person_id AS MemberId, 
    COUNT(cc.CODE)    uses
FROM
    SATS.PRIVILEGE_USAGES pu
JOIN
    CENTERS cen
ON
    cen.ID = pu.PERSON_CENTER
LEFT JOIN
    SATS.CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
LEFT JOIN
    SATS.STARTUP_CAMPAIGN sc
ON
    sc.id = cc.CAMPAIGN_ID
    AND cc.CAMPAIGN_TYPE ='STARTUP'
LEFT JOIN
    SATS.PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = cc.CAMPAIGN_ID
    AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
LEFT JOIN
    SATS.PRIVILEGE_GRANTS pgra
ON
    pgra.ID = pu.GRANT_ID
LEFT JOIN
    SATS.PRIVILEGE_SETS priset
ON
    priset.ID = pgra.PRIVILEGE_SET
WHERE
    pu.USE_TIME BETWEEN :longDateFrom AND :longDateTo
    AND (
        prg.PLUGIN_CODES_NAME = :pluginCodeName
        OR sc.PLUGIN_CODES_NAME = :pluginCodeName)
    AND pu.PERSON_CENTER IN (:scope)
    AND pu.STATE <> 'CANCELLED'
    AND pu.CAMPAIGN_CODE_ID is not null
GROUP BY
    cen.Name,
    NVL(prg.NAME,sc.NAME),
    cc.CODE,
    priset.NAME,
	pu.person_center||'p'||pu.person_id




