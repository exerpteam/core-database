-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4492
SELECT st.*
FROM SOHO_TRANSACTION st
WHERE st.PERSONID IN (:PersonId)