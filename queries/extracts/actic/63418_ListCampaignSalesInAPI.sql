-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT * FROM STARTUP_CAMPAIGN sc
WHERE
	(sc.ID)::varchar = $$CampaignId$$
