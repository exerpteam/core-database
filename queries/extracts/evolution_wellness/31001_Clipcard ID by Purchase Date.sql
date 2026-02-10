-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
        params AS
        (
        SELECT
                /*+ materialize */
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
                centers c
        ) 
SELECT DISTINCT 
		CC.CENTER ||'cc'|| CC.ID ||'cc'|| CC.SUBID 										AS "Clipcard ID",
	--	CC.CENTER AS CENTER, CC.ID AS ID, CC.SUBID AS SUBID, 
	--  CC.OWNER_CENTER AS OWNER_CENTER, CC.OWNER_ID AS OWNER_ID, 
	--  CC.FINISHED AS FINISHED, CC.CANCELLED AS CANCELLED, CC.BLOCKED AS BLOCKED, 
		pro.name 																		AS "Product Name",
	--	pg.name 																		AS "Product Category" ,
		pro.globalid 																	AS "Item Code",
		p.center ||'p'||p.id                            								AS "Membership Number" ,
		p.external_id                                   								AS "ExternalID" ,
		p.fullname                                      								AS "Members Name" ,
		c.shortname                                     								AS "Members Home Club" ,
		TO_CHAR(longtodatec(t.entry_time,t.center), 'YYYY-MM-DD')              			AS "Package Purchase Date",
		TO_CHAR(TO_TIMESTAMP(CC.VALID_FROM / 1000) + INTERVAL '1 day', 'YYYY-MM-DD') 	AS "Valid From",
		TO_CHAR(TO_TIMESTAMP(CC.VALID_UNTIL / 1000) + INTERVAL '1 day', 'YYYY-MM-DD') 	AS "Valid Until",
		CC.CLIPS_LEFT 																	AS CLIPS_LEFT
from CLIPCARDS AS CC LEFT 
    join PERSONS AS P ON (P.CENTER = CC.OWNER_CENTER AND P.ID = CC.OWNER_ID) 
    JOIN products pro ON pro.center = cc.center AND pro.id = cc.ID
--	JOIN product_and_product_group_link pgl ON pgl.product_center = pro.center AND pgl.product_id = pro.id
--	JOIN PRODUCT_GROUP pg ON pg.id = pgl.product_group_id
	JOIN centers c ON c.id = p.center
	LEFT JOIN
		(
			SELECT DISTINCT
				center ,
				id ,
				entry_time
            FROM invoices 
		)t
        ON cc.invoiceline_center = t.center AND cc.invoiceline_id = t.id
	JOIN
        params
        ON params.center_id = p.center  
where 
--	P.CENTER between 300 and 399 and
--	P.Country IN ('ID') and
	p.center IN (:Scope) AND
--	P.CENTER not in (300,301,320,315) AND
	CC.FINISHED = 'FALSE' AND
	t.entry_time BETWEEN params.FromDate AND params.ToDate