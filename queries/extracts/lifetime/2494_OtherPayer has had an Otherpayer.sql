-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    otherpayer.center || 'p' || otherpayer.id AS "OtherPayerId",
    otherpayer.external_id                    AS "Other Payers External Id",
    mobile.txtvalue                           AS "Other Payers Mobile Number",
    email.txtvalue                            AS "Other Payers Email Address",
    op_ar.balance                             AS "Other Payer Payment Account Balance"
FROM
    persons per
JOIN
    relatives oprel
ON
    oprel.relativecenter = per.center
    AND oprel.relativeid = per.id
    AND oprel.rtype = 12
JOIN
    persons otherpayer
ON
    otherpayer.center = oprel.center
    AND otherpayer.id = oprel.id
JOIN
    relatives opoprel
ON
    opoprel.relativecenter = otherpayer.center
    AND opoprel.relativeid = otherpayer.id
    AND opoprel.rtype = 12
JOIN
    persons otherpayerpayer
ON
    otherpayerpayer.center = opoprel.center
    AND otherpayerpayer.id = opoprel.id
JOIN
    account_receivables op_ar
ON
    op_ar.customercenter = otherpayer.center
    AND op_ar.customerid = otherpayer.id
    AND op_ar.ar_type = 4
LEFT JOIN
    person_ext_attrs mobile
ON
    otherpayer.center=mobile.PERSONCENTER
    AND otherpayer.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    otherpayer.center=email.PERSONCENTER
    AND otherpayer.id=email.PERSONID
    AND email.name='_eClub_Email'
WHERE
    op_ar.balance < 0