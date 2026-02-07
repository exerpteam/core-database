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
