WITH 
        v_main AS
        (
                SELECT
                        p.CENTER || 'p' || p.ID AS CompanyId,
                        ca.CENTER AS caCENTER,
                        ca.ID AS caID,
                        ca.SUBID AS caSUBID,
                        ca.NAME AS caName,
                        ps.NAME AS psName
                FROM 
                        PERSONS p 
                JOIN COMPANYAGREEMENTS ca ON ca.CENTER = p.CENTER AND ca.ID = p.ID AND ca.STATE NOT IN (3,6)
                LEFT JOIN PRIVILEGE_GRANTS pg
                        ON pg.GRANTER_CENTER = ca.CENTER
                        AND pg.GRANTER_ID = ca.ID
                        AND pg.GRANTER_SUBID = ca.SUBID
                        AND pg.VALID_FROM < exerpro.dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
                        AND 
                        (
                                pg.VALID_TO >=exerpro.dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
                                OR  pg.VALID_TO IS NULL
                        )
                        AND pg.GRANTER_SERVICE = 'CompanyAgreement'
                LEFT JOIN PRIVILEGE_SETS ps 
                        ON pg.PRIVILEGE_SET = ps.ID
                WHERE
                        p.SEX = 'C'
                        AND p.status IN (0,1,2,3,6,9)
                        AND p.CENTER IN (:scope)
                ORDER BY 
                        ca.CENTER || 'p' || ca.ID || 'rpt' || ca.SUBID
        )
        ,
        v_pivot AS
        (
                SELECT
                        v_main.*,
                        LEAD(psName,1) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege2 ,
                        LEAD(psName,2) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege3 ,
                        LEAD(psName,3) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege4 ,
                        LEAD(psName,4) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege5 ,
                        LEAD(psName,5) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege6 ,
                        LEAD(psName,6) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege7 ,
                        LEAD(psName,7) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege8 ,
                        LEAD(psName,8) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege9 ,
                        LEAD(psName,9) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege10 ,
                        LEAD(psName,10) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege11 ,
                        LEAD(psName,11) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege12 ,
                        LEAD(psName,12) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege13 ,
                        LEAD(psName,13) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege14 ,
                        LEAD(psName,14) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege15 ,
                        LEAD(psName,15) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege16 ,
                        LEAD(psName,16) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege17 ,
                        LEAD(psName,17) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege18 ,
                        LEAD(psName,18) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege19 ,
                        LEAD(psName,19) OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID)     AS Privilege20 ,
                        ROW_NUMBER() OVER (PARTITION BY COMPANYID, caCENTER, caID, caSUBID, caName ORDER BY COMPANYID) AS ADDONSEQ
                FROM
                        v_main
        ),
        v_compagr AS
        (
                SELECT
                        v_pivot.COMPANYID,
                        v_pivot.caCENTER,
                        v_pivot.caID,
                        v_pivot.caSUBID,
                        --v_pivot.caCENTER || 'p' || v_pivot.caID || 'rpt' || v_pivot.caSUBID AS "CompanyAgreementId",
                        v_pivot.caName,
                        v_pivot.psName,
                        v_pivot.Privilege2,
                        v_pivot.Privilege3,
                        v_pivot.Privilege4,
                        v_pivot.Privilege5,
                        v_pivot.Privilege6,
                        v_pivot.Privilege7,
                        v_pivot.Privilege8,
                        v_pivot.Privilege9,
                        v_pivot.Privilege10,
                        v_pivot.Privilege11,
                        v_pivot.Privilege12,
                        v_pivot.Privilege13,
                        v_pivot.Privilege14,
                        v_pivot.Privilege15,
                        v_pivot.Privilege16,
                        v_pivot.Privilege17,
                        v_pivot.Privilege18,
                        v_pivot.Privilege19,
                        v_pivot.Privilege20
                FROM 
                        v_pivot
                WHERE
                        ADDONSEQ=1
        )
        SELECT
                v_compagr.COMPANYID AS "CompanyId",
                v_compagr.caCENTER || 'p' || v_compagr.caID || 'rpt' || v_compagr.caSUBID AS "CompanyAgreementId",
                v_compagr.caName AS "CompanyAgreementName",
                v_compagr.psName AS "Privilege1",
                v_compagr.Privilege2 AS "Privilege2",
                v_compagr.Privilege3 AS "Privilege3",
                v_compagr.Privilege4 AS "Privilege4",
                v_compagr.Privilege5 AS "Privilege5",
                v_compagr.Privilege6 AS "Privilege6",
                v_compagr.Privilege7 AS "Privilege7",
                v_compagr.Privilege8 AS "Privilege8",
                v_compagr.Privilege9 AS "Privilege9",
                v_compagr.Privilege10 AS "Privilege10",
                v_compagr.Privilege11 AS "Privilege11",
                v_compagr.Privilege12 AS "Privilege12",
                v_compagr.Privilege13 AS "Privilege13",
                v_compagr.Privilege14 AS "Privilege14",
                v_compagr.Privilege15 AS "Privilege15",
                v_compagr.Privilege16 AS "Privilege16",
                v_compagr.Privilege17 AS "Privilege17",
                v_compagr.Privilege18 AS "Privilege18",
                v_compagr.Privilege19 AS "Privilege19",
                v_compagr.Privilege20 AS "Privilege20"
        FROM v_compagr
        JOIN
                (
                        SELECT
                                DISTINCT 
                                        r.RELATIVECENTER,
                                        r.RELATIVEID,
                                        r.RELATIVESUBID
                        FROM PERSONS p
                        JOIN SATS.RELATIVES r ON p.CENTER = r.CENTER AND p.ID = r.ID AND r.RTYPE = 3 AND r.STATUS = 1
                        WHERE 
                                p.PERSONTYPE = 4
                                AND p.STATUS NOT IN (4,5,7,8)
                                AND 
                                (
                                        r.EXPIREDATE IS NULL
                                        OR
                                        r.EXPIREDATE >= TRUNC(exerpsysdate())
                                )
                                AND r.RELATIVECENTER IN (:scope)
                ) actMem
        ON (actMem.RELATIVECENTER = v_compagr.caCENTER AND actMem.RELATIVEID = v_compagr.caID AND actMem.RELATIVESUBID = v_compagr.caSUBID) 