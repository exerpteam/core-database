-- The extract is extracted from Exerp on 2026-02-08
-- Extract PT Balance
-- #198412 - Fix the product name after person transferred due to closd club
WITH 
	Used_Clips AS (
    SELECT c1.card_center, c1.card_id, c1.card_subid, sum(c1.used_clips) as used_clips
    FROM (        
	SELECT ccu.card_center,	ccu.card_id, ccu.card_subid, COALESCE(SUM(ccu.clips),0) AS used_clips
    FROM card_clip_usages ccu
    JOIN
        evolutionwellness.privilege_usages pu
        ON pu.source_center = ccu.card_center
        AND pu.source_id = ccu.card_id
        AND pu.source_subid = ccu.card_subid
        AND pu.id = ccu.ref
	AND (pu.State = 'USED' OR pu.State = 'CANCELLED' and pu.misuse_state = 'PUNISHED')
    WHERE
        ccu.state != 'CANCELLED'  
        AND (cast(longToDateC(pu.use_time, ccu.card_center)AS Date) <= cast(:Report_Date AS Date)
	--	 OR pu.use_time is NULL)
	OR cast(longToDateC(pu.cancel_time, ccu.card_center)AS Date) <= cast(:Report_Date AS Date))
	AND ccu.card_center IN (:Scope)
	AND ccu.Type IN ('PRIVILEGE', 'SANCTION')
    GROUP BY
        ccu.card_center,
	ccu.card_id,
	ccu.card_subid
UNION ALL
    SELECT DISTINCT
        ccu2.card_center,
	ccu2.card_id,
	ccu2.card_subid,
   	COALESCE(SUM(ccu2.clips),0) AS used_clips
    FROM
        card_clip_usages ccu2
    WHERE 
	ccu2.state != 'CANCELLED'  
	AND ccu2.card_center IN (:Scope)
	AND ccu2.Type IN ('ADJUSTMENT', 'TRANSFER_TO','TRANSFER_FROM', 'BUYOUT')
	AND cast(longToDateC(ccu2.time, ccu2.card_center) as date) <= cast(:Report_Date AS Date)
    GROUP BY
        ccu2.card_center,
	ccu2.card_id,
	ccu2.card_subid
) AS c1
    GROUP BY
        c1.card_center,
	c1.card_id,
	c1.card_subid),

   PTG AS
        (                 
        SELECT 
                p.center
                ,p.id
                ,cavPTG.value    --PT Grade
        FROM 
                evolutionwellness.persons p   
        JOIN
                evolutionwellness.custom_attributes PTG
                ON PTG.ref_id = p.id
                AND PTG.ref_center_id = p.center
                AND PTG.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacPTG
                ON cacPTG.id = PTG.custom_attribute_config_id
                AND cacPTG.external_id = 'PTG' 
        JOIN
                evolutionwellness.custom_attribute_config_values cavPTG
                ON cavPTG.id = PTG.custom_attribute_config_value_id
        )

SELECT DISTINCT
        p.center ||'p'|| p.id AS PersonId,
	p.external_id AS ExternalId,
	p.fullname AS "Member Name",
        (Select name from Centers where id = cc.center) AS "Clipcard Center",
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
        c.name AS "Member Home Center",
        pr.globalid AS ClipcardGlobalId,
	pr.id AS ItemCode,
	pg.NAME as "Product Group",
--	uc.source_center,
--	uc.source_id,
--	uc.source_subid,
        pr.name as Clipcard_Name,
	longtodatec(t.entry_time,t.center) AS "Purchase Date" ,
	cc.invoiceline_center||'inv'||cc.invoiceline_id AS "Receipt Number" ,
	cc.subid,
        il.total_amount AS "Gross Amount",
	il.net_amount AS "Net Amount",
        il.total_amount/NULLIF(cc.clips_initial,0) as "Gross Price per session",
	il.net_amount/NULLIF(cc.clips_initial,0) as "Net Price per session",
        cc.clips_initial AS "Initial Clips",
	longToDateC(cc.valid_from, cc.center) AS "Start Date",
        longToDateC(cc.valid_until, cc.center) AS "Expiry Date",
	uc.used_clips AS "Used Clips",     
	CASE
		WHEN uc.used_clips ISNULL THEN cc.clips_initial
		ELSE (cc.clips_initial + uc.used_clips)
		END AS "Clips Left",
--	(cc.clips_initial + uc.used_priv_clips + uc2.used_adj_clips)*pgr.usage_quantity AS "Clips Left (Hours)",
	CASE
		WHEN uc.used_clips IS NULL THEN il.total_amount
		ELSE (cc.clips_initial + uc.used_clips)*(il.total_amount/cc.clips_initial)
		END AS "Gross Revenue Balance",
	CASE
		WHEN uc.used_clips ISNULL THEN il.net_amount
		ELSE (cc.clips_initial + uc.used_clips)*(il.net_amount/cc.clips_initial)
		END AS "Net Revenue Balance",
	trid.new_value AS "Assigned Trainer Emp_ID",
	PTG.value AS "Assigned Trainer Grading",
	tr.fullname AS "Assigned_Trainer",
	(Select name from centers where id = tr.center) AS "Assigned Trainer Home Center",
	pclpe.new_value AS "Selling EmployeeID",
	pe.fullname AS "Selling Staff Name",
	pec.shortname AS "Selling Club",
	pclsp.new_value AS "Sold on behalf ID",
        empsp.fullname AS "Sold on behalf Name" ,
        empspc.shortname AS "Sold on behalf Club"
