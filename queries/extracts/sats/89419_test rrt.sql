-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        longtodatec(ccc.start_datetime,ccc.personcenter) as stardate,
        longtodatec(ccc.closed_datetime,ccc.personcenter) as enddate,
        ccc.*
FROM persons p
JOIN centers c ON p.center = c.id AND c.country = 'SE'
JOIN cashcollectioncases ccc ON p.center = ccc.personcenter AND p.id = ccc.personid AND ccc.missingpayment = true
WHERE
        EXISTS
        (
                SELECT 1
                FROM cashcollectioncases ccc2
                WHERE
                        ccc2.personcenter = p.center
                        AND ccc2.personid = p.id
                        AND ccc2.missingpayment = true
                        AND ccc2.closed = false
        )