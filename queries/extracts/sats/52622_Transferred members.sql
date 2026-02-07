SELECT
    oldp.center || 'p' || oldp.id                                                                                                                                                         oldmemberid,
    newp.center || 'p' || newp.id                                                                                                                                                         newmemberid,
    DECODE (newp.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS newstatus,
    trd.txtvalue                                                                                                                                                                          transferdate,
    fromcenter.NAME                                                                                                                                                                       from_center,
    tocenter.NAME                                                                                                                                                                         to_center
FROM
    PERSON_EXT_ATTRS trd
JOIN
    persons oldp
ON
    trd.PERSONCENTER= oldp.CENTER
    AND trd.PERSONID= oldp.ID
    AND trd.NAME = '_eClub_TransferDate'
JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER= oldp.CENTER
    AND pea.PERSONID= oldp.ID
    AND pea.NAME = '_eClub_TransferredToId'
JOIN
    PERSONS newp
ON
    newp.center || 'p' || newp.id = pea.txtvalue
JOIN
    CENTERS fromcenter
ON
    fromcenter.ID=oldp.center
JOIN
    CENTERS tocenter
ON
    tocenter.ID=newp.center
WHERE
    trd.txtvalue BETWEEN TO_CHAR( $$from_date$$ , 'yyyy-MM-dd') AND 
    TO_CHAR( $$to_date$$ , 'yyyy-MM-dd')