FROM evolutionwellness.persons p
JOIN evolutionwellness.clipcards cc ON p.center = cc.owner_center AND p.id = cc.owner_id
LEFT JOIN Used_clips uc 
	 ON cc.center = uc.card_center 
        AND cc.id = uc.card_id 
        AND cc.subid = uc.card_subid
JOIN evolutionwellness.invoice_lines_mt il ON cc.invoiceline_center = il.center AND cc.invoiceline_id = il.id AND cc.invoiceline_subid = il.subid
JOIN evolutionwellness.products pr ON cc.center = pr.center AND cc.id = pr.id AND pr.PTYPE = 4
JOIN PRODUCT_GROUP pg ON pg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
--JOIN MASTERPRODUCTREGISTER mpr ON mpr.GLOBALID = pr.GLOBALID AND mpr.scope_type != 'T'
--LEFT JOIN PRIVILEGE_GRANTS pgr ON pgr.GRANTER_ID = mpr.ID AND pgr.granter_service = 'GlobalCard' AND pgr.valid_to IS NULL 
JOIN evolutionwellness.centers c ON c.id = p.center
LEFT JOIN (SELECT DISTINCT center, id, entry_time FROM invoices )t
        ON cc.invoiceline_center = t.center AND cc.invoiceline_id = t.id
--
-- Get Assigned to
LEFT JOIN persons tr ON tr.center = cc.assigned_staff_center
        AND tr.id = cc.assigned_staff_id
--LEFT JOIN person_change_logs trid
--        ON trid.person_center = tr.center
--        AND trid.person_id = tr.id
--        AND trid.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId' 
LEFT JOIN LATERAL(SELECT person_change_logs.new_value, person_change_logs.person_center, person_change_logs.person_id
     FROM person_change_logs
       WHERE person_change_logs.person_center = tr.center
        AND person_change_logs.person_id = tr.id
        AND person_change_logs.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'  
     ORDER BY longtodatec(person_change_logs.entry_time, tr.center) DESC
	 LIMIT 1
    ) trid ON trid.person_center = tr.center
        AND trid.person_id = tr.id
LEFT JOIN PTG 
	ON ptg.center = tr.center
	AND ptg.id = tr.id 
--
-- Get Sold on behalf of person
LEFT JOIN invoice_lines_mt inv
        ON cc.invoiceline_center = inv.center
        AND cc.invoiceline_id = inv.id
        AND cc.invoiceline_subid = inv.subid
LEFT JOIN evolutionwellness.invoice_sales_employee invs
        ON invs.invoice_center = inv.center AND invs.invoice_id = inv.id AND invs.stop_time is NULL
LEFT JOIN evolutionwellness.employees emps
        ON emps.center = invs.sales_employee_center AND emps.id = invs.sales_employee_id
LEFT JOIN evolutionwellness.persons empsp
        ON empsp.center = emps.personcenter
        AND empsp.id = emps.personid
--LEFT JOIN person_change_logs pclsp
--        ON pclsp.person_center = empsp.center
--        AND pclsp.person_id = empsp.id
--        AND pclsp.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId' 
LEFT JOIN LATERAL(SELECT person_change_logs.new_value, person_change_logs.person_center, person_change_logs.person_id
     FROM person_change_logs
       WHERE person_change_logs.person_center = empsp.center
        AND person_change_logs.person_id = empsp.id
        AND person_change_logs.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'  
     ORDER BY longtodatec(person_change_logs.entry_time, empsp.center) DESC
	 LIMIT 1
    ) pclsp ON pclsp.person_center = empsp.center
        AND pclsp.person_id = empsp.id
LEFT JOIN evolutionwellness.centers empspc
        ON empspc.id = empsp.center
-- Get Selling person
LEFT JOIN invoices i
        ON inv.center = i.center
        AND inv.id = i.id
LEFT JOIN employees emp
        ON emp.CENTER = i.employee_center
        AND emp.ID = i.employee_id
LEFT JOIN persons pe
        ON pe.CENTER = emp.PERSONCENTER
        AND pe.ID = emp.PERSONID
--LEFT JOIN person_change_logs pclpe
--        ON pclpe.person_center = pe.center
--        AND pclpe.person_id = pe.id
--        AND pclpe.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId' 
LEFT JOIN LATERAL(SELECT person_change_logs.new_value, person_change_logs.person_center, person_change_logs.person_id
     FROM person_change_logs
       WHERE person_change_logs.person_center = pe.center
        AND person_change_logs.person_id = pe.id
        AND person_change_logs.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'  
     ORDER BY longtodatec(person_change_logs.entry_time, pe.center) DESC
	 LIMIT 1
    ) pclpe ON pclpe.person_center = pe.center
        AND pclpe.person_id = pe.id        
LEFT JOIN centers pec
        ON pec.id = pe.center
WHERE
        p.center IN (:Scope)
	AND p.status NOT IN (4,5,7,8)
--	AND cc.clips_left <> 0
	AND cc.Cancelled is FALSE
	AND (cc.clips_initial + uc.used_clips <> 0 OR uc.used_clips is NULL)
	AND CAST(longToDateC(cc.Valid_Until, cc.center) as Date) > cast(:Report_Date AS Date)
	AND CAST(longToDateC(cc.Valid_From, cc.center) as Date) <= cast(:Report_Date AS Date)
--	AND p.external_id = '90490411'