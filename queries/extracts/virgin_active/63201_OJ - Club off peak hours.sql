-- The extract is extracted from Exerp on 2026-02-08
-- RG: 13.01.22: Lists the off peak hours configured in Exerp to show on OJ (given via ES-31607)
SELECT
    CA.Center_ID as Club_ID,
	C.Shortname as Club_Name,
	--CA.name,
    convert_from(CA.mime_value, 'UTF-8') as Off_Peak_times
FROM
    virginactive.center_ext_attrs CA
JOIN
	centers C
	ON C.ID = CA.center_id
WHERE
    CA.name = 'ClubOffPeakHours'
ORDER BY 
	Club_Name asc
