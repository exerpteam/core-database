SELECT distinct
    a.*,
    abs(trunc(((exerpsysdate()-"Debt Case Start Date")/365)-((exerpsysdate()-a.birthdate)/365))) as "Age at start of debt case"
FROM
    (
        SELECT
            p.CENTER||'p'||p.id AS memberid,
            p.center,
            p.id,
            p.fullname,
            p.birthdate,
            TRUNC((exerpsysdate()-birthdate)/365) age,
            cc.AMOUNT                      AS "Amount in Debt Case",
            cc.STARTDATE "Debt Case Start Date",
            MAX(art.DUE_DATE)          AS "latest due date overdue",
            SUM(art.UNSETTLED_AMOUNT)  AS "Overdue on Payment Account",
            SUM(art2.UNSETTLED_AMOUNT) AS "Overdue on Debt Account"
        FROM
            PERSONS p
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.center
        AND ar.CUSTOMERID = p.id
        AND ar.AR_TYPE = 4
        JOIN
            AR_TRANS art
        ON
            art.center = ar.center
        AND art.id = ar.id
        AND art.DUE_DATE < exerpsysdate()
        AND art.UNSETTLED_AMOUNT !=0
        JOIN
            SATS.CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = p.CENTER
        AND cc.PERSONID = p.id
        AND cc.CLOSED = 0
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar2
        ON
            ar2.CUSTOMERCENTER = p.center
        AND ar2.CUSTOMERID = p.id
        AND ar2.AR_TYPE = 5
        LEFT JOIN
            AR_TRANS art2
        ON
            art2.center = ar2.center
        AND art2.id = ar2.id
        WHERE
            1=1
        AND p.sex != 'C'
        AND p.center IN (:scope)
            --and p.id = 27601
        GROUP BY
            p.CENTER||'p'||p.id ,
            p.center,
            p.id,
            p.fullname,
            p.BIRTHDATE,
            cc.AMOUNT,
            cc.STARTDATE
        ORDER BY
            cc.STARTDATE DESC) a
WHERE
    "Overdue on Payment Account" < -10
    --and a.age  > 18