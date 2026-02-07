SELECT		
    
    ss.OWNER_CENTER || 'p' || ss.OWNER_ID person_id,		
	CASE owner.STATUS
        WHEN 0 THEN 'Lead'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Inactive'
        WHEN 3 THEN 'Temporary Inactive'
        WHEN 4 THEN 'Transferred'
        WHEN 5 THEN 'Duplicate'
        WHEN 6 THEN 'Prospect'
        WHEN 7 THEN 'Deleted'
        WHEN 8 THEN 'Anonymized'
        WHEN 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS STATUS,

    owner.FULLNAME,		
    prod.NAME          MEMBERSHIP,		
    stype.BINDINGPERIODCOUNT AS Duration,		
    --prod.EXTERNAL_ID,		
 --   camps.CODE                  Campaign,		
sc.name AS "CampaignName",	
        		
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY')                   startdate,		
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY')    creationdate		
    		
   
    		
		
FROM		
    SUBSCRIPTION_SALES ss		
JOIN		
    SUBSCRIPTIONS sub		
ON		
    sub.CENTER = ss.SUBSCRIPTION_CENTER		
    AND sub.ID = ss.SUBSCRIPTION_ID		
JOIN		
    SUBSCRIPTIONTYPES stype		
ON		
    ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER		
    AND ss.SUBSCRIPTION_TYPE_ID = stype.ID		
JOIN		
    PRODUCTS prod		
ON		
    stype.CENTER = prod.CENTER		
    AND stype.ID = prod.ID		
JOIN		
    PERSONS owner		
ON		
    owner.CENTER = sub.OWNER_CENTER		
    AND owner.ID = sub.OWNER_ID		
		
LEFT JOIN		
PRIVILEGE_USAGES pu		
ON 		
pu.person_center =  owner.CENTER		
AND pu.person_id = owner.ID		
JOIN		
            PRIVILEGE_GRANTS pg		
        ON		
            pg.ID = pu.GRANT_ID		
            AND pg.GRANTER_SERVICE = 'StartupCampaign'		
        JOIN		
            STARTUP_CAMPAIGN sc		
        ON		
            sc.ID = pg.GRANTER_ID		
        WHERE		
            pu.USE_TIME >= $$CreationFrom$$		
            AND pu.USE_TIME < ($$CreationTo$$ + 24*60*60*1000)		
		
AND    ss.type =1 -- only new sales		
    AND ss.SUBSCRIPTION_CENTER IN ($$Scope$$)		
    AND sub.CREATION_TIME >= $$CreationFrom$$		
    AND sub.CREATION_TIME < ($$CreationTo$$ + 24*60*60*1000)		
AND sc.ID IN ('59294', '60092', '59897', '59895','59896')--specific campaignids		
