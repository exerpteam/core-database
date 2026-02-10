-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    rel.CENTER || 'p' || rel.ID pid,
    p.CURRENT_PERSON_CENTER || 'p' || p.CURRENT_PERSON_ID current_Pid,
    p.SSN,
    p.FIRSTNAME,
    p.LASTNAME,
    longToDate(greatest(scl.ENTRY_START_TIME, 1356994800000)) agreement_start,
    longToDate(nvl2(scl.ENTRY_END_TIME,scl.ENTRY_END_TIME,1388530800000)) egreement_end,
    ceil(months_between(longToDate(greatest(scl.ENTRY_START_TIME, 1356994800000)),longToDate(nvl2(scl.ENTRY_END_TIME,scl.ENTRY_END_TIME,1388530800000)))*-1) month_on_agreement
FROM
    FW.RELATIVES rel
JOIN FW.PERSONS p
ON
    p.CENTER = rel.CENTER
    AND p.ID = rel.ID
JOIN FW.STATE_CHANGE_LOG scl
ON
    scl.CENTER = rel.CENTER
    AND scl.ID = rel.ID
    AND scl.SUBID = rel.SUBID
    AND scl.STATEID = 1
WHERE
    rel.RTYPE = 3
    AND rel.RELATIVECENTER = 116
    AND rel.RELATIVEid = 16122
    AND rel.RELATIVEsubid = 1
    AND
    (
        scl.ENTRY_START_TIME < 1388530800000
        AND
        (
            scl.ENTRY_END_TIME IS NULL
            OR scl.ENTRY_END_TIME > 1356994800000
        )
    )
    AND EXISTS
    (
        SELECT
            *
        FROM
            FW.SUBSCRIPTIONS s
        JOIN FW.PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        WHERE
            s.OWNER_CENTER = rel.CENTER
            AND s.OWNER_ID = rel.ID
            AND prod.GLOBALID = 'EFT_CORPORATE_NORMAL'
            AND s.START_DATE < longToDate(nvl2(scl.ENTRY_END_TIME,scl.ENTRY_END_TIME,1388530800000))
            AND
            (
                s.END_DATE IS NULL
                OR s.END_DATE >= longToDate(greatest(scl.ENTRY_START_TIME, 1356994800000))
            )
    )
ORDER BY
    p.CENTER,
    p.ID,
    scl.ENTRY_START_TIME