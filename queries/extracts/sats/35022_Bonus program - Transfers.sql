SELECT

    pcl.PERSON_CENTER||'p'||pcl.PERSON_ID AS newID,
    pcl.NEW_VALUE                         AS oldID,
    c1.name                               AS "To Center",
    c1.ID                                 AS "To Center ID",
    c2.name                               AS "From Center",
    c2.ID                                 AS "From Center ID"
    
FROM
    SATS.PERSON_CHANGE_LOGS pcl
JOIN
    SATS.centers c1
ON
    c1.id = pcl.PERSON_CENTER
LEFT JOIN
    SATS.centers c2
ON
    to_char(c2.id) = SUBSTR(pcl.NEW_VALUE,0,instr(pcl.NEW_VALUE,'p')-1)
WHERE
    pcl.CHANGE_ATTRIBUTE ='_eClub_TransferredFromId'
    AND pcl.PERSON_CENTER IN ($$scope$$)
and pcl.PERSON_CENTER not in (:CenterExcluded)
    AND pcl.ENTRY_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(exerpsysdate()-1 - $$offset$$), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-dd HH24:MI'))