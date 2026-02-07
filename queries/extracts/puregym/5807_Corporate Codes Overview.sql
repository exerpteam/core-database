SELECT
    cc.CODE,
    prg.NAME                                    AS "Campaign Name",
    longtodatetz(prg.STARTTIME,'Europe/London') Start_DATE,
    longtodatetz(prg.ENDTIME,'Europe/London')   END_DATE,
    priv_s.NAME                                 AS "Privilege Set",
    DECODE(a.NAME,NULL,c.NAME,a.NAME)           AS "Scope",
    prg.PLUGIN_NAME,
    CASE
        WHEN priv_g.VALID_FROM<=datetolong(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MM'))
        THEN 'Active'
        when priv_g.VALID_FROM>datetolong(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MM'))
        then 'Planned'
    END AS Status
FROM
    PUREGYM.CAMPAIGN_CODES cc
JOIN
    PUREGYM.PRIVILEGE_RECEIVER_GROUPS prg
ON
    cc.CAMPAIGN_ID = prg.ID
    AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
LEFT JOIN
    PUREGYM.PRIVILEGE_GRANTS priv_g
ON
    priv_g.GRANTER_SERVICE = 'ReceiverGroup'
    AND priv_g.GRANTER_ID = prg.ID
    AND priv_g.VALID_FROM<datetolong(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MM'))
    AND (
        priv_g.VALID_TO > datetolong(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MM'))
        OR priv_g.VALID_TO IS NULL)
LEFT JOIN
    PUREGYM.PRIVILEGE_SETS priv_s
ON
    priv_s.ID = priv_g.PRIVILEGE_SET
LEFT JOIN
    PUREGYM.AREAS a
ON
    prg.SCOPE_ID = a.ID
    AND prg.SCOPE_TYPE !='C'
LEFT JOIN
    PUREGYM.CENTERS c
ON
    prg.SCOPE_ID = c.ID
    AND prg.SCOPE_TYPE ='C'
WHERE
    cc.used =0
    AND (
        prg.ENDTIME IS NULL
        OR prg.ENDTIME > dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI')))