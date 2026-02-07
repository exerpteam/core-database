/*
This should record changes to the external attribute that keeps track of the person status.
Since this is not yet implemented we just check for address changes but this needs to be updated.
*/
SELECT
    pcl.ID "PersonStatusHistoryID",
    p.EXTERNAL_ID "PersonID",
    longToDateC(lc.ENTRY_TIME,p.center) "CreatedDate",
    longToDateC(pcl.ENTRY_TIME,p.center) "ModifiedDate",
    longToDateC(pcl.ENTRY_TIME,p.center) "StartDate",
    /* Since it's latest entry the end date will always be null */
    NULL "EndDate",
    /* This should link to VA person statuses. Also need to implement so only the latest change is returned */
    'Not implemented yet' "Status"
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
    /* This needs to link to VA custom defined member statuses */
    pcl.CHANGE_ATTRIBUTE = 'ADDRESS_1'
    AND pcl.ENTRY_TIME >= dateToLongC(TO_CHAR( TRUNC(sysdate-1,'DD'), 'YYYY-MM-dd HH24:MI'),p.center)
    AND pcl.ENTRY_TIME < dateToLongC(TO_CHAR( TRUNC(sysdate,'DD'), 'YYYY-MM-dd HH24:MI'),p.center)
	and p.SEX != 'C'
	and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')