SELECT
    t1.SHORTNAME,
    t1.SALES_DATE,
    t1.pcenter||'p'||t1.pid PERSONID,
    t1.subId,
    t1.Fullname,
    t1.subscription,
    t1.productGroup,
    t1.saleType,
    t1.extended_From,
    t1."ended sub",
    t1.created,
    t1.apiGamma,
    t1.START_DATE,
    t1.STOP_DATE,
    t1.BINDING_DATE,
    t1.MEMBER_STATUS,
    t1.SUB_STATUS,
    t1.SUB_SUB_STATE,
    sales.Fullname SALES_PERSON,
    t1.AF AS AF,
    t1.SUB_CURRENT_PRICE,
    CASE
        WHEN a.TXTVALUE IN ('Y',
                            'N/A')
        AND b.TXTVALUE IN ('Y',
                           'N/A')
        AND c.TXTVALUE IN ('Y',
                           'N/A')
        AND d.TXTVALUE IN ('Y',
                           'N/A')
        AND e.TXTVALUE IN ('Y',
                           'N/A')
        AND f.TXTVALUE IN ('Y',
                           'N/A')
        AND g.TXTVALUE IN ('Y',
                           'N/A')
        AND h.TXTVALUE IN ('Y',
                           'N/A')
        THEN 'Y'
        ELSE 'N'
    END COMMISSIONABLE,
    mycomp.FULLNAME COMPANY_RELATION,
    ca.Name AS COMPANY_AGREEMENT,
    t1.CAMPAIGN_CODE,
    sc.NAME AS FREE_MONTH_CODE,
    t2.ADD_ON
