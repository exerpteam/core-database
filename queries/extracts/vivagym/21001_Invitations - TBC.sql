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
	ce.name AS Club_de_compra,
    longtodatec(ats.trans_time,il.center) AS Fecha_de_compra,
	p.fullname AS Nombre,
	pea.txtvalue AS Email

FROM
    INVOICE_LINES_MT il
JOIN
    vivagym.account_trans ats
 ON
    il.account_trans_center    = ats.center
    AND il.account_trans_id    = ats.id
    AND il.account_trans_subid = ats.subid
JOIN
	centers ce
ON
	il.account_trans_center = ce.id
JOIN
    params
 ON
    params.CenterID = il.account_trans_center
JOIN
        persons p
        ON il.person_center = p.center AND il.person_id = p.id
LEFT JOIN
        vivagym.person_ext_attrs pea
        ON p.current_person_center = pea.personcenter AND p.current_person_id = pea.personid AND pea.name = '_eClub_Email'

WHERE
    il.text             = 'Clase boxeo Trial'
    AND ats.trans_time >= params.from_date
    AND ats.trans_time <= params.to_date
    AND ats.center IN (:Scope)