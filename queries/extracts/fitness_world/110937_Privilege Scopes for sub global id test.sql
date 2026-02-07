-- This is the version from 2026-02-05
--  
WITH RECURSIVE
    START_QUERY AS
    (
        SELECT
            a.id,
            a.name,
            a.parent,
            pa.name as parentname,
            ac.CENTER,
            c.name AS centername,
            c.zipcode
        FROM
            AREAS a
        LEFT JOIN
            AREA_CENTERS ac
        ON
            a.ID = ac.AREA
        left join areas pa
        on
        a.parent = pa.id
        
        LEFT JOIN
            centers c
        ON
            ac.center = c.id
    )
    ,
    sub_area (id, name, parent, parentname, center, centername, zipcode) AS
    (
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
        UNION ALL    
        SELECT
            a.id,
            a.name,
            a.parent,
            a.name as parentname,
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
		WHERE
			sa.CENTER IS NOT NULL
			AND a.name != 'Lukkede centre' 
			AND a.name != 'Polen' 
			AND a.name != 'Admin'
			AND sa.centername not like 'OLD%'
			

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
    list_privilegesets AS
    (
        SELECT DISTINCT
            ps.id   AS psId,
            ps.name AS psName,
            pg.USAGE_PRODUCT as pgUSAGE_PRODUCT,
            bpg.name,
            bp.ID,
            bp.PRIVILEGE_SET,
            bp.VALID_FOR,
            bp.VALID_FROM,
            bp.VALID_TO,
            bp.GROUP_ID,
            bp.MAX_OPEN,
            bp.TENTATIVE_ONLY,
            bp.CUTOFF_TIME_SETTING_ID,
            bp.IN_ADVANCE_THRESHOLD,
            bp.REQUIRES_MANUAL_SELECTION,
            (REGEXP_MATCHES(bp.valid_for,'ASS\[([ATCG])[0-9]+\]','i'))[1] AS AREA_TYPE,
            CAST((REGEXP_MATCHES(bp.valid_for,'ASS\[[ATCG]([0-9]+)\]','i'))[1] AS INT) AS AREA_ID
        FROM
            MASTERPRODUCTREGISTER mpr
        JOIN
            products p
        ON
            p.globalid = mpr.globalid
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_ID = mpr.ID
            AND pg.GRANTER_SERVICE = 'GlobalSubscription'
            and pg.VALID_TO is null
        JOIN
            PRIVILEGE_SETS ps
        ON
            ps.ID = pg.PRIVILEGE_SET
        JOIN
            BOOKING_PRIVILEGES bp
        ON
            bp.privilege_set = ps.id
            AND bp.valid_to IS NULL
            and bp.GROUP_ID = 1481    
        JOIN
            BOOKING_PRIVILEGE_GROUPS bpg
        ON
            bp.GROUP_ID = bpg.id
        
        WHERE
            mpr.GLOBALID = :GLOBAL_ID
    )
SELECT distinct
    *
FROM
    (
        SELECT
            tt.id         AS AREA_ID,
            tt.name       AS AREA_NAME,
            tt.center     AS CENTER_ID,            
            tt.centername AS CENTER_NAME,
            psl.psName    AS PRIVILEGE_NAME,
            tt.parentname as Branch,
            tt.ZIPCODE    as ZIPCODE
            
            
        FROM
            list_privilegesets psl
        JOIN
            TEMP_TABLE tt
        ON
            psl.AREA_ID = tt.ID
        WHERE
            psl.AREA_TYPE IN ( 'A',
                              'T')
            and psl.pgUSAGE_PRODUCT is null
            and  tt.id is not NULL
        UNION ALL
        SELECT DISTINCT
            NULL::int     AS AREA_ID,
            NULL          AS AREA_NAME,
            tt.center     AS CENTER_ID,            
            tt.centername AS CENTER_NAME,
            psl.psName    AS PRIVILEGE_NAME,
            tt.parentname as Branch,
            tt.ZIPCODE    as ZIPCODE
            
            
        FROM
            list_privilegesets psl
        JOIN
            TEMP_TABLE tt
        ON
            psl.AREA_ID = tt.CENTER
        WHERE
            psl.AREA_TYPE = 'C'
            and psl.pgUSAGE_PRODUCT is null
            and  tt.id is not NULL
            
        UNION ALL
        SELECT DISTINCT
            NULL::int     AS AREA_ID,
            NULL          AS AREA_NAME,
            tt.center     AS CENTER_ID,            
            tt.centername AS CENTER_NAME,
            psl.psName    AS PRIVILEGE_NAME,
            tt.parentname as Branch,
            tt.ZIPCODE    as ZIPCODE
            
            
        FROM
            list_privilegesets psl
        CROSS JOIN
            TEMP_TABLE tt
        WHERE
            psl.AREA_TYPE = 'G'
            AND tt.center IS NOT NULL 
            and psl.pgUSAGE_PRODUCT is null
            and  tt.id is not NULL) t

	WHERE
			AREA_ID is not NULL