SELECT 
    pea.txtvalue AS u_email_adress,
	p.status,
    p.external_id AS u_external_id, 
    p.center AS u_center_id, 
    p.firstname AS u_member_first_name, 
    p.lastname AS u_member_last_name, 
    p.center || 'p' || p.id AS u_member_number, 
    CASE 
        WHEN lang_attr.txtvalue = '7' THEN 'DE'
        WHEN lang_attr.txtvalue = '1' THEN 'EN'
        WHEN lang_attr.txtvalue = '2' THEN 'FR'
        WHEN lang_attr.txtvalue = '11' THEN 'IT'
        ELSE 'Unknown' -- Optional, for values that do not match any case
    END AS _eClub_LanguagePreferred,
    TO_CHAR(longtodate(p.LAST_MODIFIED), 'dd-MM-yyyy HH24:MI') AS "Sidst opdateret"
FROM PERSONS P
LEFT JOIN PERSON_EXT_ATTRS PEA 
    ON PEA.PERSONCENTER = P.CENTER AND PEA.PERSONID = P.ID 
    AND pea.name IN ('_eClub_Email')
LEFT JOIN PERSON_EXT_ATTRS lang_attr 
    ON lang_attr.PERSONCENTER = P.CENTER AND lang_attr.PERSONID = P.ID
    AND lang_attr.name = '_eClub_LanguagePreferred'
WHERE p.center IN (:Scope)
AND p.status in (1,3)
