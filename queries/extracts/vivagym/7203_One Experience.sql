       WITH
            params AS
            (
             SELECT
                    /*+ materialize */
                    --TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS cutDate,
                    datetolongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS from_date,
                    datetolongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS to_date,
                    c.ID                      AS CenterID
               FROM
                    CENTERS c
            )
SELECT
    p.current_person_center || 'p' || p.current_person_id AS MemberID ,
   p.external_id AS ExternalID,
	ce.name AS Clube_de_compra,
    longtodatec(ats.trans_time,il.center) AS Data_de_compra,
	p.fullname AS Nome,
	p.address1 AS Morada,
	p.city AS Cidade_do_socio,
	p.birthdate AS Data_nacimiento,
	pea.txtvalue AS Email,
	pea2.txtvalue AS telefone,
	p.center AS Clube_Origem

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
LEFT JOIN
        vivagym.person_ext_attrs pea2
        ON p.current_person_center = pea2.personcenter AND p.current_person_id = pea2.personid AND pea2.name = '_eClub_PhoneSMS'
WHERE
    il.text             = 'ONE EXPERIENCE PT'
    AND ats.trans_time >= params.from_date
    AND ats.trans_time <= params.to_date
    AND ats.center IN (:Scope)