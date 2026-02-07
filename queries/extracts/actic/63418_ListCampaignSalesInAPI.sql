SELECT * FROM STARTUP_CAMPAIGN sc
WHERE
	(sc.ID)::varchar = $$CampaignId$$
