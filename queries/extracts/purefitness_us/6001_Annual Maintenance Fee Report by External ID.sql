WITH
    PARAMS AS
    (
        SELECT
	    /*+ materialize */
            CAST (dateToLongC(TO_CHAR(CAST($$fromDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)    AS FromDate,
            CAST (dateToLongC(TO_CHAR(CAST($$ToDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)      AS ToDate,
            c.id AS CENTER_ID
        FROM
            centers c
      )
SELECT
    TO_CHAR(longtodateC(i.entry_time, i.center),'DD/MM/YYYY HH24:MI')                   AS "Sale Date",
    p.external_id                                                                       AS "External ID",
    to_char(il.total_amount,'99.99')                                                    AS "Amount",
    i.center                                                                            AS "Center ID",
    c.shortname                                                                         AS "Center name",
    il.person_center||'p'||il.person_id                                                 AS "Person ID",
    pd.name                                                                             AS "Subscription",
    CASE earliest_sub.stateid WHEN  2 THEN 'Active'
                     WHEN  3 THEN 'Ended'
                     WHEN  4 THEN 'Frozen'
                     WHEN  7 THEN 'Window'
                     WHEN  8 THEN 'Created'
                     ELSE 'Undefined'
    END                                                                                 AS "Subscription state",
    TO_CHAR(longtodateC(LAG(i.entry_time,1) OVER (partition by il.person_center, il.person_id order by i.entry_time), i.center),'DD/MM/YYYY HH24:MI')                   AS "Last sale",
    TO_CHAR(longtodateC(i.entry_time, i.center) + interval '12 month','DD/MM/YYYY')     AS "Next sale",
    TO_CHAR(longtodateC(member_start.start_time,i.center),'DD/MM/YYYY')     AS "Member Start Date"
FROM
    params
JOIN    
    invoices i
ON
    i.center = params.center_id
JOIN
    invoice_lines_mt il
ON
    i.center = il.center
    AND i.id = il.id
JOIN
    products pr
ON
    il.productcenter = pr.center
    AND il.productid = pr.id
    AND pr.globalid = 'ANNUAL_MAINTENANCE_FEE'
JOIN
    persons p
ON
    p.CENTER = il.person_center
    AND p.ID = il.person_id
JOIN
    centers c
ON
    i.center = c.id
JOIN
   (
    SELECT 
		row_number() over (partition BY s.OWNER_CENTER, s.OWNER_ID ORDER BY s.start_date) as firstone,
		s.SUBSCRIPTIONTYPE_CENTER,
		s.SUBSCRIPTIONTYPE_ID,
		s.OWNER_CENTER, 
		s.OWNER_ID,
		scl.stateid
    FROM
		subscriptions s
	JOIN
		SUBSCRIPTIONTYPES st
	ON
		st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
		AND st.id = s.SUBSCRIPTIONTYPE_ID
		AND st.ST_TYPE = 1  
		AND st.IS_ADDON_SUBSCRIPTION = 0  
	JOIN
		state_change_log scl
	ON
		scl.center = s.center
		AND scl.id = s.id
		AND scl.entry_type = 2
		AND scl.stateid = 2
	) earliest_sub
	ON
	earliest_sub.OWNER_CENTER = p.center
	AND earliest_sub.OWNER_ID = p.ID
	AND earliest_sub.firstone = 1
LEFT JOIN
   (
    SELECT 
	scl.CENTER, 
	scl.ID,
	min(scl.entry_start_time) as start_time
    FROM
	state_change_log scl
    WHERE 
        scl.entry_type = 1 
        and scl.stateid = 1
    GROUP BY
        scl.center, scl.id
   ) member_start
ON
   member_start.CENTER = p.center
   AND member_start.ID = p.ID
JOIN
    products pd
ON
    pd.center = earliest_sub.SUBSCRIPTIONTYPE_CENTER
    AND pd.id = earliest_sub.SUBSCRIPTIONTYPE_ID
WHERE 
   i.trans_time >= params.FROMDATE
   AND i.trans_time < params.TODATE + 24*3600*1000
   AND (p.external_id) IN ($$ExternalID$$)
   AND i.center in ($$Centers$$)
   AND NOT EXISTS (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl WHERE pl.product_center = pd.center AND pl.product_id = pd.id AND pl.product_group_id IN (11,1023)) --Add-ons AND Temp Access
