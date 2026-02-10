-- The extract is extracted from Exerp on 2026-02-08
-- 
Returns list of campaign codes and campaign status for a specific privilege campaign name
Created for ZD ticket 83731
select 

cc.CODE,
cc.CAMPAIGN_ID,
DECODE(prg.BLOCKED, 0, 'Active', 1, 'Blocked') as "CAMPAIGN STATUS"

from CAMPAIGN_CODES cc


JOIN PUREGYM.PRIVILEGE_RECEIVER_GROUPS prg ON prg.ID = cc.CAMPAIGN_ID

where prg.NAME = :campaignName