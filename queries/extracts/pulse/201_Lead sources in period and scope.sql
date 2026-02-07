--SELECT
--    *
--FROM
--    (
        SELECT
            p.center,
            pexCreation.TXTVALUE CREATION
            --,pexLeadSource.TXTVALUE SOURCE
        FROM
            PERSONS p
        JOIN PERSON_EXT_ATTRS pexCreation
        ON
            p.CENTER = pexCreation.PERSONCENTER
            AND p.ID = pexCreation.PERSONID
            AND pexCreation.NAME = 'CREATION_DATE'
        LEFT JOIN PERSON_EXT_ATTRS pexLeadSource
        ON
            p.CENTER = pexLeadSource.PERSONCENTER
            AND p.ID = pexLeadSource.PERSONID
            AND pexLeadSource.NAME = 'NEW_ENQUIRY_SOURCE_CODE'
        WHERE
            p.CENTER in (:Scope) 
            AND TO_DATE(pexCreation.TXTVALUE, 'YYYY-MM-DD') >= :FromDate
            AND TO_DATE(pexCreation.TXTVALUE, 'YYYY-MM-DD') <= :ToDate
--    )
--    PIVOT ( COUNT(*) FOR SOURCE IN ('LD','BN','RD','SW','PW','HW','LB','LE','CP','PG','HS','SM','PO','F--LY','RF','PA','PS','PU','OD','CM','SC') )