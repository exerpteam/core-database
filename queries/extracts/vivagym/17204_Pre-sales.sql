-- The extract is extracted from Exerp on 2026-02-08
--  
Select id, shortname, startupdate, country, web_name
From centers
WHERE startupdate > CURRENT_DATE
AND (web_name LIKE '¡Próxima apertura!%' OR web_name LIKE 'Próxima abertura!%');