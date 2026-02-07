SELECT DISTINCT
    c.ID "VAClubID",
    '"' || replace(c.SHORTNAME,'"','""') || '"'   "SiteID",
    '"' || replace(c.NAME,'"','""') || '"'  "Description",
    NVL2(l.CENTER_ID,1,0) "Active"
FROM
    CENTERS c
LEFT JOIN LICENSES l
ON
    l.CENTER_ID = c.ID
    AND l.FEATURE = 'clubLead'
ORDER BY
    c.ID