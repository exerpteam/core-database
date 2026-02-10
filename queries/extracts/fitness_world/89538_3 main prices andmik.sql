-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    START_QUERY AS
    (
        SELECT
            a.id,
            a.name,
            a.parent,
            pa.name AS parentname,
            ac.CENTER,
            c.name AS centername,
            c.zipcode
        FROM
            AREAS a
        LEFT JOIN
            AREA_CENTERS ac
        ON
            a.ID = ac.AREA
        LEFT JOIN
            areas pa
        ON
            a.parent = pa.id
        LEFT JOIN
            centers c
        ON
            ac.center = c.id
    )
    ,
    sub_area
    (
        id,
        name,
        parent,
        parentname,
        center,
        centername,
        zipcode
    ) AS
    (
        SELECT
            a.id,
            a.name,
            a.parent,
            a.name AS parentname,
            sa.center,
            sa.centername,
            c.zipcode
        FROM
            sub_area sa
        JOIN
            areas a
        ON
            sa.PARENT = a.id
        JOIN
            centers c
        ON
            sa.center = c.id
        UNION ALL
        SELECT
            Sa.id,
            Sa.name,
            Sa.parent,
            Sa.parentname,
            sa.center,
            sa.centername,
            sa.zipcode
        FROM
            START_QUERY sa
    )
    ,
    TEMP_TABLE AS
    (
        SELECT
            *
        FROM
            sub_area
    )
    ,
    AVAILABILITY AS
    (
        SELECT
            sc.ID,
            sc.NAME,
            sc.STARTTIME,
            sc.ENDTIME,
            sc.AVAILABLE_SCOPES
        FROM
            STARTUP_CAMPAIGN sc
        WHERE
            TRUNC(longtodate(sc.STARTTIME)) <= CURRENT_DATE
        AND TRUNC(longtodate(sc.ENDTIME)) > CURRENT_DATE
		AND sc.STATE = 'ACTIVE'
    )
    ,
    START_CAMPAIGNS AS
    (
        SELECT
            avail.ID,
            avail.NAME,
            avail.STARTTIME,
            avail.ENDTIME,
            REGEXP_SUBSTR(avail.AVAILABLE_SCOPES,'[^,]+', 1, LEVEL) AVAILABILITY
        FROM
            AVAILABILITY avail CONNECT BY avail.ID = PRIOR avail.ID
        AND prior sys_guid() IS NOT NULL
        AND LEVEL <= REGEXP_COUNT(avail.AVAILABLE_SCOPES, ',') + 1
    )
    ,
    STARTUP_CAMPAIGNS AS
    (
        SELECT DISTINCT
            stcam.ID,
            stcam.NAME,
            stcam.STARTTIME,
            stcam.ENDTIME,
            SUBSTR(stcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
            SUBSTR(stcam.AVAILABILITY, 2,LENGTH(stcam.AVAILABILITY)-1) AS SCOPE_ID
        FROM
            START_CAMPAIGNS stcam
    )
    ,
    AVAILABILITY_PRIV AS
    (
        SELECT
            prg.ID,
            prg.NAME,
            prg.STARTTIME,
            prg.ENDTIME,
            prg.AVAILABLE_SCOPES
        FROM
            PRIVILEGE_RECEIVER_GROUPS prg
        WHERE
            prg.RGTYPE = 'CAMPAIGN'
        AND TRUNC(longtodate(prg.ENDTIME)) > CURRENT_DATE
        AND TRUNC(longtodate(prg.STARTTIME)) <= CURRENT_DATE
		AND prg.blocked = 0
        AND (
                prg.WEB_TEXT LIKE 'L-%'
            OR  prg.WEB_TEXT LIKE 'N-%')
    )
    ,
    PRIV_CAMPAIGNS AS
    (
        SELECT
            avail_priv.ID,
            avail_priv.NAME,
            avail_priv.STARTTIME,
            avail_priv.ENDTIME,
            LEVEL,
            REGEXP_SUBSTR(avail_priv.AVAILABLE_SCOPES,'[^,]+', 1, LEVEL) AVAILABILITY
        FROM
            AVAILABILITY_PRIV avail_priv CONNECT BY avail_priv.ID = PRIOR avail_priv.ID
        AND prior sys_guid() IS NOT NULL
        AND LEVEL <= REGEXP_COUNT(avail_priv.AVAILABLE_SCOPES, ',') + 1
    )
    ,
    PRIVILEGE_CAMPAIGNS AS
    (
        SELECT DISTINCT
            prcam.ID,
            prcam.NAME,
            prcam.STARTTIME,
            prcam.ENDTIME,
            SUBSTR(prcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
            SUBSTR(prcam.AVAILABILITY, 2,LENGTH(prcam.AVAILABILITY)-1) AS SCOPE_ID
        FROM
            PRIV_CAMPAIGNS prcam
    )
    ,
    mpr AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    extract(xmltype(mpr.product, 871),
                    '//subscriptionType/subscriptionNew/product/requiredRole/text()').getStringVal
                    () AS requiredRole,
                    mpr.*
                FROM
                    masterproductregister mpr )
        WHERE
            globalid LIKE 'PLUS%'
        AND globalid NOT IN 'PLUS_FRIEND'
        AND globalid NOT LIKE 'PLUS%UPGRADE'
        AND requiredRole IS NULL
        AND state = 'ACTIVE'
        AND scope_id = 2
    )
    ,
    plus_products AS
    (
        SELECT
            pr.CENTER,
            pr.PRICE,
            pr.name,
            pr.GLOBALID
        FROM
            mpr
        JOIN
            PRODUCTS pr
        ON
            mpr.GLOBALID = pr.GLOBALID
        WHERE
            pr.BLOCKED = 0
    )
    ,
    mpr_core AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    extract(xmltype(mpr.product, 871),
                    '//subscriptionType/subscriptionNew/product/requiredRole/text()').getStringVal
                    () AS requiredRole,
                    mpr.*
                FROM
                    masterproductregister mpr )
        WHERE
            globalid LIKE 'CORE%'
	 AND globalid NOT LIKE 'CORE_OFF%'
        AND requiredRole IS NULL
        AND state = 'ACTIVE'
        AND scope_id = 2
    )
