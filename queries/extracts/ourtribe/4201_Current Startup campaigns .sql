WITH
    PRODUCT_PRIVILEGE_PRICE AS
    (
        SELECT DISTINCT
            pg.GRANTER_ID,
            pg.privilege_set,
            ppr.name,
            pp.PRICE_MODIFICATION_NAME AS PriceChangeType,
            CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN pr.price*pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN pr.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE pr.price
            END AS price
        FROM
            PRIVILEGE_GRANTS pg
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            PRODUCTS pr
        ON
            pp.REF_GLOBALID = pr.GLOBALID
        AND pr.PTYPE IN (10,
                         5)
        AND pp.REF_TYPE = 'GLOBAL_PRODUCT'
        join privilege_sets ppr
        on pg.PRIVILEGE_SET = ppr.id
        where pg.valid_to is null
    )
    

 SELECT distinct
     allCamp.NAME,
     allcamp.scopename,
     --allCamp.CENTER,
   --  allCamp.CENTER_NAME,
     longToDate(allCamp.STARTTIME) campaign_STARTTIME,
     longToDate(allCamp.ENDTIME) campaign_ENDTIME,
     allCamp.plugin_name,
    -- allCamp.RECEIVER_GROUP_TYPE,
     allCamp.CODE_TYPE,
     allCamp.code,
     allcamp.period_start as priviledge_period_start,
     allcamp.period_end as priviledge_period_end,
     allcamp.period_value,
     case when allcamp.period_unit = '2'
     then 'months'
     else '' end as period_unit,
     allCamp.ref_globalid as productglobalid,
     allcamp.privilege_set as privilegeset_ID,
    allcamp.priviledge_name
 FROM
     (
        
         SELECT DISTINCT
             suc.NAME,
             ac.CENTER,
             a.name as scopename,
             c.SHORTNAME center_name,
             suc.STARTTIME STARTTIME,
             suc.ENDTIME ENDTIME,
             suc.plugin_name,
             'STARTUP CAMPAIGN' RECEIVER_GROUP_TYPE,
             CASE suc.PLUGIN_CODES_NAME WHEN 'UNIQUE' THEN 'MULTY USAGE' WHEN 'GENERATED' THEN 'ONE TIME USAGE' WHEN 'NO_CODES' THEN 'NO CODES' ELSE 'UNDEFINED' END CODE_TYPE,
             cc.code,
             suc.period_start,
             suc.period_end,
             suc.period_unit,
             suc.period_value,
             scs.ref_globalid,
             ppp.privilege_set,
             ppp.name as priviledge_name 
         FROM
             STARTUP_CAMPAIGN suc
         JOIN AREA_CENTERS ac
         ON
             1=1
         JOIN CENTERS c
         ON
             c.ID = ac.CENTER
         join areas a
         on ac.area = a.id     
         
         Join campaign_codes cc
         on cc.campaign_id = suc.id 
         
         Join startup_campaign_subscription scs
         on scs.startup_campaign = suc.id
         JOIN
            PRODUCT_PRIVILEGE_PRICE ppp
        ON
            ppp.GRANTER_ID = suc.ID
            
         WHERE
             (
                 POSITION(',C' || ac.CENTER || ',' IN ',' || suc.AVAILABLE_SCOPES || ',') != 0
                 OR POSITION(',A' || ac.AREA || ',' IN ',' || suc.AVAILABLE_SCOPES || ',') != 0
                 OR POSITION(',T1,' IN ',' || suc.AVAILABLE_SCOPES || ',') != 0
             )
             AND suc.STATE IN ('ACTIVE')
     )
     allCamp
 WHERE
    allCamp.center IN ($$scope$$)
    AND
    
      $$startdate$$ < allCamp.STARTTIME 
    
