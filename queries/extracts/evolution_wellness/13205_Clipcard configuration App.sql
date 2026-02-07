WITH countryselected AS
(
	SELECT :countrySelected AS cs
)
SELECT
        t2.id,
        t2.scope_name,
        t2.globalid,
        t2.product_name,
        t2.product_price,
        t2.state,
        t2.use_contract_template,
        t2.template_name,
        t2.sales_commission,
        t2.sales_units, 
        t2.period_commission,
        t2.commissionable,
        t2.privilegedNeeded,
        t2.clipCount,
        sg.name AS staffGroupName
FROM
(
        SELECT
                t1.*,
                (CASE
                        WHEN t1.tempAssignedStaffGroupId = 'null' THEN NULL
                        ELSE CAST(t1.tempAssignedStaffGroupId AS INT)
                END) assignedstaffgroupid
        FROM
        (
                WITH pmp_xml AS 
                (
                        SELECT 
                                m.id, 
                                CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml 
                        FROM masterproductregister m 
                        WHERE
                                m.state NOT IN ('DELETED','INACTIVE')
                                AND m.cached_producttype = 4
                ) 
                SELECT
                        mpr.id,
                        (CASE 
                                WHEN mpr.scope_type = 'T' THEN 'System'
                                WHEN mpr.scope_type = 'A' THEN a.name
                                WHEN mpr.scope_type = 'C' THEN c.name
                                ELSE NULL
                        END) AS scope_name,
                        mpr.scope_type,
                        mpr.scope_id,
                        c.country,
                        mpr.globalid,
                        mpr.cached_productname AS product_name,
                        mpr.cached_productprice AS product_price,
                        mpr.state,
                        mpr.use_contract_template,
                        te.description AS template_name,
                        mpr.sales_commission,
                        mpr.sales_units, 
                        mpr.period_commission,
                        mpr.commissionable,
                        UNNEST(xpath('//clipcardType/product/assignedStaffGroup/text()',px.pxml))::text AS tempAssignedStaffGroupId,
                        UNNEST(xpath('//clipcardType/product/privilegeNeeded/text()',px.pxml))::text AS privilegedNeeded,
                        UNNEST(xpath('//clipcardType/clipCount/text()',px.pxml))::text AS clipCount
                FROM pmp_xml px
                JOIN masterproductregister mpr ON mpr.id = px.id
                LEFT JOIN evolutionwellness.areas a ON a.id = mpr.scope_id AND mpr.scope_type = 'A'
                LEFT JOIN evolutionwellness.centers c ON c.id = mpr.scope_id AND mpr.scope_type = 'C' 
                LEFT JOIN evolutionwellness.templates te ON te.id = mpr.contract_template_id
        ) t1
) t2
CROSS JOIN countryselected csel
LEFT JOIN evolutionwellness.staff_groups sg ON sg.id = t2.assignedstaffgroupid

WHERE
        ('ID' = csel.cs AND (t2.scope_type = 'T' OR (t2.scope_type = 'A' AND t2.scope_id IN (1,4,15,19,22,23,34)) OR (t2.scope_type = 'C' AND t2.country = 'ID')))
        OR
        ('PH' = csel.cs  AND (t2.scope_type = 'T' OR (t2.scope_type = 'A' AND t2.scope_id IN (1,18,24,25,40)) OR (t2.scope_type = 'C' AND t2.country = 'PH')))
        OR
        ('SG' = csel.cs AND (t2.scope_type = 'T' OR (t2.scope_type = 'A' AND t2.scope_id IN (1,2,8,9,14)) OR (t2.scope_type = 'C' AND t2.country = 'SG')))
        OR
        ('MY' = csel.cs AND (t2.scope_type = 'T' OR (t2.scope_type = 'A' AND t2.scope_id IN (1,7,13,17,32,33)) OR (t2.scope_type = 'C' AND t2.country = 'MY')))
        OR
        ('TH' = csel.cs AND (t2.scope_type = 'T' OR (t2.scope_type = 'A' AND t2.scope_id IN (1,6,21,27,28,29,37,38)) OR (t2.scope_type = 'C' AND t2.country = 'TH')))
