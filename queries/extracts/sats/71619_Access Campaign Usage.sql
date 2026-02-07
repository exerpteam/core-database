WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$FromDate$$                                                              AS StartDate,
            $$ToDate$$                                                              AS EndDate,
            datetolong(TO_CHAR($$FromDate$$, 'YYYY-MM-dd HH24:MI'))                   AS StartDateLong,
            (datetolong(TO_CHAR($$ToDate$$, 'YYYY-MM-dd HH24:MI'))+ 86400 * 1000)-1 AS EndDateLong
        FROM
            dual
    )
    ,
    v_camp AS
    (
        SELECT
            pg.id,
            NVL(prg.NAME,sc.NAME) AS name,
            CASE
                WHEN sc.NAME IS NOT NULL
                THEN 'Startup'
                ELSE 'Privilege'
            END AS type,
            cc.code
        FROM
            PRIVILEGE_RECEIVER_GROUPS prg
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            prg.ID = pg.GRANTER_ID
            AND pg.GRANTER_SERVICE = 'ReceiverGroup'
        LEFT JOIN
            CAMPAIGN_CODES cc
        ON
            cc.CAMPAIGN_ID = prg.ID
        LEFT JOIN
            STARTUP_CAMPAIGN sc
        ON
            cc.CAMPAIGN_TYPE = 'STARTUP'
            AND sc.ID = cc.CAMPAIGN_ID
        WHERE
            prg.RGTYPE = 'CAMPAIGN'
            AND ( (
                    $$searchType$$ = 'CODE'
                    AND cc.CODE = $$code$$)
                OR (
                    $$searchType$$ = 'CAMPAIGN'
                    AND (
                        sc.NAME = $$campaignName$$
                        OR prg.NAME = $$campaignName$$ ) ) )
    )
SELECT
    name AS CAMPAIGN_NAME,
    type AS CAMPAIGN_TYPE,
    code,
    person_center || 'p' || person_id AS PID,
    COUNT(*)                          AS USED
FROM
    (
        SELECT
            camp.name,
            camp.type,
            camp.code,
            pu.person_center,
            pu.person_id
        FROM
            v_camp camp
        CROSS JOIN
            params
        JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.GRANT_ID = camp.ID
            AND pu.TARGET_SERVICE in ('Attend','Participation')
        WHERE
            pu.USE_TIME BETWEEN params.StartDateLong AND params.EndDateLong )
GROUP BY
    name,
    type,
    code,
    person_center,
    person_id