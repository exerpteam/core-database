-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     TO_CHAR(to_date($$BookDate$$,'yyyy-mm-dd'), 'YYYY-MM-DD') "Date",
     extId AS "MEASUREID",
         TO_CHAR(SUM(deb+cred) ,'FM99999999999999999990.00') "value",
     ClubId AS "CLUBID"
 FROM
     (
         SELECT
             /* Map in case switch to aggregate GL codes*/
             CASE
                 WHEN acc.EXTERNAL_ID = '101313'
                 THEN '36'
                 WHEN acc.EXTERNAL_ID = '101311'
                 THEN '37'
                 WHEN acc.EXTERNAL_ID = '101310'
                 THEN '39'
                 WHEN acc.EXTERNAL_ID IN ('101300','101302','101301')
                 THEN '40'
                 WHEN acc.EXTERNAL_ID = '101377'
                 THEN '64'
                 WHEN acc.EXTERNAL_ID = '101710'
                 THEN '43'
                 WHEN acc.EXTERNAL_ID = '102200'
                 THEN '44'
                 WHEN acc.EXTERNAL_ID IN ('101720',
                                          '101777',
                                          '101700')
                 THEN '22'
                                 WHEN acc.EXTERNAL_ID = '101312'
                                 THEN '79'
                 WHEN acc.EXTERNAL_ID IN ('101120',
                                          '101105')
                 THEN '9'
                 WHEN acc.EXTERNAL_ID IN ('101177')
                 THEN '10'
                 WHEN acc.EXTERNAL_ID = '101100'
                 THEN '8'
                 WHEN acc.EXTERNAL_ID = '102000'
                 THEN '46'
                 WHEN acc.EXTERNAL_ID = '102003'
                 THEN '47'
                 WHEN acc.EXTERNAL_ID = '102006'
                 THEN '69'
                 WHEN acc.EXTERNAL_ID ='102002'
                 then '68'
                 WHEN acc.EXTERNAL_ID IN ('101809','101806')
                 THEN '63'
                 WHEN acc.EXTERNAL_ID = '102007'
                 THEN '67'
                 WHEN acc.EXTERNAL_ID = '102008'
                 THEN '50'
                 WHEN acc.EXTERNAL_ID = ('101400')
                 THEN '77'
                 WHEN acc.EXTERNAL_ID = '101411'
                 THEN '74'
                 WHEN acc.EXTERNAL_ID = '101413'
                 THEN '72'
                 WHEN acc.EXTERNAL_ID = '101477'
                 THEN '7'
                 WHEN acc.EXTERNAL_ID = '101188'
                 THEN '11'
                 WHEN acc.EXTERNAL_ID ='101410'
                 THEN '73'
                 WHEN acc.EXTERNAL_ID ='101414'
                 THEN '76'
                 WHEN acc.EXTERNAL_ID ='101416'
                 THEN '77'
                 WHEN acc.EXTERNAL_ID = '101417'
                 THEN '75'
                 WHEN acc.EXTERNAL_ID = '101730'
                 THEN '66'
                 WHEN acc.EXTERNAL_ID = '102001'
                 THEN '71'
                 WHEN acc.EXTERNAL_ID = '102004'
                 THEN '70'
                 WHEN acc.EXTERNAL_ID = '102005'
                 THEN '68'
                 WHEN acc.EXTERNAL_ID = '102100'
                 THEN '36'
                                 WHEN acc.EXTERNAL_ID = '101241'
                 THEN '3'
                                 WHEN acc.EXTERNAL_ID = '101240'
                 THEN '4'
                 ELSE 'UNMAPPED'
             END extId,
             club.EXTERNAL_ID club,
             club.ID clubID,
             acc.CENTER,
             acc.ID,
             CASE
                 WHEN acc.center = sums.d_center
                     AND acc.id = sums.d_id
                 THEN -sums.amount
                 ELSE 0
             END deb,
             CASE
                 WHEN acc.center = sums.c_center
                     AND acc.id = sums.c_id
                 THEN sums.amount
                 ELSE 0
             END cred
         FROM
             ACCOUNTS acc
         JOIN
             CENTERS club
         ON
             acc.CENTER = club.ID
         LEFT JOIN
             (
                        SELECT
                                t1.*,
                                debitacc.EXTERNAL_ID dex,
                                creditacc.EXTERNAL_ID cex
                        FROM
                        (
                                SELECT
                                        art.DEBIT_ACCOUNTCENTER d_center,
                                        art.DEBIT_ACCOUNTID d_id, 
                                        --debitacc.EXTERNAL_ID dex,
                                        art.CREDIT_ACCOUNTCENTER c_center,
                                        art.CREDIT_ACCOUNTID c_id,
                                        --creditacc.EXTERNAL_ID cex,
                                        SUM(art.AMOUNT) amount
                                FROM
                                        ACCOUNT_TRANS art
                                WHERE
                                        art.AMOUNT <> 0
                                        AND art.TRANS_TIME >= CAST(extract(epoch FROM timezone('Europe/London',CAST(to_date($$BookDate$$,'yyyy-mm-dd') AS TIMESTAMP))) AS bigint)*1000
                                        AND art.TRANS_TIME < CAST(extract(epoch FROM timezone('Europe/London',CAST(to_date($$BookDate$$,'yyyy-mm-dd') + interval '1 day' AS TIMESTAMP))) AS bigint)*1000 
                                        AND NOT(art.TRANSFERRED = 1 AND art.AGGREGATED_TRANSACTION_CENTER IS NULL)
                                GROUP BY
                                        art.DEBIT_ACCOUNTCENTER,
                                        art.DEBIT_ACCOUNTID, 
                                        --debitacc.EXTERNAL_ID,
                                        art.CREDIT_ACCOUNTCENTER,
                                        art.CREDIT_ACCOUNTID--,
                                        --creditacc.EXTERNAL_ID
                        ) t1
                        JOIN
                                ACCOUNTS debitacc
                                ON debitacc.center = t1.d_center
                                AND debitacc.id = t1.d_id
                        JOIN
                                ACCOUNTS creditacc
                                ON creditacc.center = t1.c_center
                                AND creditacc.id = t1.c_id
                ) sums
         ON
             ( (
                     sums.d_center = acc.CENTER
                     AND sums.d_id = acc.ID)
                 OR (
                     sums.c_center = acc.CENTER
                     AND sums.c_id = acc.ID))
         WHERE
             acc.ATYPE = 3
             AND acc.BLOCKED = 0
         GROUP BY
             acc.EXTERNAL_ID,
             acc.CENTER,
             acc.ID,
             club.EXTERNAL_ID,
             club.id,
             sums.d_center,
             sums.d_id,
             sums.c_center,
             sums.c_id,
             sums.amount) t1
 WHERE
         extId <> 'UNMAPPED'
 GROUP BY
     extId,
     club,
     clubID
 ORDER BY
     extid