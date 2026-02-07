SELECT
    TO_CHAR(kpidata.FOR_DATE, 'YYYY-MM-DD') "Date",
    kpifield.EXTERNAL_ID measureId,
    ABS(kpidata.VALUE) "Value",
    kpidata.CENTER clubId,
    kpifield.name name,
    kpifield.DISPLAY_TYPE mesaure
FROM
    KPI_FIELDS kpifield
LEFT JOIN
    KPI_DATA kpidata
ON
    kpifield.ID = kpidata.FIELD
WHERE
    kpifield.STATE IN ('DRAFT',
                       'ACTIVE')
	AND kpidata.FOR_DATE >= TO_DATE('31/DEC/2015','dd/mon/yyyy')
    AND kpifield.KEY IN ('MemSalesCountAdults',
                         'MemSalesCountJuniors', 'MemFrozenCountAdults')
ORDER BY
    kpidata.FOR_DATE,
    kpidata.CENTER