FROM 
(
SELECT
    cen.SHORTNAME,
    TO_CHAR(SS.SALES_DATE,'DD.MM.YYYY')  AS SALES_DATE,
    p.CENTER pcenter,
    p.ID pid,
    SS.SUBSCRIPTION_CENTER || 'ss' || SS.SUBSCRIPTION_ID subId,
    SS.SUBSCRIPTION_CENTER,
    SS.SUBSCRIPTION_ID,
    p.FULLNAME,
    pr.NAME  subscription,
    prg.NAME productGroup,
    CASE
        WHEN MAX(ex_pg.EXCLUDE_FROM_MEMBER_COUNT) = 1
        AND ss.TYPE = 2 -- extended and FROM COMP
        AND type4.CURRENT_PERSON_CENTER IS NULL
        THEN 1
        ELSE SS.TYPE
    END                                      AS saleType,
    ex_pr.name                               AS extended_From,
    type4.name                               AS "ended sub",
    TO_CHAR(longtodateC(SU.CREATION_TIME, SU.CENTER),'DD.MM.YYYY') AS created,
    CASE
        WHEN ss.EMPLOYEE_CENTER = 100
        AND ss.EMPLOYEE_ID = 3202
        THEN 1
        ELSE 0
    END                                       AS apiGamma,
    il.TOTAL_AMOUNT                           AS AF,
    NVL(camps.CODE, cc_startup.CODE)             AS CAMPAIGN_CODE,
    TO_CHAR(su.START_DATE,'DD.MM.YYYY')       AS START_DATE,
    TO_CHAR(su.END_DATE,'DD.MM.YYYY')         AS STOP_DATE,
    TO_CHAR(su.BINDING_END_DATE,'DD.MM.YYYY') AS BINDING_DATE,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,
         'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS  MEMBER_STATUS,
    DECODE (su.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS  SUB_STATUS,
    DECODE (su.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5, 
        'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED',10,'CHANGED','UNKNOWN') AS  SUB_SUB_STATE,
    su.SUBSCRIPTION_PRICE AS SUB_CURRENT_PRICE,
    su.STARTUP_FREE_PERIOD_ID    
FROM
    SUBSCRIPTION_SALES SS
JOIN
    SUBSCRIPTIONS SU
ON
    SUBSCRIPTION_CENTER = SU.CENTER
    AND SUBSCRIPTION_ID = SU.ID
INNER JOIN
    SUBSCRIPTIONTYPES ST
ON
    (
        SS.SUBSCRIPTION_TYPE_CENTER = ST.CENTER
    AND SS.SUBSCRIPTION_TYPE_ID = ST.ID)
INNER JOIN
    PRODUCTS PR
ON
    (
        SS.SUBSCRIPTION_TYPE_CENTER = PR.CENTER
    AND SS.SUBSCRIPTION_TYPE_ID = PR.ID)
INNER JOIN
    --PERSONS p
    PERSONS p
ON
    p.center = SS.OWNER_CENTER
    AND p.ID = ss.OWNER_ID
INNER JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
LEFT JOIN
    PRODUCT_GROUP prg
ON
    prg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    SUBSCRIPTION_CHANGE sc
ON
    sc.NEW_SUBSCRIPTION_CENTER = su.center
    AND sc.NEW_SUBSCRIPTION_ID = su.id
    AND sc.TYPE = 'EXTENSION'
LEFT JOIN
    SUBSCRIPTIONS ex_s
ON
    ex_s.center = sc.OLD_SUBSCRIPTION_CENTER
    AND ex_s.id = sc.OLD_SUBSCRIPTION_ID
LEFT JOIN
    PRODUCTS ex_pr
ON
    ex_pr.CENTER = ex_s.SUBSCRIPTIONTYPE_CENTER
    AND ex_pr.ID = ex_s.SUBSCRIPTIONTYPE_ID
LEFT JOIN 
    INVOICE_LINES_MT il
ON
    il.center = su.invoiceline_center
    AND il.id = su.invoiceline_id
    AND il.subid = su.invoiceline_subid	
LEFT JOIN
(
    SELECT 
       pu.TARGET_CENTER, pu.TARGET_ID, listagg(cc.CODE, ',') within group (order by pu.CAMPAIGN_CODE_ID) AS "CODE"
    FROM
       PRIVILEGE_USAGES pu
    JOIN
       CAMPAIGN_CODES cc
    ON
       pu.CAMPAIGN_CODE_ID = cc.ID
    WHERE 
       pu.CAMPAIGN_CODE_ID is not null
       AND pu.TARGET_SERVICE = 'InvoiceLine'
    GROUP BY 
       pu.TARGET_CENTER, pu.TARGET_ID
) camps    
ON
    camps.TARGET_CENTER = il.center 
    AND camps.TARGET_ID = il.ID 
LEFT JOIN
    CAMPAIGN_CODES cc_startup
ON
    su.CAMPAIGN_CODE_ID = cc_startup.ID
LEFT JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK ex_ppgl
ON
    ex_ppgl.PRODUCT_CENTER = ex_s.SUBSCRIPTIONTYPE_CENTER
    AND ex_ppgl.PRODUCT_ID = ex_s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PRODUCT_GROUP ex_pg
ON
    ex_pg.id = ex_ppgl.PRODUCT_GROUP_ID
LEFT JOIN
    (
        SELECT
            re_p.CURRENT_PERSON_CENTER,
            re_p.CURRENT_PERSON_ID,
            scl.ENTRY_START_TIME,
            re_pr.name
        FROM
            subscriptions re_s
        JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.center = re_s.center
        AND scl.id = re_s.id
        JOIN
            products re_pr
        ON
            re_pr.CENTER = re_s.SUBSCRIPTIONTYPE_CENTER
        AND re_pr.ID = re_s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK re_ppgl
        ON
            re_ppgl.PRODUCT_CENTER = re_s.SUBSCRIPTIONTYPE_CENTER
        AND re_ppgl.PRODUCT_ID = re_s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCT_GROUP re_pg
        ON
            re_pg.id = re_ppgl.PRODUCT_GROUP_ID
        JOIN
            --persons re_p
            persons re_p
        ON
            re_p.center = re_s.OWNER_CENTER
        AND re_p.id = re_s.OWNER_ID
        WHERE
            scl.ENTRY_TYPE = 2
            -- no subscription cancelled / regretted in the last 30 days
        AND scl.STATEID IN (2,3)
        AND scl.SUB_STATE IN (7,8)
            --AND re_s.CREATION_TIME +1000*60*60*24 < scl.ENTRY_START_TIME
        AND TRUNC(longtodate(re_s.CREATION_TIME)) < (longtodate(scl.ENTRY_START_TIME))
        GROUP BY
            re_p.CURRENT_PERSON_CENTER,
            re_p.CURRENT_PERSON_ID,
            scl.ENTRY_START_TIME,
            re_pr.name
        HAVING
            MAX(re_pg.EXCLUDE_FROM_MEMBER_COUNT) = 0 ) type4
ON
    type4.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
    AND type4.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
    AND type4.ENTRY_START_TIME BETWEEN su.CREATION_TIME - 1000*60*60*24*30 AND su.CREATION_TIME
LEFT OUTER JOIN
    (
        SELECT
            s.CENTER,
            s.ID
        FROM
            SUBSCRIPTIONS s
        INNER JOIN
            CENTERS c
        ON
            c.ID = s.CENTER
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            PRODUCT_CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND PRODUCT_ID = s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.id = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.ID IN (4001, 4601, 5208)
        AND c.COUNTRY ='IT'
        GROUP BY
            s.CENTER,
            s.ID ) spg
ON
    ss.SUBSCRIPTION_CENTER = spg.CENTER
    AND ss.SUBSCRIPTION_ID = spg.ID
WHERE
    (
    SS.SUBSCRIPTION_TYPE_CENTER IN ($$Scope$$)
    AND LongToDate(SU.CREATION_TIME) >= $$SalesFromDate$$
    AND LongToDate(SU.CREATION_TIME) < $$SalesToDate$$ +1)
    AND ss.TYPE IN(1,2)
    AND (
        spg.CENTER IS NULL
        OR  prg.id IN (5413,5414,6802))
  /*
    AND p.center = 219
    AND p.id = 45051
  */
    --Exludung comps, operating x 2 & juniors
    AND PRG.ID NOT IN (5405,5611,5613,5406,5407,5615)
    -- excludes subscription sales after a regrest/cancellation unless the regretted/cancelled
    -- subscription is an 'Exlucde from mem.count'
    AND type4.CURRENT_PERSON_CENTER IS NULL
    AND pr.NAME NOT LIKE 'Corporate%'
    AND NOT EXISTS (
       SELECT 1 
	   FROM 
	      SUBSCRIPTIONS sw
	   JOIN
          STATE_CHANGE_LOG scl
       ON 
          scl.ENTRY_TYPE = 2
          AND scl.CENTER = sw.CENTER
          AND scl.id = sw.ID
          AND scl.STATEID = 7 
       WHERE 
          sw.OWNER_CENTER = su.OWNER_CENTER
          AND sw.OWNER_ID = su.OWNER_ID
          AND sw.ID <> su.ID
		  AND scl.ENTRY_START_TIME >= su.CREATION_TIME - 1000*60*60*24*30 
		  AND NOT EXISTS (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl 
		                  WHERE pl.PRODUCT_CENTER = sw.SUBSCRIPTIONTYPE_CENTER 
						  AND pl.PRODUCT_ID = sw.SUBSCRIPTIONTYPE_ID 
						  AND pl.PRODUCT_GROUP_ID = 4601)
    )
GROUP BY
    cen.ID,
    cen.SHORTNAME,
    SS.SALES_DATE,
    p.CENTER,
    p.ID ,
    SS.SUBSCRIPTION_CENTER,
    SS.SUBSCRIPTION_ID ,
    p.FULLNAME,
    pr.NAME ,
    prg.NAME ,
    SS.TYPE,
    camps.CODE,
    cc_startup.CODE,
    ex_pr.name,
    longtodateC(SU.CREATION_TIME, SU.CENTER),
    type4.CURRENT_PERSON_CENTER,
    type4.name,
    su.START_DATE,
    su.END_DATE,
    su.BINDING_END_DATE,
    p.STATUS,
    su.STATE,
    il.TOTAL_AMOUNT,
    su.SUB_STATE,
    su.SUBSCRIPTION_PRICE,
    su.STARTUP_FREE_PERIOD_ID,    
    CASE
        WHEN ss.EMPLOYEE_CENTER = 100
        AND ss.EMPLOYEE_ID = 3202
        THEN 1
        ELSE 0
    END
HAVING
    (
        MAX(ex_pg.EXCLUDE_FROM_MEMBER_COUNT) = 1
    AND ss.TYPE = 2
    AND type4.CURRENT_PERSON_CENTER IS NULL)
   OR  ss.TYPE = 1
ORDER BY
    cen.ID,
    SS.SALES_DATE
) t1
LEFT JOIN
    PERSON_EXT_ATTRS a
ON
    t1.pcenter = a.PERSONCENTER
    AND t1.pid = a.PERSONID
    AND a.name = 'Sono_presenti_tutti_i _dati_anagrafici'
LEFT JOIN
    PERSON_EXT_ATTRS b
ON
    t1.pcenter = b.PERSONCENTER
    AND t1.pid = b.PERSONID
    AND b.name = 'Sono_presenti_ID_e_codice_fiscale'
LEFT JOIN
    PERSON_EXT_ATTRS c
ON
    t1.pcenter = c.PERSONCENTER
    AND t1.pid = c.PERSONID
    AND c.name = 'CONDIZIONIGENERALIFIRMATO'
LEFT JOIN
    PERSON_EXT_ATTRS d
ON
    t1.pcenter = d.PERSONCENTER
    AND t1.pid = d.PERSONID
    AND d.name = 'Sono_presenti_i_dati_bancari_o_il_pagamento_cash'
                  
LEFT JOIN
    PERSON_EXT_ATTRS e
ON
     t1.pcenter = e.PERSONCENTER
     AND t1.pid = e.PERSONID
     AND e.name = 'LADATAINIZIOEVALIDA'
LEFT JOIN
    PERSON_EXT_ATTRS f
ON
     t1.pcenter = f.PERSONCENTER
     AND t1.pid = f.PERSONID
     AND f.name = 'PRESENTEILBADGEAZIENDALE'
LEFT JOIN
    PERSON_EXT_ATTRS g
ON
     t1.pcenter = g.PERSONCENTER
     AND t1.pid = g.PERSONID
     AND g.name = 'MODULODIPAGAMENTOFIRMATO'
LEFT JOIN
    PERSON_EXT_ATTRS h
ON
     t1.pcenter = h.PERSONCENTER
     AND t1.pid = h.PERSONID
     AND h.name = 'Sono_presenti_le_firme_del_titolare_dei_pagamenti'
LEFT JOIN
    PERSON_EXT_ATTRS mc
ON
     t1.pcenter = mc.PERSONCENTER
     AND t1.pid = mc.PERSONID
     AND mc.name = 'MC_IT'
LEFT JOIN
     PERSONS sales
ON
     sales.center||'p'||sales.id = mc.TXTVALUE
LEFT JOIN
     RELATIVES rel_company
ON
     rel_company.CENTER = t1.pcenter
     AND rel_company.ID = t1.pid
     AND rel_company.RTYPE = 3
     AND rel_company.STATUS = 1
LEFT JOIN
     PERSONS mycomp
ON
    rel_company.RELATIVECENTER = mycomp.CENTER
    AND rel_company.RELATIVEID = mycomp.ID
LEFT JOIN
     COMPANYAGREEMENTS ca
ON
     ca.CENTER = rel_company.RELATIVECENTER
     AND ca.ID = rel_company.RELATIVEID
     AND ca.SUBID = rel_company.RELATIVESUBID
LEFT JOIN
(
    SELECT
       sa.SUBSCRIPTION_CENTER, 
       sa.SUBSCRIPTION_ID, 
       listagg (mpr.CACHED_PRODUCTNAME, ', ') WITHIN GROUP (ORDER BY mpr.CACHED_PRODUCTNAME) AS "ADD_ON"
    FROM
        SUBSCRIPTION_ADDON sa
    JOIN
        MASTERPRODUCTREGISTER mpr
    ON 
        sa.ADDON_PRODUCT_ID = mpr.ID
    WHERE
        sa.CANCELLED = 0
        AND mpr.PRIMARY_PRODUCT_GROUP_ID = 20004
    GROUP BY 
        sa.SUBSCRIPTION_CENTER, 
        sa.SUBSCRIPTION_ID
) t2
ON 
    t2.SUBSCRIPTION_CENTER = t1.SUBSCRIPTION_CENTER
    AND t2.SUBSCRIPTION_ID = t1.SUBSCRIPTION_ID
LEFT JOIN
    STARTUP_CAMPAIGN sc
ON 
    sc.ID = t1.STARTUP_FREE_PERIOD_ID    
     