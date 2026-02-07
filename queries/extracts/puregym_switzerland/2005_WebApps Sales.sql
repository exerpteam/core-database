WITH PARAMS AS MATERIALIZED
(
	SELECT
		to_date(:fromdate,'YYYY-MM-DD') as fromdate,
		to_date(:todate,'YYYY-MM-DD') as todate,
		c.id
	FROM CENTERS c
	WHERE c.id IN (:Scope)
)
SELECT
        emp.fullname AS employee,
        ss.sales_date,
        longtodatec(s.creation_time, s.center) AS creation_datetime,
        p.center || 'p' || p.id AS memberid,
        p.fullname,
        pr.name,
        st.periodcount,
        (CASE spp.spp_type 
                WHEN 1 THEN 'NORMAL' 
                WHEN 2 THEN 'UNCONDITIONAL FREEZE' 
                WHEN 3 THEN 'FREE DAYS' 
                WHEN 7 THEN 'CONDITIONAL FREEZE' 
                WHEN 8 THEN 'INITIAL PERIOD' 
                WHEN 9 THEN 'PRORATA PERIOD' 
                ELSE 'Undefined' 
        END) AS spp_type,
        spp.from_date,
        spp.to_date,
        pr2.globalid AS invoiced_product,
        il.total_amount,
        spp.to_date-spp.from_date+1 AS InvoicedDays
FROM puregym_switzerland.subscription_sales ss
JOIN params par ON par.id = ss.subscription_center
JOIN puregym_switzerland.subscriptions s ON ss.subscription_center = s.center AND ss.subscription_id = s.id
JOIN puregym_switzerland.employees e ON ss.employee_center = e.center AND ss.employee_id = e.id
JOIN puregym_switzerland.persons emp ON e.personcenter = emp.center AND e.personid = emp.id
JOIN puregym_switzerland.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
JOIN puregym_switzerland.products pr ON st.center = pr.center AND st.id = pr.id
JOIN puregym_switzerland.persons p ON s.owner_center = p.center AND s.owner_id = p.id
JOIN puregym_switzerland.subscriptionperiodparts spp ON spp.center = s.center AND spp.id = s.id
JOIN puregym_switzerland.spp_invoicelines_link sppl ON spp.center = sppl.period_center AND spp.id = sppl.period_id AND spp.subid = sppl.period_subid
JOIN puregym_switzerland.invoice_lines_mt il ON sppl.invoiceline_center = il.center AND sppl.invoiceline_id = il.id AND sppl.invoiceline_subid = il.subid
JOIN puregym_switzerland.products pr2 ON il.productcenter = pr2.center AND il.productid = pr2.id
WHERE
        ss.sales_date >= par.fromdate
AND ss.sales_date <= par.todate
        AND 
        e.center = 100
        AND e.id = 415
        AND spp.spp_type IN (8)  
ORDER BY 
        2,4