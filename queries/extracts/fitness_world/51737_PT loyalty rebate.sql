-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6334
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(ADD_MONTHS(TRUNC(exerpsysdate()), -12), 'YYYY-MM-dd HH24:MI'), 'Europe/Copenhagen') AS StartDateLong
        FROM
            dual
    )
SELECT
    *
FROM
    (
        SELECT
            curp.center,
            curp.id,
            COUNT(*) AS total_session,
            SUM(
                CASE
                    WHEN pu.TARGET_START_TIME >= params.StartDateLong
                    THEN 1
                    ELSE 0
                END) total_12_months
        FROM
            persons curp
        CROSS JOIN
            params
        JOIN
            persons allp
        ON
            allp.current_person_center = curp.center
            AND allp.current_person_id = curp.id
        JOIN
            CLIPCARDS cc
        ON
            cc.owner_center = allp.center
            AND cc.owner_id = allp.id
        JOIN
            CARD_CLIP_USAGES ccu
        ON
            cc.CENTER = ccu.CARD_CENTER
            AND cc.ID = ccu.CARD_ID
            AND cc.SUBID = ccu.CARD_SUBID
        JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.ID = ccu.REF
        WHERE
            curp.center IN ($$Scope$$)
            AND ccu.state = 'ACTIVE'
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    invoice_lines_mt invl,
                    PRODUCTS prod,
                    PRODUCT_AND_PRODUCT_GROUP_LINK plink,
                    PRODUCT_GROUP pg
                WHERE
                    invl.CENTER = cc.INVOICELINE_CENTER
                    AND invl.ID = cc.INVOICELINE_ID
                    AND invl.SUBID = cc.INVOICELINE_SUBID
                    AND prod.CENTER = invl.PRODUCTCENTER
                    AND prod.ID = invl.PRODUCTID
                    AND plink.PRODUCT_CENTER = prod.CENTER
                    AND plink.PRODUCT_ID = prod.ID
                    AND pg.ID = plink.PRODUCT_GROUP_ID
                    AND pg.NAME IN( 'PT Packages (afbetaling)' ,
                                   'PT Packages (kontant)',
                                   'PT Packages (10%)',
                                   'PT Get Started (afbetaling)',
                                   'PT Get Started (kontant)',
                                   'Personlig træning (mdlskb. + klippekort)'))
        GROUP BY
            curp.center,
            curp.id
        HAVING
            COUNT(*) >=$$no_session$$ )
WHERE
    total_12_months >= 12