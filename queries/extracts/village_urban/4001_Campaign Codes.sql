-- The extract is extracted from Exerp on 2026-02-08
-- Find campaigns for a specific campaign code ID 
select 

cc.ID as "Campaign_code_id",
cc.CODE as "Code",
cc.CAMPAIGN_TYPE as "Campaign type",
sc.NAME as "Startup campaign name",
prg.NAME as "Receiver group name",
bc.NAME as "Bundle campaign name"

from CAMPAIGN_CODES cc

left join STARTUP_CAMPAIGN sc on sc.ID = cc.CAMPAIGN_ID and cc.CAMPAIGN_TYPE = 'STARTUP'

left join PRIVILEGE_RECEIVER_GROUPS prg on prg.ID = cc.CAMPAIGN_ID and cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'

left join BUNDLE_CAMPAIGN bc on bc.ID = cc.CAMPAIGN_ID and cc.CAMPAIGN_TYPE = 'BUNDLE'

where CAST(cc.ID AS VARCHAR) in (:campaign_code_id)