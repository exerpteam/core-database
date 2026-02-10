-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TO_CHAR(kpidata.FOR_DATE, 'YYYY-MM-DD') "Date",
    kpifield.EXTERNAL_ID measureId,
    kpifield.DISPLAY_TYPE mesaure,
	kpifield.name name,
    kpidata.CENTER clubId,
    c.SHORTNAME,
    c.NAME,
	ABS(kpidata.VALUE) "Value"

FROM
    KPI_FIELDS kpifield
LEFT JOIN
    KPI_DATA kpidata
ON
    kpifield.ID = kpidata.FIELD
LEFT JOIN
	CENTERS c
ON 
	kpidata.CENTER = c.ID
WHERE
    kpifield.STATE IN ('DRAFT',
                       'ACTIVE')
    AND kpidata.FOR_DATE >= $$FromDate$$  
    AND kpidata.FOR_DATE <= $$ToDate$$
	AND c.ID IN ($$Scope$$)

    --AND kpifield.KEY IN ('MemSalesCountAdults','MemSalesCountJuniors','MemFrozenCountAdults')
ORDER BY
    kpidata.FOR_DATE,
    kpidata.CENTER