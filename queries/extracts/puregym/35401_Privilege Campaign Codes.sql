select 

cc.CODE,
cc.CAMPAIGN_ID,
DECODE(prg.BLOCKED, 0, 'Active', 1, 'Blocked') as "CAMPAIGN STATUS"

from CAMPAIGN_CODES cc


JOIN PUREGYM.PRIVILEGE_RECEIVER_GROUPS prg ON prg.ID = cc.CAMPAIGN_ID

where prg.NAME = :campaignName