,
 mpr_offpeak AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    extract(xmltype(mpr.product, 871),
                    '//subscriptionType/subscriptionNew/product/requiredRole/text()').getStringVal
                    () AS requiredRole,
                    mpr.*
                FROM
                    masterproductregister mpr )
        WHERE
            globalid LIKE 'CORE_OFF%'
	AND requiredRole IS NULL
        AND state = 'ACTIVE'
        AND scope_id = 2
    )
    ,
    core_products AS
    (
        SELECT
            pr.CENTER,
            pr.PRICE,
            pr.name,
            pr.GLOBALID
        FROM
            mpr_core
        JOIN
            PRODUCTS pr
        ON
            mpr_core.GLOBALID = pr.GLOBALID
        WHERE
            pr.BLOCKED = 0
            AND mpr_core.globalid LIKE 'CORE%'
            AND mpr_core.globalid NOT LIKE 'CORE_CLASSES%'
			AND mpr_core.globalid NOT LIKE 'CORE_OFF%'
    )
    ,
	offpeak_products AS
    (
        SELECT
            pr.CENTER,
            pr.PRICE,
            pr.name,
            pr.GLOBALID
        FROM
            mpr_offpeak
        JOIN
            PRODUCTS pr
        ON
            mpr_offpeak.GLOBALID = pr.GLOBALID
        WHERE
            pr.BLOCKED = 0
            AND mpr_offpeak.globalid LIKE 'CORE_OFF%'
            AND mpr_offpeak.globalid NOT LIKE 'CORE_CLASSES%'
    )
,    
	core_hold_products AS
    (
        SELECT
            pr.CENTER,
            pr.PRICE,
            pr.name,
            pr.GLOBALID
        FROM
            mpr_core
        JOIN
            PRODUCTS pr
        ON
            mpr_core.GLOBALID = pr.GLOBALID
        WHERE
            pr.BLOCKED = 0
            AND mpr_core.globalid like 'CORE_CLASSES%'
    )
    
SELECT DISTINCT
    "Center ID",
    "Center name",
    "Address",
    "Zipcode",
    "City",
    "Longitude",
    "Lattitude",
    "Total area",
    "Core price",
    "Core og Hold price",
    "Plus Price",
    "OffPeak price"
    "Plus GlobalID",
    "Temp closed start",
    "Temp closed end",
    LISTAGG("Startup campaign", ';') WITHIN GROUP (ORDER BY "Startup campaign") AS
    "Startup campaign",
    LISTAGG("Privilege campaign", ';') WITHIN GROUP (ORDER BY "Privilege campaign") AS
    "Privilege campaign"
