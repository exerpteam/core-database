-- This is the version from 2026-02-05
-- ST-6808: List of Active members with person type 'Corporate' who do not have an active or future subscription asociated with a company agreement
https://clublead.atlassian.net/browse/ST-7770
SELECT
        sub.personCenter || 'p' || sub.personId AS "Person id",
		c.NAME AS "Centre name",
		sub.FULLNAME AS "Member name",
        comp.FULLNAME AS "Company name",
		sub.caCENTER || 'p' ||sub.caID || 'rpt' || sub.caSUBID AS "Company agreement id",
		sub.caName AS "Company agreement name",
		sub.prName AS "Subscription name",
		sub.SubscriptionId AS "Subscription id",
		sub.SUBSCRIPTION_PRICE AS "Current price",
        sub.START_DATE AS "Start date",
		sub.END_DATE AS "End date"        
FROM
(
        SELECT 
                p.CENTER AS personCenter,
                p.ID AS personId,
				p.FULLNAME,
                ca.CENTER AS caCENTER, 
                ca.ID AS caID, 
                ca.SUBID AS caSUBID, 
                pr.NAME AS prName,
				ca.NAME AS caName,
				pr.GLOBALID,
				s.CENTER || 'ss' || s.ID AS SubscriptionId,
				s.SUBSCRIPTION_PRICE,
				s.START_DATE,
				s.END_DATE
        FROM 
                persons p
        JOIN FW.RELATIVES r
                ON p.CENTER = r.CENTER
                AND p.ID = r.ID
                AND r.RTYPE = 3
                AND r.STATUS = 1
        JOIN FW.COMPANYAGREEMENTS ca
                ON ca.CENTER = r.RELATIVECENTER
                AND ca.ID = r.RELATIVEID
                AND ca.SUBID = r.RELATIVESUBID
        JOIN 
                FW.SUBSCRIPTIONS s
                ON
                        p.CENTER = s.OWNER_CENTER
                        AND p.ID = s.OWNER_ID
                        AND s.STATE IN (2,4)
        JOIN 
                FW.SUBSCRIPTIONTYPES st 
                ON 
                        st.CENTER = s.SUBSCRIPTIONTYPE_CENTER 
                        AND st.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN FW.PRODUCTS pr
                ON
                        st.CENTER = pr.CENTER
                        AND st.ID = pr.ID
        WHERE 
                p.STATUS in (1,3)
                AND p.PERSONTYPE = 4
				AND p.CENTER IN (:Scope)
) sub
JOIN
	CENTERS c ON c.ID = sub.personCenter
JOIN
	PERSONS comp ON comp.CENTER = sub.caCENTER AND comp.ID = sub.caID
WHERE
        (sub.caCENTER,sub.caID,sub.caSUBID, sub.GLOBALID) NOT IN 
