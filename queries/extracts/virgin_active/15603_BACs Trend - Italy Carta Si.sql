-- The extract is extracted from Exerp on 2026-02-08
--  
 with params as (
         select CAST($$date_month$$ AS DATE) as DATE_P 
 )
 SELECT
     table2.ClubId                      AS "Club ID",
     table2.ClubCode                    AS "Club Code",
     table2.ClubName                    AS "Club Name",
     table2.Month2                      AS "Month-2 Value £",
     table2.Month1                      AS "Month-1 Value £",
     table2.CurrentMonth                AS "Current Month Value £",
     to_char(table2.MmvtM2toM1,'FM9990.00') ||'%'            AS "Mvmt % M-2 to M-1",
     to_char(table2.MmvtM1toCurrent,'FM9990.00') ||'%'       AS "Mvmt % M-1 to Current",
     table2.Month2Volume                AS "Month-2 volume of DDs",
     table2.Month1Volume                AS "Month-1 volume of DDs",
     table2.CurrentMonthVolume          AS "Current Month volume of DDs",
     to_char(table2.MmvtM2toM1Volume,'FM9990.00') ||'%'      AS "Mvmt % M-2 to M-1",
     to_char(table2.MmvtM1toCurrentVolume,'FM9990.00') ||'%' AS "Mvmt % M-1 to Current",
     to_char(table2.MmvtM2toM1-table2.MmvtM2toM1Volume,'FM9990.00') ||'%' AS "Avg DD Mvmt % M-2 to M-1",
     to_char(table2.MmvtM1toCurrent-table2.MmvtM1toCurrentVolume,'FM9990.00') ||'%' AS "Avg DD Mvmt % M-1 to Current"
 FROM
     (
         SELECT
             c.ID                                             AS ClubId,
             c.EXTERNAL_ID                                    AS ClubCode,
             c.SHORTNAME                                      AS ClubName,
             table1.Month2                                    AS Month2,
             table1.Month1                                    AS Month1,
             table1.CurrentMonth                              AS CurrentMonth,
             (CASE WHEN table1.Month1=0
             THEN
                 0
             ELSE
                 TRUNC(((table1.Month1-table1.Month2)/table1.Month1)*100,3)
             END) AS MmvtM2toM1,
             (CASE WHEN table1.CurrentMonth=0
             THEN
                 0
             ELSE
                 TRUNC(((table1.CurrentMonth-table1.Month1)/table1.CurrentMonth)*100,3)
             END) AS MmvtM1toCurrent,
             table1.Month2Volume                                               AS Month2Volume,
             table1.Month1Volume                                               AS Month1Volume,
             table1.CurrentMonthVolume                                    AS CurrentMonthVolume,
             (CASE WHEN table1.Month1Volume=0
             THEN
                 0
             ELSE
                 TRUNC(((table1.Month1Volume-table1.Month2Volume)/table1.Month1Volume)*100,3)
             END) AS MmvtM2toM1Volume,
             (CASE WHEN table1.CurrentMonthVolume=0
             THEN
                 0
             ELSE
                 TRUNC(((table1.CurrentMonthVolume-table1.Month1Volume)/table1.CurrentMonthVolume)*100,3)
             END) AS MmvtM1toCurrentVolume
         FROM
             CENTERS c
         JOIN
             (
                 SELECT
                     pr.CENTER AS clubId,
                     SUM(CASE TRUNC(pr.REQ_DATE,'MM') WHEN ADD_MONTHS(TRUNC(PARAMS.DATE_P, 'MM'),-2) THEN 
                     pr.REQ_AMOUNT ELSE 0 END ) AS Month2,
                     SUM(CASE TRUNC(pr.REQ_DATE,'MM') WHEN ADD_MONTHS(TRUNC(PARAMS.DATE_P, 'MM'),-1) THEN 
                     pr.REQ_AMOUNT ELSE 0 END )                                                    AS Month1,
                     SUM(CASE TRUNC(pr.REQ_DATE,'MM') WHEN TRUNC(PARAMS.DATE_P, 'MM') THEN pr.REQ_AMOUNT ELSE 0 END) AS
                     CurrentMonth,
                     SUM(CASE TRUNC(pr.REQ_DATE,'MM') WHEN ADD_MONTHS(TRUNC(PARAMS.DATE_P, 'MM'),-2) THEN 1 ELSE 0 END) AS
                     Month2Volume,
                     SUM(CASE TRUNC(pr.REQ_DATE,'MM') WHEN ADD_MONTHS(TRUNC(PARAMS.DATE_P, 'MM'),-1) THEN 1 ELSE 0 END) AS
                     Month1Volume,
                     SUM(CASE TRUNC(pr.REQ_DATE,'MM') WHEN TRUNC(PARAMS.DATE_P, 'MM') THEN 1 ELSE 0 END) AS
                     CurrentMonthVolume
                 FROM
                     PAYMENT_REQUESTS pr
                     CROSS JOIN PARAMS
                 WHERE
                     pr.REQUEST_TYPE IN ($$pr_type$$)
                 AND pr.REQ_DELIVERY IS NOT NULL
                 AND pr.CLEARINGHOUSE_ID IN (803,2801,2802,2803,2804,3601)
                 AND pr.CENTER IN ($$scope$$)
                 AND pr.REQ_DATE >= ADD_MONTHS(TRUNC(PARAMS.DATE_P, 'MM'),-2)
                 GROUP BY
                     pr.CENTER) table1
         ON
             table1.clubId = c.ID) table2
 order by 3
