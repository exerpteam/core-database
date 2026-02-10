-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    nvl(c_NAME, '_Total')                 AS Center,
    COUNT(DISTINCT SID) AS "Total Sold",
    --sum(case  WHEN "Success by backs 1st" + "Success by backs rep" + "Paid debt online" + "Failed" + "Write-off" =1 then 1 else 0 end) ,
    SUM("Success by backs 1st")                                                                                                                  AS "Success by backs 1st",
    SUM("Success by backs rep")                                                                                                                  AS "Success by backs rep",
    SUM("Paid debt online")                                                                                                                      AS "Paid debt online",
    SUM("Failed")                                                                                                                                AS "Failed",
    SUM("Write-off")                                                                                                                             AS "Write-off",
    COUNT(DISTINCT SID)-(SUM("Success by backs 1st") + SUM("Success by backs rep") + SUM("Paid debt online") + SUM("Failed") + SUM("Write-off")) AS "Unknown",
    TO_CHAR((SUM("Success by backs 1st") + SUM("Success by backs rep") + SUM("Paid debt online"))* 100 / COUNT(SID),'FM999.00')|| ' %'           AS "SUCCEDED PERCENTAGE"
FROM
    (
        SELECT
            c_NAME,
            SID,
            CASE
                WHEN "Write-off" >0
                THEN 1
                ELSE 0
            END AS "Write-off",
            CASE
                WHEN "Paid debt online" > 0
                    AND "Write-off" = 0
                THEN 1
                ELSE 0
            END AS "Paid debt online",
            CASE
                WHEN "Success by backs rep" > 0
                    AND "Paid debt online" = 0
                    AND "Write-off" =0
                THEN 1
                ELSE 0
            END AS "Success by backs rep",
            CASE
                WHEN "Success by backs 1st" >0
                    AND "Success by backs rep" = 0
                    AND "Paid debt online" = 0
                    AND "Write-off" =0
                THEN 1
                ELSE 0
            END AS "Success by backs 1st",
            CASE
                WHEN "Failed">0
                    AND "Success by backs 1st" =0
                    AND "Success by backs rep" = 0
                    AND "Paid debt online" = 0
                    AND "Write-off" =0
                THEN 1
                ELSE 0
            END AS "Failed"
        FROM
            (
                SELECT DISTINCT
                    c.NAME               c_NAME,
                    s.center||'ss'||s.id SID,
                    SUM(
                        CASE
                            WHEN pr.CENTER IS NOT NULL
                                AND pr.REQUEST_TYPE = 1
                            THEN 1
                            ELSE 0
                        END )AS "Success by backs 1st",
                    SUM(
                        CASE
                            WHEN pr.CENTER IS NOT NULL
                                AND pr.REQUEST_TYPE = 6
                            THEN 1
                            ELSE 0
                        END) AS "Success by backs rep",
                    SUM(
                        CASE
                            WHEN ac.GLOBALID = 'BANK_ACCOUNT_WEB_DEBT'
                            THEN 1
                            ELSE 0
                        END) AS "Paid debt online",
                    SUM(
                        CASE
                            WHEN art2.CENTER IS NULL
                            THEN 1
                            ELSE 0
                        END) AS "Failed",
                    SUM(
                        CASE
                            WHEN art2.TEXT LIKE '%Write-off%'
                            THEN 1
                            WHEN art2.TEXT LIKE '%Stop and credit%'
                            THEN 1
                            WHEN art2.TEXT LIKE '%(Stop)%'
                            THEN 1
                            WHEN art2.TEXT LIKE '%(Cancel)%'
                            THEN 1
                            WHEN art2.TEXT LIKE '%FreeCreditnote: Subscription sale API%'
                            THEN 1
                            ELSE 0
                        END) AS "Write-off"
                FROM
                    PUREGYM.SUBSCRIPTIONS s
                JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st
                ON
                    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
                    AND s.SUBSCRIPTIONTYPE_ID = st.id
                    AND st.ST_TYPE = 1
                JOIN
                    PUREGYM.SUBSCRIPTIONPERIODPARTS spp
                ON
                    spp.CENTER = s.CENTER
                    AND spp.id = s.ID
                    AND spp.SUBID = 1
                    /*AND spp.FROM_DATE = s.START_DATE
                    AND spp.SPP_STATE = 1*/
                    --        AND spp.SPP_TYPE = 8
                JOIN
                    PUREGYM.SPP_INVOICELINES_LINK sil
                ON
                    sil.PERIOD_CENTER = spp.CENTER
                    AND sil.PERIOD_ID = spp.ID
                    AND sil.PERIOD_SUBID = spp.SUBID
                JOIN
                    PUREGYM.INVOICELINES il --This is to not have trasactions debiting for add-ons
                ON
                    il.CENTER = sil.INVOICELINE_CENTER
                    AND il.id = sil.INVOICELINE_ID
                    AND il.SUBID = sil.INVOICELINE_SUBID
                JOIN
                    PUREGYM.PRODUCTS pro
                ON
                    pro.CENTER = il.PRODUCTCENTER
                    AND pro.id = il.PRODUCTID
                    AND pro.PTYPE !=13
                JOIN --Account recievable transaction for the invoice
                    PUREGYM.AR_TRANS art
                ON
                    art.REF_TYPE = 'INVOICE'
                    AND art.REF_CENTER = sil.INVOICELINE_CENTER
                    AND art.REF_ID = sil.INVOICELINE_ID
                JOIN
                    PUREGYM.CENTERS c
                ON
                    s.OWNER_CENTER = c.id
                LEFT JOIN
                    PUREGYM.ART_MATCH arm
                ON
                    arm.ART_PAID_CENTER = art.CENTER
                    AND arm.ART_PAID_ID = art.ID
                    AND arm.ART_PAID_SUBID = art.SUBID
                    AND arm.CANCELLED_TIME IS NULL
                LEFT JOIN --Account recievable transaction for the payment
                    PUREGYM.AR_TRANS art2
                ON
                    art2.CENTER = arm.ART_PAYING_CENTER
                    AND art2.ID = arm.ART_PAYING_ID
                    AND art2.SUBID = arm.ART_PAYING_SUBID
                LEFT JOIN --Incase it was paid into account
                    PUREGYM.ACCOUNT_TRANS act
                ON
                    art2.REF_TYPE = 'ACCOUNT_TRANS'
                    AND act.CENTER = art2.REF_CENTER
                    AND act.ID = art2.REF_ID
                    AND act.SUBID = art2.REF_SUBID
                LEFT JOIN
                    PUREGYM.ACCOUNTS ac
                ON
                    ac.CENTER = act.DEBIT_ACCOUNTCENTER
                    AND ac.ID = act.DEBIT_ACCOUNTID
                LEFT JOIN --incase it was paid with BACS
                    PUREGYM.PAYMENT_REQUEST_SPECIFICATIONS prc
                ON
                    prc.CENTER = art2.PAYREQ_SPEC_CENTER
                    AND prc.ID = art2.PAYREQ_SPEC_ID
                    AND prc.SUBID = art2.PAYREQ_SPEC_SUBID
                LEFT JOIN
                    PUREGYM.PAYMENT_REQUESTS pr
                ON
                    pr.INV_COLL_CENTER = prc.CENTER
                    AND pr.INV_COLL_ID = prc.id
                    AND pr.INV_COLL_SUBID = prc.SUBID
                    AND pr.STATE !=8 -- not cancelled
                    AND pr.REQUEST_TYPE IN (1,
                                            6)--only initial or representations.
                    AND pr.xfr_date = longtodateTZ(art2.trans_time, 'Europe/London')
                WHERE
                    s.center IN ($$scope$$)
                    AND s.CREATION_TIME BETWEEN $$start_date$$ AND $$end_date$$
                    AND c.STARTUPDATE <longtodate($$start_date$$)
                    AND s.id !=38714
                    AND s.SUB_STATE NOT IN (8,
                                            3,
                                            6)
                    AND NOT EXISTS--not include subscriptions which are transfers
                    (
                        SELECT
                            1
                        FROM
                            PUREGYM.SUBSCRIPTIONS s2
                        JOIN
                            PUREGYM.PERSONS p2
                        ON
                            p2.CENTER = s2.OWNER_CENTER
                            AND p2.id = s2.OWNER_ID
                        WHERE
                            (
                                s2.TRANSFERRED_CENTER=s.CENTER
                                AND s2.TRANSFERRED_ID = s.id)
                            OR (
                                p2.CURRENT_PERSON_CENTER = s.OWNER_CENTER
                                AND p2.CURRENT_PERSON_ID = s.OWNER_ID
                                AND s2.END_DATE BETWEEN s.START_DATE-2 AND s.START_DATE
                                AND NOT(
                                    s2.CENTER= s.CENTER
                                    AND s2.ID=s.ID) ))
                GROUP BY
                    c.NAME ,
                    s.center,
                    s.id))
GROUP BY
   grouping sets ( ( c_name), () )
   order by 1
    --172ss10001: simplest case paid by first BACS request
    --91ss415: payment by representation
    -- 172ss12706 paid debt online 172p12905
    -- issues: transfers, change of start date,
    -- and not(pr.REQUEST_TYPE in (6,1) or ac.GLOBALID = 'BANK_ACCOUNT_WEB_DEBT' or art2.CENTER IS NULL or art2.TEXT LIKE '%Write-off%')
    --case : sale settled vs money on the account and a PR
    --case : settled vs a credit for a downgraded subscription
    --case : settled vs an 'account transfer' transaction
    --case : 2 debit lines due to an addon-sale
    --case : member payed the payment request but was refunded 1p38466