FROM
    (
        SELECT DISTINCT
            c.id                AS "Center ID",
            c.name              AS "Center name",
            c.address2          AS "Address",
            c.zipcode           AS "Zipcode",
            c.city              AS "City",
            c.LONGITUDE         AS "Longitude",
            c.LATITUDE          AS "Lattitude",
            tot_area.TXT_VALUE  AS "Total area",
            prod.price          AS "Core price",
            prod2.price         AS "Core og Hold price",
            offpeakprod.price	AS "OffPeak price",		
            pp.price            AS "Plus Price",
            pp.GLOBALID         AS "Plus GlobalID",
            start_cea.TXT_VALUE AS "Temp closed start",
            stop_cea.TXT_VALUE  AS "Temp closed end",
            sc_center.NAME      AS "Startup campaign",
            NULL                AS "Privilege campaign"
        FROM
            centers c
        LEFT JOIN
            core_products prod
        ON
            c.id = prod.center
        LEFT JOIN
            core_hold_products prod2
        ON
            c.id = prod2.center
        LEFT JOIN
            plus_products pp
        ON
            pp.CENTER = c.id
        LEFT JOIN
            offpeak_products offpeakprod
        ON
            c.id = offpeakprod.center
	LEFT JOIN
            CENTER_EXT_ATTRS start_cea
        ON
            c.ID = start_cea.CENTER_ID
        AND start_cea.NAME = 'TEMPCLOSEDSTART'
        LEFT JOIN
            CENTER_EXT_ATTRS stop_cea
        ON
            c.ID = stop_cea.CENTER_ID
        AND stop_cea.NAME = 'TEMPCLOSEDEND'
        LEFT JOIN
            CENTER_EXT_ATTRS tot_area
        ON
            c.ID = tot_area.CENTER_ID
        AND tot_area.NAME = 'TOTALAREA'
        LEFT JOIN
            STARTUP_CAMPAIGNS sc_center
        ON
            sc_center.SCOPE_ID = c.ID
        AND sc_center.SCOPE_TYPE = 'C'
        WHERE
            c.country = 'DK'
        AND c.id IN (:scope)
        AND c.id != 100
        AND c.name NOT LIKE 'OLD%'
        UNION ALL
        SELECT DISTINCT
            c.id                AS "Center ID",
            c.name              AS "Center name",
            c.address2          AS "Address",
            c.zipcode           AS "Zipcode",
            c.city              AS "City",
            c.LONGITUDE         AS "Longitude",
            c.LATITUDE          AS "Lattitude",
            tot_area.TXT_VALUE  AS "Total area",
            prod.price          AS "Core price",
            prod2.price         AS "Core og Hold price",
            pp.price            AS "Plus Price",
	    offpeakprod.price	AS "OffPeak price",
            pp.GLOBALID         AS "Plus GlobalID",
            start_cea.TXT_VALUE AS "Temp closed start",
            stop_cea.TXT_VALUE  AS "Temp closed end",
            sc_area.NAME        AS "Startup campaign",
            NULL                AS "Privilege campaign"
        FROM
            centers c
        LEFT JOIN
            core_products prod
        ON
            c.id = prod.center
        LEFT JOIN
            core_hold_products prod2
        ON
            c.id = prod2.center
        LEFT JOIN
            plus_products pp
        ON
            pp.CENTER = c.id
	LEFT JOIN
            offpeak_products offpeakprod
        ON
            c.id = offpeakprod.center
        LEFT JOIN
            CENTER_EXT_ATTRS start_cea
        ON
            c.ID = start_cea.CENTER_ID
        AND start_cea.NAME = 'TEMPCLOSEDSTART'
        LEFT JOIN
            CENTER_EXT_ATTRS stop_cea
        ON
            c.ID = stop_cea.CENTER_ID
        AND stop_cea.NAME = 'TEMPCLOSEDEND'
        LEFT JOIN
            CENTER_EXT_ATTRS tot_area
        ON
            c.ID = tot_area.CENTER_ID
        AND tot_area.NAME = 'TOTALAREA'
        JOIN
            TEMP_TABLE tt
        ON
            tt.CENTER = c.ID
        AND tt.ID IS NOT NULL
        AND tt.CENTER IS NOT NULL
        LEFT JOIN
            STARTUP_CAMPAIGNS sc_area
        ON
            sc_area.SCOPE_ID = tt.ID
        AND sc_area.SCOPE_TYPE IN ('A',
                                   'T')
        AND tt.ID IS NOT NULL
        WHERE
            c.country = 'DK'
        AND c.id IN (:scope)
        AND c.id != 100
        AND c.name NOT LIKE 'OLD%'
        UNION ALL
        SELECT DISTINCT
            c.id                AS "Center ID",
            c.name              AS "Center name",
            c.address2          AS "Address",
            c.zipcode           AS "Zipcode",
            c.city              AS "City",
            c.LONGITUDE         AS "Longitude",
            c.LATITUDE          AS "Lattitude",
            tot_area.TXT_VALUE  AS "Total area",
            prod.price          AS "Core price",
            prod2.price         AS "Core og Hold price",
            pp.price            AS "Plus Price",
	    offpeakprod.price	AS "OffPeak price",
            pp.GLOBALID         AS "Plus GlobalID",
            start_cea.TXT_VALUE AS "Temp closed start",
            stop_cea.TXT_VALUE  AS "Temp closed end",
            NULL                AS "Startup campaign",
            pr_center.NAME      AS "Privilege campaign"
        FROM
            centers c
        LEFT JOIN
            core_products prod
        ON
            c.id = prod.center
        LEFT JOIN
            core_hold_products prod2
        ON
            c.id = prod2.center
        LEFT JOIN
            plus_products pp
        ON
            pp.CENTER = c.id
	LEFT JOIN
            offpeak_products offpeakprod
        ON
            c.id = offpeakprod.center
        LEFT JOIN
            CENTER_EXT_ATTRS start_cea
        ON
            c.ID = start_cea.CENTER_ID
        AND start_cea.NAME = 'TEMPCLOSEDSTART'
        LEFT JOIN
            CENTER_EXT_ATTRS stop_cea
        ON
            c.ID = stop_cea.CENTER_ID
        AND stop_cea.NAME = 'TEMPCLOSEDEND'
        LEFT JOIN
            CENTER_EXT_ATTRS tot_area
        ON
            c.ID = tot_area.CENTER_ID
        AND tot_area.NAME = 'TOTALAREA'
        LEFT JOIN
            PRIVILEGE_CAMPAIGNS pr_center
        ON
            pr_center.SCOPE_ID = c.ID
        AND pr_center.SCOPE_TYPE = 'C'
        WHERE
            c.country = 'DK'
        AND c.id IN (:scope)
        AND c.id != 100
        AND c.name NOT LIKE 'OLD%'
        UNION ALL
        SELECT DISTINCT
            c.id                AS "Center ID",
            c.name              AS "Center name",
            c.address2          AS "Address",
            c.zipcode           AS "Zipcode",
            c.city              AS "City",
            c.LONGITUDE         AS "Longitude",
            c.LATITUDE          AS "Lattitude",
            tot_area.TXT_VALUE  AS "Total area",
            prod.price          AS "Core price",
            prod2.price         AS "Core og Hold price",
            pp.price            AS "Plus Price",
	    offpeakprod.price	AS "OffPeak price",
            pp.GLOBALID         AS "Plus GlobalID",
            start_cea.TXT_VALUE AS "Temp closed start",
            stop_cea.TXT_VALUE  AS "Temp closed end",
            NULL                AS "Startup campaign",
            pr_area.NAME        AS "Privilege campaign"
        FROM
            centers c
        LEFT JOIN
            core_products prod
        ON
            c.id = prod.center
        LEFT JOIN
            core_hold_products prod2
        ON
            c.id = prod2.center
        LEFT JOIN
            plus_products pp
        ON
            pp.CENTER = c.id
	LEFT JOIN
            offpeak_products offpeakprod
        ON
            c.id = offpeakprod.center
        LEFT JOIN
            CENTER_EXT_ATTRS start_cea
        ON
            c.ID = start_cea.CENTER_ID
        AND start_cea.NAME = 'TEMPCLOSEDSTART'
        LEFT JOIN
            CENTER_EXT_ATTRS stop_cea
        ON
            c.ID = stop_cea.CENTER_ID
        AND stop_cea.NAME = 'TEMPCLOSEDEND'
        LEFT JOIN
            CENTER_EXT_ATTRS tot_area
        ON
            c.ID = tot_area.CENTER_ID
        AND tot_area.NAME = 'TOTALAREA'
        JOIN
            TEMP_TABLE tt
        ON
            tt.CENTER = c.ID
        AND tt.ID IS NOT NULL
        AND tt.CENTER IS NOT NULL
        LEFT JOIN
            PRIVILEGE_CAMPAIGNS pr_area
        ON
            pr_area.SCOPE_ID = tt.ID
        AND pr_area.SCOPE_TYPE IN ('A',
                                   'T')
        AND tt.ID IS NOT NULL
        WHERE
            c.country = 'DK'
        AND c.id IN (:scope)
        AND c.id != 100
        AND c.name NOT LIKE 'OLD%')
GROUP BY
    "Center ID",
    "Center name",
    "Address",
    "Zipcode",
    "City",
    "Longitude",
    "Lattitude",
    "Total area",
    "OffPeak price",
    "Core price",
    "Core og Hold price",
    "Plus Price",
    "Plus GlobalID",
    "Temp closed start",
    "Temp closed end"
ORDER BY
    "Center ID"
