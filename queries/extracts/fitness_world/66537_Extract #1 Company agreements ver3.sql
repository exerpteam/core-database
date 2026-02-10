-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        sub.CENTER as "Company center",
        sub.ID AS "Company Id",
        sub.CENTER ||'p'|| sub.ID ||'rpt'|| sub.SUBID AS "AgreementId",
        sub.company AS "Company",
        sub.agreement AS "Agreement",
        longtodate(sub.companystartdate) AS "CompanyStartDate",
        sub.STOP_NEW_DATE "Agreement_Signup_EndDate",
        sub.GLOBALID AS "GlobalId",   
        sub.Price AS "Price",
        sub.Sponsortype AS "SponsorType",
    CASE
        WHEN joining.PRICE  = 0
        THEN 'YES'
        ELSE 'NO'
    END as "Is startup fee free?"
FROM
(
        SELECT
                t2.center,
                t2.id,
                t2.subid,
                t2.company,
                t2.agreement,
                t2.companystartdate,
                t2.STOP_NEW_DATE,
                t2.GLOBALID,
                t2.Price,
                t2.Sponsortype,
                t2.GLOBALID AS MAIN_SUB
        FROM
        (
                SELECT
                        t1.*,
                        rank() OVER (PARTITION BY t1.center, t1.id, t1.subid, t1.company,t1.agreement,t1.companystartdate,t1.STOP_NEW_DATE,t1.GLOBALID  ORDER BY t1.Price) ranking
                FROM
                (
                        SELECT DISTINCT
                            ca.center,
                            ca.id,
                            ca.subid,
                            c.fullname                                 AS company ,
                            ca.name                                    AS agreement,
                            scl.ENTRY_START_TIME          AS companystartdate,
                            ca.STOP_NEW_DATE                           AS STOP_NEW_DATE,
                            p.GLOBALID,
                            p.pTYPE,
                            --PS.NAME,
                            CASE
                                WHEN ppr.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                                THEN ppr.PRICE_MODIFICATION_AMOUNT
                                ELSE p.PRICE
                            END                 AS Price,
                            pg.SPONSORSHIP_NAME AS Sponsortype
                        FROM
                            COMPANYAGREEMENTS ca
                            /* company */
                        JOIN
                            PERSONS c
                        ON
                            ca.CENTER = c.CENTER
                        AND ca.ID = c.ID
                        JOIN
                            PRIVILEGE_GRANTS pg
                        ON
                            pg.GRANTER_CENTER = ca.CENTER
                        AND pg.GRANTER_ID = ca.ID
                        AND pg.GRANTER_SUBID = ca.SUBID
                        AND pg.GRANTER_SERVICE = 'CompanyAgreement'
                        AND pg.valid_to IS NULL
                        Left JOIN
                            PRIVILEGE_SET_INCLUDES psi
                        ON
                            pg.PRIVILEGE_SET = psi.PARENT_ID
                        AND psi.VALID_TO IS NULL
                        JOIN
                            PRIVILEGE_SETS ps
                        ON
                            psi.PARENT_ID = ps.id
                        OR  psi.CHILD_ID = ps.id
                        or pg.PRIVILEGE_SET = ps.id  
                        JOIN
                            PRODUCT_PRIVILEGES ppr
                        ON
                            ppr.PRIVILEGE_SET = ps.id
                        AND ppr.VALID_TO IS NULL
                         LEFT JOIN
            MASTER_PROD_AND_PROD_GRP_LINK mpl
        ON
            mpl.PRODUCT_GROUP_ID = ppr.ref_id
                        left join
                        MASTERPRODUCTREGISTER mpr
                        on
                       mpl.MASTER_PRODUCT_ID = mpr.id
                        
                        JOIN
                            PRODUCTS p
                        ON
                            (ppr.REF_GLOBALID = p.GLOBALID or
                             mpr.globalid = p.globalid)
                         AND p.pTYPE IN (10,13)
                        
                        JOIN
                            STATE_CHANGE_LOG scl
                        ON
                            scl.center = c.center
                        AND scl.id = c.id
                        AND ENTRY_TYPE = 3
                        WHERE
                            ca.center IN (:scope)
                 and ca.state != 6
                ) t1
        ) t2
        WHERE 
                t2.ranking = 1
) sub
LEFT JOIN
(
        SELECT
                t2.center,
                t2.id,
                t2.subid,
                t2.company,
                t2.agreement,
                t2.companystartdate,
                t2.STOP_NEW_DATE,
                t2.GLOBALID,
                t2.Price,
                t2.Sponsortype,
                (CASE 
                        WHEN t2.GLOBALID LIKE 'CREATION%' THEN substr(t2.GLOBALID,10)
                        ELSE t2.GLOBALID
                END) AS MAIN_SUB
        FROM
        (
                SELECT
                        t1.*,
                        rank() OVER (PARTITION BY t1.center, t1.id, t1.subid, t1.company,t1.agreement,t1.companystartdate,t1.STOP_NEW_DATE,t1.GLOBALID  ORDER BY t1.Price) ranking
                FROM
                (
                        SELECT DISTINCT
                            ca.center,
                            ca.id,
                            ca.subid,
                            c.fullname                                 AS company ,
                            ca.name                                    AS agreement,
                            scl.ENTRY_START_TIME          AS companystartdate,
                            ca.STOP_NEW_DATE                           AS STOP_NEW_DATE,
                            p.GLOBALID,
                            p.pTYPE,
                            --PS.NAME,
                            CASE
                                WHEN ppr.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                                THEN ppr.PRICE_MODIFICATION_AMOUNT
                                ELSE p.PRICE
                            END                 AS Price,
                            pg.SPONSORSHIP_NAME AS Sponsortype
                        FROM
                            COMPANYAGREEMENTS ca
                            /* company */
                        JOIN
                            PERSONS c
                        ON
                            ca.CENTER = c.CENTER
                        AND ca.ID = c.ID
                        JOIN
                            PRIVILEGE_GRANTS pg
                        ON
                            pg.GRANTER_CENTER = ca.CENTER
                        AND pg.GRANTER_ID = ca.ID
                        AND pg.GRANTER_SUBID = ca.SUBID
                        AND pg.GRANTER_SERVICE = 'CompanyAgreement'
                        AND pg.valid_to IS NULL
                        Left JOIN
                            PRIVILEGE_SET_INCLUDES psi
                        ON
                            pg.PRIVILEGE_SET = psi.PARENT_ID
                        AND psi.VALID_TO IS NULL
                        JOIN
                            PRIVILEGE_SETS ps
                        ON
                            psi.PARENT_ID = ps.id
                        OR  psi.CHILD_ID = ps.id
                        or pg.PRIVILEGE_SET = ps.id  
                        JOIN
                            PRODUCT_PRIVILEGES ppr
                        ON
                            ppr.PRIVILEGE_SET = ps.id
                        AND ppr.VALID_TO IS NULL
                        JOIN
                            FW.PRODUCTS p
                        ON
                            ppr.REF_GLOBALID = p.GLOBALID
                            AND p.pTYPE IN (5)
                        JOIN
                            STATE_CHANGE_LOG scl
                        ON
                            scl.center = c.center
                        AND scl.id = c.id
                        AND ENTRY_TYPE = 3
                        WHERE ca.center IN (:scope)
                       and ca.state != 6
                ) t1
        ) t2
        WHERE 
                t2.ranking = 1
) joining ON sub.CENTER = joining.CENTER AND sub.ID = joining.ID AND sub.SUBID = joining.SUBID AND sub.COMPANY = joining.COMPANY AND sub.AGREEMENT = joining.AGREEMENT AND sub.MAIN_SUB = joining.MAIN_SUB