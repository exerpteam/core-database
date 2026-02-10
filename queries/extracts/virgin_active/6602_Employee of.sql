-- The extract is extracted from Exerp on 2026-02-08
--  
EXISTS
    (
        SELECT
            1
        FROM
            RELATIVES r1
        WHERE
            r1.RTYPE =2
            AND r1.RELATIVECENTER = p.CENTER
            AND r1.RELATIVEID = p.id
            AND r1.STATUS = 1
            AND (
                r1.center,r1.id) IN ($$company_ID$$) )