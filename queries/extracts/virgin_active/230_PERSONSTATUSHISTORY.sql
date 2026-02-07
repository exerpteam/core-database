/*
This should record changes to the external attribute that keeps track of the person status.
Since this is not yet implemented we just check for address changes but this needs to be updated.
*/
SELECT
    pcl.ID "PersonStatusHistoryID",
    p.EXTERNAL_ID "PersonID",
    longToDate(lc.ENTRY_TIME) "CreatedDate",
    longToDate(pcl.ENTRY_TIME) "ModifiedDate",
    longToDate(pcl.ENTRY_TIME) "StartDate",
    'N/A' "EndDate",
    '?' "Status",
    'N/A' "TerminatedReason",
    '?' "StatusType",
    'EXERP' "SourceSystem",
    pcl.ID "ExtRef"
FROM
    PERSON_CHANGE_LOGS pcl
LEFT JOIN PERSON_CHANGE_LOGS lc
ON
    lc.PERSON_CENTER = pcl.PERSON_CENTER
    AND lc.PERSON_ID = pcl.PERSON_ID
    AND lc.CHANGE_ATTRIBUTE = pcl.CHANGE_ATTRIBUTE
    AND lc.PREVIOUS_ENTRY_ID IS NULL
JOIN PERSONS op
ON
    op.CENTER = pcl.PERSON_CENTER
    AND op.ID = pcl.PERSON_ID
JOIN PERSONS p
ON
    p.CENTER = op.CURRENT_PERSON_CENTER
    AND p.ID = op.CURRENT_PERSON_ID
WHERE
    pcl.CHANGE_ATTRIBUTE = 'ADDRESS_1'
    AND pcl.PREVIOUS_ENTRY_ID IS NOT NULL