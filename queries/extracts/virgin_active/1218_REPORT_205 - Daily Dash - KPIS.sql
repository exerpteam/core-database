 SELECT
     TO_CHAR(kpidata.FOR_DATE, 'YYYY-MM-DD') "Date",
     kpifield.EXTERNAL_ID AS "MEASUREID",
     ABS(kpidata.VALUE) "Value",
     kpidata.CENTER AS "CLUBID"--,
     --kpifield.name name,
     --kpifield.DISPLAY_TYPE mesaure
 FROM
     KPI_FIELDS kpifield
 LEFT JOIN
     KPI_DATA kpidata
 ON
     kpifield.ID = kpidata.FIELD
 WHERE
     kpifield.STATE IN ('DRAFT',
                        'ACTIVE')
     AND kpidata.FOR_DATE = $$ForDate$$
     /*AND kpidata.CENTER IN (401,402,414,415,429,451,436,439,440,444,446,406,417,418,447,450,408,422,425,430,452,419,421,424,431,448,409,404,423,428,434,437)*/
     AND kpifield.KEY IN ('MemSalesCountAdults',
                          'MemSalesCountJuniors', 'MemFrozenCountAdults')
 ORDER BY
     kpidata.FOR_DATE,
     kpidata.CENTER
