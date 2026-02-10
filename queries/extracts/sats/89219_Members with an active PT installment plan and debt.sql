-- The extract is extracted from Exerp on 2026-02-08
-- EC-6916
SELECT distinct on (cc.center,cc.id,cc.subid)
        p.center||'p'||p.id                                                           AS "MemberID",
        pr.name                                                                       AS "PT product",
        TO_CHAR (longtodateTZ (inv.TRANS_TIME, c.time_zone), 'DD-MM-YYYY HH24:MI:SS') AS "PT products sales day",
        cc.clips_left                                                                 AS "Clips left",
        ROUND (cash.AMOUNT, 2)                                                        AS "Debt"
    FROM
        INVOICELINES IL
    JOIN
        PERSONS P ON IL.PERSON_CENTER = P.CENTER AND IL.PERSON_ID = P.ID
    JOIN
        PRODUCTS PR ON PR.CENTER = IL.PRODUCTCENTER AND PR.ID = IL.PRODUCTID AND PR.PTYPE = 4 --4 CLIPCARD
    JOIN
        PRODUCT_AND_PRODUCT_GROUP_LINK PPGL ON PPGL.PRODUCT_CENTER = PR.CENTER AND PPGL.PRODUCT_ID = PR.ID
    JOIN
        PRODUCT_GROUP PG ON PG.ID = PPGL.PRODUCT_GROUP_ID
    JOIN
        INVOICES INV ON INV.CENTER = IL.CENTER AND INV.ID = IL.ID 
    JOIN
        INVOICE_LINES_MT INVL ON INV.CENTER = INVL.CENTER AND INV.ID = INVL.ID
    JOIN
        INSTALLMENT_PLANS IP ON IP.ID = INVL.INSTALLMENT_PLAN_ID
    JOIN
        CLIPCARDS CC ON CC.INVOICELINE_CENTER = IL.CENTER AND CC.INVOICELINE_ID = IL.ID AND CC.INVOICELINE_SUBID = IL.SUBID
    JOIN
        CASHCOLLECTIONCASES CASH ON CASH.PERSONCENTER = P.CENTER AND CASH.PERSONID = P.ID AND CASH.MISSINGPAYMENT = TRUE AND CASH.CLOSED = FALSE
    JOIN
        CENTERS C ON C.ID = IL.PERSON_CENTER
    WHERE
        pg.name ilike 'PT%' ---product group starting with "PT"  
        AND il.person_center IN (:scope)
        AND ip.end_date > CURRENT_DATE