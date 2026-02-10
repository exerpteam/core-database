-- The extract is extracted from Exerp on 2026-02-08
-- Report to get the lead from the tablet that have accepted to received commercial information
       WITH
            params AS
            (
             SELECT
                    /*+ materialize */
                    datetolongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS from_date,
                    datetolongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS to_date,
                    c.ID                      AS CenterID
               FROM
                    CENTERS c
            )
SELECT
    p.external_id AS ExternalID,
	ce.name AS Club,
    p.fullname AS Nombre,
	pea.txtvalue AS Email

FROM
       persons p

JOIN
	centers ce
ON
	p.center = ce.id
JOIN
    params
 ON
    params.CenterID = p.center

LEFT JOIN
        vivagym.person_ext_attrs pea
        ON p.current_person_center = pea.personcenter AND p.current_person_id = pea.personid 
        AND pea.name = '_eClub_Email'

WHERE
    EXISTS ( SELECT * FROM PERSON_EXT_ATTRS WHERE PERSONCENTER= P.CENTER AND PERSONID = P.ID AND NAME = 'CREATION_DATE' AND CAST(TXTVALUE AS DATE) BETWEEN :fromDate AND :toDate)
    AND EXISTS ( SELECT * FROM PERSON_EXT_ATTRS WHERE PERSONCENTER= P.CENTER AND PERSONID = P.ID AND NAME = 'LEADCAP' AND TXTVALUE IS NOT NULL AND TXTVALUE ='true')
    AND EXISTS ( SELECT * FROM PERSON_EXT_ATTRS WHERE PERSONCENTER= P.CENTER AND PERSONID = P.ID AND NAME = 'eClubIsAcceptingEmailNewsLetters' AND TXTVALUE IS NOT NULL AND TXTVALUE = 'true')
    AND p.center IN (:Scope)