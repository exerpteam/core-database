-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    decode(status,0,'Lead',1,'Active',2,'Inactive',3,'TemporaryInactive',4,'Transferred',5,'Duplicate',6,'Prospect',7,'Deleted',8,'Anonymized',9,'Contact','Undefined') AS PersonStatus,
    SUM("International Number Count") AS "International Number Count"
FROM
    (
        SELECT
            p.status,
            CASE
                WHEN SUBSTR(pea.TXTVALUE,0,3) != '+44'
                THEN 1
                ELSE 0
            END AS "International Number Count"
        FROM
            persons p
        LEFT JOIN
            person_ext_attrs pea
        ON
            pea.name = '_eClub_PhoneSMS'
        AND pea.PERSONCENTER = p.center
        AND pea.PERSONID = p.id
        WHERE
            pea.TXTVALUE IS NOT NULL
    )
GROUP BY
    status