SELECT distinct
    p1.CURRENT_PERSON_CENTER||'p'||p1.CURRENT_PERSON_ID AS MemberId,
    pr.NAME                                             AS Product,
    emp.FULLNAME                                        AS Employee,
    c.NAME                                              AS "Sale Center"
FROM
    SATS.INVOICES inv
JOIN
    SATS.INVOICELINES il
ON
    il.CENTER = inv.CENTER
    AND il.id = inv.ID
JOIN
    SATS.PRODUCTS pr
ON
    pr.CENTER = il.PRODUCTCENTER
    AND pr.id = il.PRODUCTID
    AND pr.PTYPE = 4
JOIN
    SATS.PRODUCT_GROUP pg
ON
    pg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
JOIN
    SATS.PERSONS p1
ON
    p1.CENTER = inv.PAYER_CENTER
    AND p1.ID = inv.PAYER_ID
JOIN
    SATS.PERSONS emp
ON
    emp.center = inv.EMPLOYEE_CENTER
    AND emp.id = inv.EMPLOYEE_ID
JOIN
    SATS.CENTERS c
ON
    c.id = inv.CENTER
WHERE
    pg.NAME IN ('PT')
    AND inv.TRANS_TIME BETWEEN exerpro.datetolong('2014-10-27 00:00') AND exerpro.datetolong('2014-11-04 23:59')
    AND inv.CENTER IN ($$scope$$)
    AND pr.GLOBALID NOT IN ('PT45START1',
                            'PT45START2')
    AND pr.PRICE !=0
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.INVOICES inv2
        JOIN
            SATS.INVOICELINES il2
        ON
            il2.CENTER = inv2.CENTER
            AND il2.id = inv2.ID
        JOIN
            SATS.PRODUCTS pr2
        ON
            pr2.CENTER = il2.PRODUCTCENTER
            AND pr2.id = il2.PRODUCTID
            AND pr2.PTYPE = 4
        JOIN
            SATS.PRODUCT_GROUP pg2
        ON
            pg2.ID = pr2.PRIMARY_PRODUCT_GROUP_ID
        WHERE
            pg2.NAME IN ('PT')
            AND inv2.TRANS_TIME BETWEEN exerpro.datetolong('2014-04-27 00:00') AND exerpro.datetolong('2014-10-26 23:59')
            AND pr2.GLOBALID NOT IN ('PT45START1',
                                     'PT45START2')
            AND inv2.PAYER_CENTER = inv.PAYER_CENTER
            AND inv2.PAYER_ID = inv.PAYER_ID )