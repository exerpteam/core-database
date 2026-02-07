WITH
    t AS
    (
        SELECT
            p.CENTER || 'p' || p.ID "Member Id" ,
            SUM(ccc.AMOUNT) "Debt amount"
        FROM
            PERSONS p
        JOIN
            CASHCOLLECTIONCASES ccc
        ON
            p.CENTER = ccc.PERSONCENTER
        AND p.ID = ccc.PERSONID
        JOIN
            cashcollectionservices ccs
        ON
            ccc.cashcollectionservice = ccs.id
        JOIN
            centers cen
        ON
            cen.id = ccc.personcenter
        WHERE
            ccc.CLOSED = 0 -- Open Cash collection cases
        AND p.status NOT IN(7,8) --Members not in status Anonymous, deleted
        AND ccc.MISSINGPAYMENT = 1 --  only look at CashCollectionCases
      --  AND cen.country= 'DK' --Scope Denmark
   and  cen.id IN ($$Scope$$)
      
AND ccc.startdate BETWEEN :dateFrom AND :dateTo
        GROUP BY
            p.CENTER || 'p' || p.ID
    )
SELECT
    *
FROM
    t
UNION ALL
SELECT
    'TOTAL',
    SUM("Debt amount")
FROM
    t