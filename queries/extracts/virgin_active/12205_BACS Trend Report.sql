-- The extract is extracted from Exerp on 2026-02-08
--  
 with params as (
        select cast(:date_month as date) AS DATE_P
 )
 ,
 monthly_vals AS
 (
         SELECT
                  pr.CENTER AS ClubId,
                 DATE_TRUNC('month',pr.REQ_DATE) AS MonthVal,
                 SUM(pr.REQ_AMOUNT)         tot,
                 COUNT(1)                   vol,
                 MAX(pr.REQ_AMOUNT)         mx,
                 MIN(pr.REQ_AMOUNT)         mn
         FROM
                 PAYMENT_REQUESTS pr
         CROSS JOIN
                 PARAMS
         WHERE
                 pr.REQUEST_TYPE IN (:pr_type)
                 AND pr.REQ_DELIVERY IS NOT NULL
                 AND pr.CLEARINGHOUSE_ID IN (1,201,401,601)
                 AND pr.CENTER IN ($$scope$$)
                 AND pr.REQ_DATE >= DATE_TRUNC('month',PARAMS.DATE_P) - interval '2 months'
                 GROUP BY
                         pr.CENTER,
                         DATE_TRUNC('month',pr.REQ_DATE)
 )
 ,
 table1 as (
         SELECT
                 monthly_vals.ClubId AS ClubId,
                 c.EXTERNAL_ID AS ClubCode,
                 c.SHORTNAME AS ClubName,
                 SUM((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) - interval '2 months' THEN monthly_vals.tot ELSE 0 END)) AS Month2,
                 SUM((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) - interval '1 months' THEN monthly_vals.tot ELSE 0 END)) AS Month1,
                 SUM((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) THEN monthly_vals.tot ELSE 0 END)) AS CurrentMonth,
                 SUM((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) - interval '2 months' THEN monthly_vals.vol ELSE 0 END)) AS Month2Volume,
                 SUM((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) - interval '1 months' THEN monthly_vals.vol ELSE 0 END)) AS Month1Volume,
                 SUM((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) THEN monthly_vals.vol ELSE 0 END)) AS CurrentMonthVolume,
                 MAX((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) THEN monthly_vals.mx ELSE NULL END)) AS CurrentMonthMax,
                 MIN((CASE monthly_vals.MonthVal WHEN DATE_TRUNC('month',PARAMS.DATE_P) THEN monthly_vals.mn ELSE NULL END)) AS CurrentMonthMin
         FROM
                 monthly_vals
         CROSS JOIN
                 PARAMS
         JOIN
                 CENTERS c
         ON
                 monthly_vals.ClubId = c.ID
         GROUP BY grouping sets ( (monthly_vals.clubid, c.EXTERNAL_ID, c.SHORTNAME), () )
 )
 ,
 table2 as (
         SELECT
                 table1.ClubId AS ClubId_T1,
                 table1.ClubCode AS ClubCode_T1,
                 table1.ClubName AS ClubName_T1,
                 table1.Month2 AS Month2_T1,
                 table1.Month1 AS Month1_T1,
                 table1.CurrentMonth AS CurrentMonth_T1,
                 (CASE WHEN table1.Month1=0
                         THEN
                                 0
                         ELSE
                                 TRUNC(((table1.Month1-table1.Month2)/table1.Month1)*100,4)
                 END) AS MvmtM2toM1_T1,
                 (CASE WHEN table1.CurrentMonth=0
                         THEN
                                 0
                         ELSE
                                 TRUNC(((table1.CurrentMonth-table1.Month1)/table1.CurrentMonth)*100,4)
                 END) AS MvmtM1toCurrent_T1,
                 table1.Month2Volume AS Month2volumeofDDs_T1,
                 table1.Month1Volume AS Month1volumeofDDs_T1,
                 table1.CurrentMonthVolume AS CurrentMonthvolumeofDDs_T1,
                 (CASE WHEN table1.Month2Volume=0
                         THEN
                                 0
                         ELSE
                                 table1.Month2/table1.Month2Volume
                 END) AS AvgDDMonth2_T1,
                 (CASE WHEN table1.Month1Volume=0
                         THEN
                                 0
                         ELSE
                                 table1.Month1/table1.Month1Volume
                 END) AS AvgDDMonth1_T1,
                 (CASE WHEN table1.CurrentMonthVolume=0
                         THEN
                                 0
                         ELSE
                                 table1.CurrentMonth/table1.CurrentMonthVolume
                 END) AS AvgDDCurrentMonth_T1,
                 (CASE WHEN table1.Month1Volume=0
                         THEN
                                 0
                         ELSE
                                 TRUNC(((table1.Month1Volume-table1.Month2Volume)/table1.Month1Volume)*100,4)
                 END) AS MvmtM2toM1Vol_T1,
                 (CASE WHEN table1.CurrentMonthVolume=0
                         THEN
                                 0
                         ELSE
                                 TRUNC(((table1.CurrentMonthVolume-table1.Month1Volume)/table1.CurrentMonthVolume)*100,4)
                 END) AS MvmtM1toCurrentVol_T1,
                 table1.CurrentMonthMax AS CurrentMonthMax_T1,
                 table1.CurrentMonthMin AS CurrentMonthMin_T1
         FROM table1
         ORDER BY 1
 )
 SELECT
         table2.ClubId_T1 AS "Club ID",
         table2.ClubCode_T1 AS "Club Code",
         table2.ClubName_T1 AS "Club Name",
         table2.Month2_T1 AS "Month-2 Value £",
         table2.Month1_T1 AS "Month-1 Value £",
         table2.CurrentMonth_T1 AS "Current Month Value £",
         TO_CHAR(table2.MvmtM2toM1_T1,'FM999990.00') ||'%' AS "Mvmt % M-2 to M-1",
         TO_CHAR(table2.MvmtM1toCurrent_T1,'FM999990.00') ||'%' AS "Mvmt % M-1 to Current",
         table2.Month2volumeofDDs_T1 AS "Month-2 volume of DDs",
         table2.Month1volumeofDDs_T1 AS "Month-1 volume of DDs",
         table2.CurrentMonthvolumeofDDs_T1 AS "Current Month volume of DDs",
         TO_CHAR(table2.MvmtM2toM1Vol_T1,'FM999990.00') ||'%' AS "Mvmt % M-2 to M-1",
         TO_CHAR(table2.MvmtM1toCurrentVol_T1,'FM999990.00') ||'%' AS "Mvmt % M-1 to Current",
         TO_CHAR(table2.AvgDDMonth2_T1,'FM999990.00') AS "Avg DD Month-2",
         TO_CHAR(table2.AvgDDMonth1_T1,'FM999990.00') AS "Avg DD Month-1",
         TO_CHAR(table2.AvgDDCurrentMonth_T1,'FM999990.00') AS "Avg DD Current Month",
         TO_CHAR(table2.MvmtM2toM1_T1-MvmtM2toM1Vol_T1,'FM999990.00') ||'%' AS "Avg DD Mvmt % M-2 to M-1",
         TO_CHAR(table2.MvmtM1toCurrent_T1-MvmtM1toCurrentVol_T1,'FM999990.00') ||'%' AS "Avg DD Mvmt % M-1 to Current",
         table2.CurrentMonthMin_T1 AS "Min DD" ,
         table2.CurrentMonthMax_T1 AS "Max DD"
 FROM table2
 ORDER BY 1
