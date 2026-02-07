SELECT
    scl.key                              AS "ID",
    r.CENTER||'rel'||r.ID||'id'||r.SUBID AS "RELATION_ID",
    CASE
        WHEN r.RTYPE = 1
        THEN 'FRIEND'
        WHEN r.RTYPE = 2
        THEN 'EMPLOYEE'
        WHEN r.RTYPE = 3
        THEN 'COMPANYAGREEMENT'
        WHEN r.RTYPE = 4
        THEN 'FAMILY'
        WHEN r.RTYPE = 5
        THEN 'BUDDY'
        WHEN r.RTYPE = 6
        THEN 'SUBCOMPANY'
        WHEN r.RTYPE = 7
        THEN 'CONTACTPERSON'
        WHEN r.RTYPE = 8
        THEN 'CREATEDBY'
        WHEN r.RTYPE = 9
        THEN 'COUNSELLOR'
        WHEN r.RTYPE = 10
        THEN 'ACCOUNTMANAGER'
        WHEN r.RTYPE = 11
        THEN 'DUPLICATE'
        WHEN r.RTYPE = 12
        THEN 'EFT_PAYER'
        WHEN r.RTYPE = 13
        THEN 'REFERED_BY'
        WHEN r.RTYPE = 14
        THEN 'PARENTING'
        WHEN r.RTYPE = 15
        THEN 'PRIMARY_MEMBER'
        WHEN r.RTYPE = 16
        THEN 'FAMILY_OF_CORPORATE_EMPLOYEE'
        WHEN r.RTYPE = 17
        THEN 'CORPORATE_FAMILY_OF_COMPANY'
        WHEN r.RTYPE = 18
        THEN 'FAMILY_RELATIVE'
        WHEN r.RTYPE = 19
        THEN 'FAMILY_RELATION_PRIMARY'
        WHEN r.RTYPE = 20
        THEN 'FAMILY_RELATION_SPOUSE'
        WHEN r.RTYPE = 21
        THEN 'FAMILY_RELATION_PARTNER'
        WHEN r.RTYPE = 22
        THEN 'FAMILY_RELATION_CHILD'
        WHEN r.RTYPE = 23
        THEN 'FAMILY_RELATION_OTHER'

        ELSE 'UNKNOWN'
		
    END AS "TYPE",
    CASE
        WHEN r.RTYPE NOT IN (2,6,7,10)
        THEN
            CASE
                WHEN (per.CENTER != per.TRANSFERS_CURRENT_PRS_CENTER
                    OR  per.id != per.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = per.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = per.TRANSFERS_CURRENT_PRS_ID)
                ELSE per.EXTERNAL_ID
            END
    END AS "PERSON_ID",
    CASE
        WHEN r.RTYPE IN (2,6,7,10)
        THEN per.EXTERNAL_ID
    END AS "COMPANY_ID",
    CASE
        WHEN r.RTYPE IN (1,2,4,5,7,8,9,11,12,13,14,15,16,17,18)
        THEN 'PERSON'
        WHEN r.RTYPE IN (6,10)
        THEN 'COMPANY'
        WHEN r.RTYPE IN (3)
        THEN 'COMPANY_AGREEMENT' 
        WHEN r.RTYPE IN (19,20,21,22,23)
        THEN 'FAMILY' 
        ELSE 'UNKNOWN'
		
    END AS "RELATIVE_TYPE",
    CASE
        WHEN r.RTYPE IN (3)
        THEN r.relativecenter||'p'||r.relativeid||'rpt'||r.relativesubid
		WHEN r.RTYPE IN (19,20,21,22,23)
		THEN CAST(r.relativeid AS VARCHAR(255))
        ELSE crel.EXTERNAL_ID
    END AS "RELATIVE_ID",
    CASE
        WHEN scl.STATEID = 0
        THEN 'LEAD'
        WHEN scl.STATEID = 1
        THEN 'ACTIVE'
        WHEN scl.STATEID = 2
        THEN 'INACTIVE'
        WHEN scl.STATEID = 3
        THEN 'BLOCKED'
        ELSE 'UNKNOWN'
    END                  AS "STATUS",
    scl.ENTRY_START_TIME AS "FROM_DATETIME",
    r.center             AS "CENTER_ID",
    COALESCE(scl.ENTRY_END_TIME, scl.ENTRY_START_TIME)  AS "ETS",
    scl.ENTRY_END_TIME AS "TO_DATETIME"
FROM
    RELATIVES r
JOIN
    PERSONS per
ON
    per.center = r.center
AND per.id = r.id
JOIN
    PERSONS cper
ON
    cper.center = per.transfers_current_prs_center
AND cper.id = per.transfers_current_prs_id
LEFT JOIN
    PERSONS rel
ON
    rel.center = r.relativecenter
AND rel.id = r.relativeid
LEFT JOIN
    PERSONS crel
ON
    crel.center = rel.transfers_current_prs_center
AND crel.id = rel.transfers_current_prs_id
JOIN
    STATE_CHANGE_LOG scl
ON
    scl.ENTRY_TYPE = 4
AND scl.CENTER = r.CENTER
AND scl.ID = r.ID
AND scl.SUBID = r.SUBID
