-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-1637
SELECT 
        t1.center AS CENTER,
        t1.id AS ID,
        t1.p_center AS P_CENTER,
        t1.p_id AS P_ID,
        t1.ar_center AS AR_CENTER,
        t1.ar_id AS AR_ID,
        t1.MemberID AS PERSONKEY,
        t1.FirstName AS FIRSTNAME,
        t1.LastName AS LASTNAME,
        t1.GLOBALID,
        t1.persontype,
        --t1.Subcription_Periods,
        t1.Net_Subcription_Periods,
        t1.OtherPayer
FROM
(
        SELECT
                (CASE
                        WHEN r.CENTER IS NOT NULL THEN r.CENTER
                        ELSE p.CENTER
                END) AS p_center,
                (CASE
                        WHEN r.ID IS NOT NULL THEN r.ID
                        ELSE p.ID
                END) AS p_id,
                p.center,
                p.id,
                p.FIRSTNAME,
                p.LASTNAME,
                pr.GLOBALID,
                sum(round((sp.TO_DATE-sp.FROM_DATE+1)/30)) AS Net_Subcription_Periods,
                ar.center AS AR_CENTER,
                ar.id AS AR_ID,
                p.CENTER || 'p' || p.ID AS MemberID,
                p.persontype,
                CASE WHEN r.center IS NULL THEN NULL
                        ELSE 'YES' 
                END AS OtherPayer
        FROM
                PERSONS p 
        JOIN  
                ACCOUNT_RECEIVABLES ar
                        ON ar.CUSTOMERCENTER = p.CENTER AND ar.CUSTOMERID = p.ID AND ar.AR_TYPE = 4
        JOIN
                SUBSCRIPTIONS s
                        ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID
        JOIN
                SUBSCRIPTIONTYPES st
                        ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID AND st.ST_TYPE = 1 -- EFT
        JOIN
                PRODUCTS pr
                        ON st.center = pr.center AND st.ID = pr.ID
        LEFT JOIN
                RELATIVES r
                        ON r.RTYPE = 12 AND r.STATUS = 1 AND r.RELATIVECENTER = p.center AND r.RELATIVEID = p.id
        JOIN
                CENTERS c
                        ON s.CENTER = c.ID
        JOIN  
                SUBSCRIPTIONPERIODPARTS sp
                        ON s.CENTER = sp.CENTER
                           AND s.ID = sp.ID  
                           AND sp.CANCELLATION_TIME = 0
                           AND sp.SPP_TYPE IN (1,3,8)
                           AND sp.TO_DATE-sp.FROM_DATE+1 > 15
                           AND sp.TO_DATE <= current_timestamp
        WHERE   
                c.COUNTRY = 'NO'  -- Norway
                AND c.ID in (:center)
                -- AND p.STATUS = 1  --only active
                AND p.STATUS NOT IN (4,5,7,8)
                AND pr.PTYPE = 10 -- Subscriptions
                AND s.STATE = 2 -- Active
                AND s.START_DATE >= to_date('2015-01-01','YYYY-MM-DD')
                AND (s.END_DATE is null OR s.END_DATE > add_months((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date,1))  --exclude if subscription ends next month
                AND pr.GLOBALID in ('EFT_12_M','EFT_24_M','EFT_12_M_FITNESS_BATH','EFT_9_M','EFT_4_M_NEW','EFT_12M_SWIMMING','EFT_12_M_SWIMMING',
                        'EFT_12_M_SWIMMING_2','EFT_12_M_REGIONAL','WEB_EFT_12_M_LOCAL','WEB_EFT_4_M','WEB_24_EFT_M','WEB_EFT_12_M','WEB_EFT_4_MONTHS')
        GROUP BY 
                p.center, 
                p.id, 
                p.firstname, 
                p.lastname, 
                pr.GLOBALID, 
                ar.center, 
                ar.id, 
                r.CENTER,
                r.id,
                p.persontype
        HAVING mod(sum(round((sp.TO_DATE-sp.FROM_DATE+1)/30))::INT,12) = 0        
) t1
WHERE 
        (
                (t1.GLOBALID IN ('EFT_24_M','WEB_24_EFT_M') AND t1.Net_Subcription_Periods >= 24)
                OR 
                (t1.GLOBALID NOT IN ('EFT_24_M','WEB_24_EFT_M') AND t1.Net_Subcription_Periods >= 12)
         )
        -- exclude if s/he has already paid an admin fee within last 12 months 
        AND NOT EXISTS 
        (SELECT 1
         FROM
                AR_TRANS art
         JOIN
                INVOICE_LINES_MT il
                ON
                        art.REF_CENTER =  il.CENTER
                        AND art.REF_ID = il.ID
                        AND art.REF_TYPE = 'INVOICE'
        JOIN
                PRODUCTS pr
                ON
                        il.PRODUCTCENTER = pr.center
                        AND il.PRODUCTID = pr.ID   
                        AND pr.globalid = 'ADMIN_FEE'  
        WHERE
                art.CENTER = t1.AR_CENTER
                AND art.ID = t1.AR_ID
                AND il.PERSON_CENTER = t1.p_Center
                AND il.PERSON_ID = t1.p_id
                AND longtodate(art.ENTRY_TIME) > add_months(current_timestamp,-12)
        )
        -- exclude if s/he has a company aggrement with full sponsorship
        AND NOT EXISTS
        (
        SELECT 1
        FROM
                PRIVILEGE_CACHE pc
        JOIN
                PRIVILEGE_GRANTS pg
                ON 
                        pg.id = pc.GRANT_ID
        JOIN 
                PRODUCT_PRIVILEGES pp
                ON
                pp.id = pc.PRIVILEGE_ID
         WHERE 
                     person_center = t1.center 
                     and person_id = t1.id
                     and pg.GRANTER_SERVICE = 'CompanyAgreement'
                     and (pc.VALID_TO is null  OR longtodate(pc.VALID_TO) > current_timestamp) 
                     and UPPER(pg.SPONSORSHIP_NAME) = 'FULL' 
        )
