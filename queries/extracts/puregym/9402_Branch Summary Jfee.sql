WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE-1 -$$offset$$,'MM') ,'YYYY-MM-DD HH24:MI'), 'Europe/London')    p_start,
            datetolongTZ(TO_CHAR(SYSDATE -$$offset$$ ,'YYYY-MM-DD') || ' 00:00', 'Europe/London')           AS p_end
        FROM
            dual
    )
SELECT
    /*+ NO_BIND_AWARE */
    NVL(c_name, 'TOTAL')                      AS "Club Name",
    C_STATUS                                  AS "Status",
    "£0 joining fee"                          AS "£0 joining fee",
    TO_CHAR(TRUNC(SYSDATE), 'dd-mm-yyyy')     AS "Date (End of play)",
    COUNT(*)                                  AS "Total",
    TO_CHAR((SUM(price)*100/120)/COUNT(*),'FM99990.00') AS "Average Net Yield £",
    --        sum(case when SCL1_STATEID = 4 and Price = 0 then 1 else 0 end) as "Freeze £0.00",
    sum(Used_cc) as "Use code Jfee 0",
    TO_CHAR(sum(Used_cc)*100/count(*),'FM99990.00') as "% of code Use Jfee 0",
    SUM(DECODE(Price, 0, 1, 0))   AS "Jfee 0",
    SUM(DECODE(Price, 5, 1, 0))   AS "Jfee 5",
    SUM(DECODE(Price, 7.5, 1, 0)) AS "Jfee 7.5",
    SUM(DECODE(Price, 10, 1, 0))  AS "Jfee 10",
    SUM(DECODE(Price, 15, 1, 0))  AS "Jfee 15",
    SUM(DECODE(Price, 20, 1, 0))  AS "Jfee 20",
    SUM(DECODE(Price, 25, 1, 0))  AS "Jfee 25",
    SUM(
        CASE
            WHEN price NOT IN (0,
                               5,
                               7.5,
                               10,15,20,25 )
            THEN 1
            ELSE 0
        END)                                             AS "Other",
    to_number(TO_CHAR(SUM(price)*100/120,'FM9999990'),'9999990') AS "Total Net £"
FROM
    (
        SELECT
            SU.CENTER AS SU_CENTER,
            C.NAME    AS C_NAME,
            CASE
                WHEN c.STARTUPDATE>SYSDATE
                THEN 'Pre-Join'
                ELSE 'Open'
            END                                AS C_STATUS,
            DECODE(pr2.CENTER,NULL,'No','Yes') AS "£0 joining fee",
            il.TOTAL_AMOUNT / il.QUANTITY      AS PRICE,
            decode(pu.CAMPAIGN_CODE_ID,null,0,1) as Used_cc
        FROM
            SUBSCRIPTIONS SU
        CROSS JOIN
            params
        JOIN
            CENTERS c
        ON
            c.id = su.center
        INNER JOIN
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID)
        INNER JOIN
            STATE_CHANGE_LOG SCL1
        ON
            (
                SCL1.CENTER = SU.CENTER
                AND SCL1.ID = SU.ID
                AND SCL1.ENTRY_TYPE = 2 )
        JOIN
            PUREGYM.INVOICELINES il
        ON
            il.CENTER = su.INVOICELINE_CENTER
            AND il.id = su.INVOICELINE_ID
            AND il.SUBID = su.INVOICELINE_SUBID
        LEFT JOIN
            PUREGYM.PRIVILEGE_USAGES pu
        ON
            il.CENTER = pu.TARGET_CENTER
            AND il.ID= pu.TARGET_ID
            AND il.SUBID = pu.TARGET_SUBID
            and il.TOTAL_AMOUNT = 0
            AND pu.TARGET_SERVICE = 'InvoiceLine'
        JOIN
            PUREGYM.PRODUCTS pr
        ON
            pr.CENTER = il.PRODUCTCENTER
            AND pr.id = il.PRODUCTID
            AND pr.PTYPE = 5
        LEFT JOIN
            PUREGYM.PRODUCTS pr2
        ON
            pr2.CENTER = c.id
            AND pr2.GLOBALID = 'FREE_JOINING_LOCAL_ACCESS'
            AND pr2.BLOCKED = 0
        WHERE
            SCL1.STATEID IN (8)
            AND SCL1.ENTRY_START_TIME > params.p_start
            AND SCL1.ENTRY_START_TIME <= params.p_end
            AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
            AND (
                su.START_DATE>=su.END_DATE
                OR su.END_DATE IS NULL)
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    STATE_CHANGE_LOG SCL2
                WHERE
                    SCL2.CENTER = Su.CENTER
                    AND SCL2.ID = Su.ID
                    AND SCL2.ENTRY_TYPE = 2
                    AND scl2.STATEID = 5
                    AND SCL2.ENTRY_START_TIME >= scl1.BOOK_END_TIME
                    AND SCL2.ENTRY_START_TIME <= params.p_end ))
GROUP BY
    grouping sets ( (c_name,C_STATUS,"£0 joining fee"), () )
    --, price
ORDER BY
    NVL(c_name, 'ZZZZZ')
    --,2