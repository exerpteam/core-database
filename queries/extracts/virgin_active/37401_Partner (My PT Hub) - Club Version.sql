WITH
    PARAMS AS
    (
        SELECT
                datetolongTZ(TO_CHAR(trunc(sysdate, 'MONTH'), 'YYYY-MM-DD HH24:MI'),'Europe/London') AS prevMonth,
                datetolongTZ(TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI'),'Europe/London') AS today,
                sysdate AS todayDate
        FROM dual
    )
--First part: Clip Card product
SELECT
        pc.Name AS "Add-on/clip card product", 
        pg.USAGE_DURATION_VALUE  AS "Duration of the sessions",
        TO_CHAR(longtodateC(cc.VALID_UNTIL,cc.CENTER),'YYYY-MM-DD') AS "Expiry of active sessions",
        p.EXTERNAL_ID AS "Member external ID",
        pc.PRICE AS "Price of product",
        nvl(overall."Session used in total",0) AS "Session used in total",
        --cct.clip_count - nvl(session_totals."Sessions used",0) AS "Sessions remaining",
        cc.CLIPS_LEFT AS "Sessions remaining",
        nvl(session_totals."Sessions used",0) AS "Sessions used",
        --cct.clip_count AS "Totals sessions",
        cc.CLIPS_INITIAL AS "Totals sessions",
        Trainer_Level."Trainer Level",
        DECODE(bp.VALID_FOR,'LSS','Local',VALID_FOR) AS "Where clips can be used"
FROM
        PARAMS
CROSS JOIN PERSONS p
JOIN    CLIPCARDS cc ON p.CENTER = cc.OWNER_CENTER AND p.ID = cc.OWNER_ID AND cc.finished = 0
JOIN    PRODUCTS pc ON pc.CENTER = cc.CENTER AND pc.ID = cc.ID
LEFT JOIN  
        (
                SELECT
                        p.external_id, 
                        cc.center,
                        cc.id,
                        cc.subid, 
                        listagg (pg.Name, ', ') WITHIN GROUP (ORDER BY prod.Name) AS "Trainer Level"
                FROM
                        PARAMS
                CROSS JOIN PERSONS p
                JOIN    CLIPCARDS cc ON p.CENTER = cc.OWNER_CENTER AND p.ID = cc.OWNER_ID
                JOIN    PRODUCTS prod ON prod.center = cc.CENTER AND prod.ID = cc.ID
                JOIN    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl ON ppgl.PRODUCT_CENTER = prod.CENTER AND ppgl.PRODUCT_ID = prod.ID
                JOIN    PRODUCT_GROUP pg ON pg.id = ppgl.PRODUCT_GROUP_ID
                WHERE
                        cc.VALID_UNTIL > PARAMS.today
                        AND cc.finished = 0
                GROUP BY 
                        p.External_ID, cc.center, cc.id, cc.subid
        ) Trainer_Level
                ON 
                        Trainer_Level.External_id = p.external_id
                        AND Trainer_Level.center = cc.center
                        AND Trainer_Level.subid = cc.subid
                        AND Trainer_Level.id = cc.id
LEFT JOIN
        (
                SELECT 
                        pu.SOURCE_ID,
                        pu.SOURCE_CENTER,
                        pu.PERSON_CENTER,
                        pu.PERSON_ID,
                        count(*) AS "Session used in total"
                FROM 
                        PRIVILEGE_SETS ps
                JOIN    BOOKING_PRIVILEGES bg ON bg.PRIVILEGE_SET = ps.id
                JOIN    PRIVILEGE_USAGES pu ON bg.id = pu.PRIVILEGE_ID
                WHERE 
                        (pu.STATE = 'CANCELLED' AND (pu.MISUSE_STATE = 'PUNISHED' OR pu.MISUSE_STATE = 'MISUSED'))
                        OR 
                        pu.STATE in  ('USED','PLANNED')
                GROUP BY 
                        pu.SOURCE_ID, pu.SOURCE_CENTER, pu.PERSON_ID, pu.PERSON_CENTER
        ) overall
                ON
                        overall.SOURCE_ID = cc.id 
                        AND overall.SOURCE_CENTER = cc.center 
                        AND overall.PERSON_CENTER = p.CENTER
                        AND overall.PERSON_ID = p.ID
LEFT JOIN
        (
                SELECT 
                        pu.SOURCE_ID,
                        pu.SOURCE_CENTER,
                        pu.SOURCE_SUBID,
                        pu.PERSON_CENTER,
                        pu.PERSON_ID,
                        COUNT(*) AS "Sessions used"
                FROM 
                        PRIVILEGE_SETS ps
                JOIN    BOOKING_PRIVILEGES bg ON bg.PRIVILEGE_SET = ps.id
                JOIN    PRIVILEGE_USAGES pu ON bg.id = pu.PRIVILEGE_ID
                WHERE 
                        (pu.STATE = 'CANCELLED' AND (pu.MISUSE_STATE = 'PUNISHED' OR pu.MISUSE_STATE = 'MISUSED'))
                        OR 
                        pu.STATE in  ('USED','PLANNED')
                GROUP BY 
                        pu.SOURCE_ID, pu.SOURCE_CENTER, pu.PERSON_ID, pu.PERSON_CENTER, pu.SOURCE_SUBID
        ) session_totals
                ON
                        session_totals.SOURCE_ID = cc.id 
                        AND session_totals.SOURCE_CENTER = cc.center 
                        AND session_totals.SOURCE_SUBID = cc.SUBID
                        AND session_totals.PERSON_CENTER = p.CENTER
                        AND session_totals.PERSON_ID = p.ID
JOIN    PRIVILEGE_CACHE pca ON pca.SOURCE_ID = cc.ID AND pca.SOURCE_CENTER = cc.CENTER AND pca.SOURCE_SUBID = cc.SUBID AND pca.PERSON_ID = p.ID 
                               AND pca.PERSON_CENTER = p.CENTER AND pca.privilege_type = 'BOOKING' AND pca.valid_from <= params.today
                               AND (pca.valid_to >= params.today OR pca.valid_to is null) 
JOIN    BOOKING_PRIVILEGES bp ON bp.ID = pca.privilege_id 
JOIN    PRIVILEGE_SETS ps ON bp.PRIVILEGE_SET = ps.id 
JOIN    PRIVILEGE_GRANTS pg ON pg.id = pca.GRANT_ID AND pg.USAGE_DURATION_VALUE is not null 
WHERE 
        cc.VALID_UNTIL >= params.today
        AND p.center IN (:Scope)
        AND EXISTS     
        (
	       SELECT 1 
               FROM PRODUCTS pro
               JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl ON ppgl.PRODUCT_CENTER = pro.CENTER AND ppgl.PRODUCT_ID = pro.ID
               JOIN PRODUCT_GROUP pg ON pg.id = ppgl.PRODUCT_GROUP_ID AND pg.name in ('PT Clipcards','Personal Training','PT Top Ups') 
               WHERE
   	            pro.center = pc.center
                    AND pro.id = pc.id
	)  
UNION ALL
-- second part: ADD ON
SELECT
        prod.Name AS "Add-on/clip card product", 
        (CASE WHEN 
                instr(bpg.NAME,'60') > 0  THEN 60
                ELSE
                        (CASE WHEN instr(bpg.NAME,'30') > 0  THEN 30 END)
        END) AS "Duration of the sessions",
        TO_CHAR(sa.END_DATE,'YYYY-MM-DD') AS "Expiry of active sessions",
        p.EXTERNAL_ID AS "Member external ID",
        prod.PRICE AS "Price of product",
        nvl(overall."Session used in total",0) AS "Session used in total",
        nvl(ps.FREQUENCY_RESTRICTION_COUNT,0) - nvl(session_totals."Sessions used",0) AS "Sessions remaining",
        nvl(session_totals."Sessions used",0) AS "Sessions used",
        nvl(ps.FREQUENCY_RESTRICTION_COUNT,0) AS "Total sessions",
        Trainer_Level."Trainer Level",
        DECODE(bp.VALID_FOR,'LSS','Local',VALID_FOR) AS "Where clips can be used"
FROM
        PARAMS
CROSS JOIN PERSONS p
JOIN    SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID
JOIN    SUBSCRIPTION_ADDON sa ON s.CENTER = sa.SUBSCRIPTION_CENTER AND s.ID = sa.SUBSCRIPTION_ID AND ((sa.end_date is null) or (sa.end_date >= params.todayDate))
JOIN    MASTERPRODUCTREGISTER mpr ON mpr.id = sa.ADDON_PRODUCT_ID 
JOIN    PRODUCTS prod ON prod.center = sa.CENTER_ID AND prod.GLOBALID = mpr.GLOBALID
LEFT JOIN
        (
                SELECT 
                        p.external_id, 
                        listagg (pg.Name, ', ') WITHIN GROUP (ORDER BY prod.Name) AS "Trainer Level"
                FROM
                        PARAMS
                CROSS JOIN PERSONS p
                JOIN    SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID
                JOIN    SUBSCRIPTION_ADDON sa ON s.CENTER = sa.SUBSCRIPTION_CENTER AND s.ID = sa.SUBSCRIPTION_ID
                JOIN    MASTERPRODUCTREGISTER mpr ON mpr.id = sa.ADDON_PRODUCT_ID
                JOIN    PRODUCTS prod ON prod.center = sa.CENTER_ID AND prod.GLOBALID = mpr.GLOBALID
                JOIN    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl ON ppgl.PRODUCT_CENTER = prod.CENTER AND ppgl.PRODUCT_ID = prod.ID
                JOIN    PRODUCT_GROUP pg ON pg.id = ppgl.PRODUCT_GROUP_ID
                WHERE 
                        ((sa.end_date is null) or (sa.end_date >= params.todayDate))
                GROUP BY 
                        p.External_ID
        ) Trainer_Level
                ON 
                        Trainer_Level.External_id = p.external_id
LEFT JOIN
        (
                SELECT 
                        pu.SOURCE_ID,
                        count(*) AS "Sessions used"
                FROM 
                        PARAMS
                CROSS JOIN PRIVILEGE_SETS ps
                JOIN    BOOKING_PRIVILEGES bg ON bg.PRIVILEGE_SET = ps.id
                JOIN    PRIVILEGE_USAGES pu ON bg.id = pu.PRIVILEGE_ID
                WHERE 
                        pu.USE_TIME BETWEEN params.prevMonth and params.today
                        AND pu.target_service = 'Participation' 
                        AND pu.SOURCE_CENTER is null
                        AND ((pu.STATE = 'CANCELLED' AND (pu.MISUSE_STATE = 'PUNISHED' OR pu.MISUSE_STATE = 'MISUSED'))
                        OR pu.STATE in  ('USED','PLANNED'))
                GROUP BY 
                        pu.SOURCE_ID
        ) session_totals
                ON
                        session_totals.SOURCE_ID = sa.ID
LEFT JOIN
        (
                SELECT 
                        pu.PERSON_CENTER,
                        pu.PERSON_ID,
                        pu.SOURCE_ID,
                        count(*) AS "Session used in total"
                FROM 
                        PRIVILEGE_SETS ps
                JOIN    BOOKING_PRIVILEGES bg ON bg.PRIVILEGE_SET = ps.id
                JOIN    PRIVILEGE_USAGES pu ON bg.id = pu.PRIVILEGE_ID
                WHERE 
                        pu.target_service = 'Participation' 
                        AND ((pu.STATE = 'CANCELLED' AND (pu.MISUSE_STATE = 'PUNISHED' OR pu.MISUSE_STATE = 'MISUSED'))
                        OR pu.STATE in  ('USED','PLANNED'))
                GROUP BY 
                        pu.PERSON_CENTER, 
                        pu.PERSON_ID,
                        pu.SOURCE_ID
        ) overall
                ON
                        overall.PERSON_ID = p.ID
                        AND overall.PERSON_CENTER = p.CENTER
                        AND overall.SOURCE_ID = sa.ID
JOIN    PRIVILEGE_CACHE pca ON pca.SOURCE_ID = sa.ID AND pca.SOURCE_CENTER is null AND pca.PERSON_ID = p.ID AND pca.PERSON_CENTER = p.CENTER
                               AND pca.valid_from <= params.today
                               AND (pca.valid_to >= params.today OR pca.valid_to is null)
JOIN    BOOKING_PRIVILEGES bp ON bp.ID = pca.privilege_id AND pca.privilege_type = 'BOOKING'
JOIN    PRIVILEGE_SETS ps ON bp.PRIVILEGE_SET = ps.id AND ps.FREQUENCY_RESTRICTION_COUNT IS NOT NULL
JOIN    BOOKING_PRIVILEGE_GROUPS bpg ON bpg.id = bp.group_id 
WHERE 
        p.CENTER IN (:Scope)
        AND ((sa.end_date is null) or (sa.end_date >= params.todayDate))
        AND EXISTS     
        (
	       SELECT 1 
               FROM PRODUCTS pro
               JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl ON ppgl.PRODUCT_CENTER = pro.CENTER AND ppgl.PRODUCT_ID = pro.ID
               JOIN PRODUCT_GROUP pg ON pg.id = ppgl.PRODUCT_GROUP_ID AND pg.name in ('PT Clipcards','Personal Training','PT Top Ups') 
               WHERE
   	            pro.center = prod.center
                    AND pro.id = prod.id
	)