(
        SELECT
                DISTINCT
                priv.CENTER,
                priv.ID,
                priv.SUBID,
                priv.NEWGLOBALID
        FROM
        (
                SELECT
                        DISTINCT 
                        t1.CENTER,
                        t1.ID,
                        t1.SUBID,
                        pp.REF_TYPE,
                        --ps2.name AS Name2
                        --pp.REF_GLOBALID,
                        (CASE
                                WHEN pp.REF_GLOBALID LIKE 'PRORATA_%' THEN replace(pp.REF_GLOBALID,'PRORATA_','')
                                WHEN pp.REF_GLOBALID LIKE 'CREATION_%' THEN replace(pp.REF_GLOBALID,'CREATION_','')
                                ELSE pp.REF_GLOBALID
                        END) NEWGLOBALID,
                        (CASE
                                WHEN ps.NAME IS NULL THEN 'EMPTY'
                                WHEN pp.REF_TYPE = 'PRODUCT_GROUP' THEN 'EXCLUDE'
                                WHEN pp.REF_TYPE = 'GLOBAL_PRODUCT' THEN 'INCLUDE'
                                ELSE 'UNKNOWN'
                        END) filterColumn
                FROM
                ( 
                        SELECT 
                                DISTINCT
                                         ca.CENTER,
                                         ca.ID,
                                         ca.SUBID,
                                         ca.NAME
                        FROM 
                                persons p
                        JOIN FW.RELATIVES r
                                ON p.CENTER = r.CENTER
                                AND p.ID = r.ID
                                AND r.RTYPE = 3
                                AND r.STATUS = 1
                        JOIN FW.COMPANYAGREEMENTS ca
                                ON ca.CENTER = r.RELATIVECENTER
                                AND ca.ID = r.RELATIVEID
                        WHERE 
                                p.STATUS in (1,3)
                                and p.PERSONTYPE = 4
                ) t1
                LEFT JOIN PRIVILEGE_GRANTS pg
                        ON pg.GRANTER_CENTER = t1.CENTER
                        AND pg.GRANTER_ID = t1.ID
                        AND pg.GRANTER_SUBID = t1.SUBID
                        AND pg.VALID_FROM < exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                        AND 
                        (
                                pg.VALID_TO >=exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                                OR  pg.VALID_TO IS NULL
                        )
                        AND pg.GRANTER_SERVICE = 'CompanyAgreement'
                LEFT JOIN PRIVILEGE_SETS ps 
                        ON pg.PRIVILEGE_SET = ps.ID
                LEFT JOIN FW.PRODUCT_PRIVILEGES pp ON pp.PRIVILEGE_SET = ps.ID	
                UNION ALL
                SELECT
                        DISTINCT 
                        t1.CENTER,
                        t1.ID,
                        t1.SUBID,
                        pp.REF_TYPE,
                        --pp.REF_GLOBALID,
                        (CASE
                                WHEN pp.REF_GLOBALID LIKE 'PRORATA_%' THEN replace(pp.REF_GLOBALID,'PRORATA_','')
                                WHEN pp.REF_GLOBALID LIKE 'CREATION_%' THEN replace(pp.REF_GLOBALID,'CREATION_','')
                                ELSE pp.REF_GLOBALID
                        END) NEWGLOBALID,
                        (CASE
                                WHEN ps2.NAME IS NULL THEN 'EMPTY'
                                WHEN pp.REF_TYPE = 'PRODUCT_GROUP' THEN 'EXCLUDE'
                                WHEN pp.REF_TYPE = 'GLOBAL_PRODUCT' THEN 'INCLUDE'
                                ELSE 'UNKNOWN'
                        END) filterColumn
                FROM
                (
                        SELECT 
                                DISTINCT
                                         ca.CENTER,
                                         ca.ID,
                                         ca.SUBID,
                                         ca.NAME
                        FROM 
                                persons p
                        JOIN FW.RELATIVES r
                                ON p.CENTER = r.CENTER
                                AND p.ID = r.ID
                                AND r.RTYPE = 3
                                AND r.STATUS = 1
                        JOIN FW.COMPANYAGREEMENTS ca
                                ON ca.CENTER = r.RELATIVECENTER
                                AND ca.ID = r.RELATIVEID
                        WHERE 
                                p.STATUS in (1,3)
                                and p.PERSONTYPE = 4
                ) t1
                LEFT JOIN PRIVILEGE_GRANTS pg
                        ON pg.GRANTER_CENTER = t1.CENTER
                        AND pg.GRANTER_ID = t1.ID
                        AND pg.GRANTER_SUBID = t1.SUBID
                        AND pg.VALID_FROM < exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                        AND 
                        (
                                pg.VALID_TO >=exerpro.dateToLong(TO_CHAR(SYSDATE+1, 'YYYY-MM-dd HH24:MI'))
                                OR  pg.VALID_TO IS NULL
                        )
                        AND pg.GRANTER_SERVICE = 'CompanyAgreement'
                LEFT JOIN PRIVILEGE_SETS ps 
                        ON pg.PRIVILEGE_SET = ps.ID
                LEFT JOIN FW.PRIVILEGE_SET_INCLUDES psi ON ps.ID = psi.PARENT_ID
                LEFT JOIN FW.PRIVILEGE_SETS ps2 ON ps2.ID = psi.CHILD_ID
                LEFT JOIN FW.PRODUCT_PRIVILEGES pp ON pp.PRIVILEGE_SET = ps2.ID
        ) priv
        WHERE
                priv.filterColumn = 'INCLUDE'
) 
ORDER BY sub.GLOBALID
