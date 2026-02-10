-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
        p.CENTER || 'p' || p.ID AS "PersonId",
        CASE p.persontype
                WHEN 0 THEN 'PRIVATE'
                WHEN 1 THEN 'STUDENT'
                WHEN 2 THEN 'STAFF'
                WHEN 3 THEN 'FRIEND'
                WHEN 4 THEN 'CORPORATE'
                WHEN 5 THEN 'ONEMANCORPORATE'
                WHEN 6 THEN 'FAMILY'
                WHEN 7 THEN 'SENIOR'
                WHEN 8 THEN 'GUEST'
                WHEN 9 THEN 'CHILD'
                WHEN 10 THEN 'EXTERNAL_STAFF'
                ELSE 'UNKNOWN'
        END AS "PersonType",
        CASE P.STATUS
                WHEN 0 THEN 'LEAD'
                WHEN 1 THEN 'ACTIVE'
                WHEN 2 THEN 'INACTIVE'
                WHEN 3 THEN 'TEMPORARY INACTIVE'
                WHEN 4 THEN 'TRANSFERRED'
                WHEN 5 THEN 'DUPLICATE'
                WHEN 6 THEN 'PROSPECT'
                WHEN 7 THEN 'DELETED'
                WHEN 8 THEN 'ANONYMIZED'
                WHEN 9 THEN 'CONTACT'
                ELSE 'UNKNOWN'
        END AS "PersonStatus",
        debtor.TXTVALUE AS "StatusDEBTOR",
        extra.TXTVALUE AS "StatusEXTRA",
        frozen.TXTVALUE AS "StatusFROZEN",
        lateStart.TXTVALUE AS "StatusLATESTART"        
FROM PERSONS p
LEFT JOIN PERSON_EXT_ATTRS debtor
        ON debtor.PERSONCENTER = p.CENTER AND debtor.PERSONID = p.ID AND debtor.NAME = 'STATUS_DEBTOR'
LEFT JOIN PERSON_EXT_ATTRS extra
        ON extra.PERSONCENTER = p.CENTER AND extra.PERSONID = p.ID AND extra.NAME = 'STATUS_EXTRA'
LEFT JOIN PERSON_EXT_ATTRS frozen
        ON frozen.PERSONCENTER = p.CENTER AND frozen.PERSONID = p.ID AND frozen.NAME = 'STATUS_FROZEN'
LEFT JOIN PERSON_EXT_ATTRS lateStart
        ON lateStart.PERSONCENTER = p.CENTER AND lateStart.PERSONID = p.ID AND lateStart.NAME = 'STATUS_LATE_START'        
WHERE 
        p.STATUS IN (1,2,3)
        AND p.CENTER IN (:Scope)
