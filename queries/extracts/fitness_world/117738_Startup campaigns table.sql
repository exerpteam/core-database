-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT st.*
FROM STARTUP_CAMPAIGN st
where st.web_text is not NULL
LIMIT 1000;