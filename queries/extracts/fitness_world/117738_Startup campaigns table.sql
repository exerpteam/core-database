-- This is the version from 2026-02-05
--  
SELECT st.*
FROM STARTUP_CAMPAIGN st
where st.web_text is not NULL
LIMIT 1000;