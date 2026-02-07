 SELECT
 cc.ID,
 cc.CODE,
 sc.NAME,
 sc.STATE as BLOCKED,
 longtodate(sc.STARTTIME) as CampaignStopDate,
 longtodate(sc.ENDTIME) as CampaignStopDate
 FROM   STARTUP_CAMPAIGN sc
 left join CAMPAIGN_CODES cc on sc.ID = cc.CAMPAIGN_ID
 where :active_date BETWEEN sc.STARTTIME and sc.ENDTIME and cc.ID is not null
