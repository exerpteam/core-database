-- The extract is extracted from Exerp on 2026-02-08
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
    list_products AS
    (
        SELECT DISTINCT
            mpr.id   AS mprId,
            mpr.globalid AS globalid,
            pa.scope_type AS AREA_TYPE,
            pa.scope_id as AREA_ID,
            CAST(p.price AS VARCHAR) as price,
            p.name as pname
            
           -- regexp_substr(pa.SCOPE_TYPE, 'ASS\\[([ATCG])[0-9]+\\]',1,1,NULL,1)              AS AREA_TYPE,
           -- CAST(regexp_substr(pa.SCOPE_ID, 'ASS\\[[ATCG]([0-9]+)\\]',1,1,NULL,1) AS INT) AS AREA_ID
        FROM
            MASTERPRODUCTREGISTER mpr
        JOIN
            products p
        ON
            p.globalid = mpr.globalid
		AND
			mpr.STATE = 'ACTIVE'
		JOIN 
			PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
		ON
			ppgl.PRODUCT_CENTER = p.CENTER
		AND 
			ppgl.PRODUCT_ID = p.ID
		
		JOIN
			PRODUCT_GROUP pg
		ON
			pg.ID = ppgl.PRODUCT_GROUP_ID
			AND pg.ID in (32801, 52201)
                      
        join PRODUCT_AVAILABILITY pa
        on
        pa.PRODUCT_MASTER_KEY = mpr.id
        WHERE
            p.center in (:scope) and
            p.PTYPE = 10
            and mpr.state != 'DELETED'
			and mpr.globalid like 'CORE_%'
			OR mpr.globalid like 'OFFPEAK_%'
			OR mpr.globalid like 'PLUS_________20%'
			OR mpr.globalid like 'PLUS__________20%'
			OR mpr.globalid like 'PLUS_UNLIMITED%'
			OR mpr.globalid like 'PREPAID%'
			or mpr.globalid like 'PREAPAID%'
			OR mpr.globalid like 'CASH%'
			--and mpr.globalid not like 'PLUS_FRIEND%'
			and mpr.globalid not like 'PLUS_KIRSTEN'
			and mpr.globalid not like 'PLUS_TEST_IMPORT'

           
    )
SELECT distinct
    *
FROM
    (
        SELECT
            pname          AS NAME,            
            tt.center     AS CENTER_ID,            
            tt.centername AS CENTER_NAME,
            price         AS PRICE,
            globalid    AS globalid
            
            
            
        FROM
            list_products psl
        JOIN
            TEMP_TABLE tt
        ON
            psl.AREA_ID = tt.ID
        WHERE
            psl.AREA_TYPE IN ( 'A',
                              'T')
           and  tt.id is not NULL
           AND tt.center IS NOT NULL 
        UNION ALL
        SELECT DISTINCT
           PNAME          AS NAME,
           tt.center     AS CENTER_ID,            
            tt.centername AS CENTER_NAME,
            price         AS PRICE,
            globalid    AS globalid
           
          
            
        FROM
            list_products psl
        JOIN
            TEMP_TABLE tt
        ON
            psl.AREA_ID = tt.CENTER
        WHERE
            psl.AREA_TYPE = 'C'
         and  tt.id is not NULL
         AND tt.center IS NOT NULL 
						AND tt.centername not like 'Lille%'
            			AND tt.centername not like 'OLD%'
						AND tt.centername not like 'Admin%'
        UNION ALL
        SELECT DISTINCT
            PNAME          AS NAME,   
            tt.center     AS CENTER_ID,            
            tt.centername AS CENTER_NAME,
            price         AS PRICE, 
            globalid    AS globalid
             
        FROM
            list_products psl
        CROSS JOIN
            TEMP_TABLE tt
        WHERE
            psl.AREA_TYPE = 'G'
            AND tt.center IS NOT NULL 
            and  tt.id is not NULL) t

