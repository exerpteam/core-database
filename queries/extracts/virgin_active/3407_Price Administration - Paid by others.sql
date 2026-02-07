SELECT
    centre.ID club_Id,
    centre.NAME club_name,
    p.CENTER || 'p' || p.id memberid,
    p.FIRSTNAME member_firstname,
    p.LASTNAME member_lastname,
    prod.name subscription,
    p.FIRSTNAME member_firstname,
    p.LASTNAME member_lastname,
    p.ADDRESS1 member_address1,
    p.ADDRESS2 member_address2,
    p.ADDRESS3 member_address3,
    p.ZIPCODE member_postcode,
    p.CITY payer_city,
    sub.SUBSCRIPTION_PRICE "CURRENT PRICE",
    pc.PRICE "NEW PRICE",
    pc.PRICE - sub.SUBSCRIPTION_PRICE "VARIANCE",
    TO_CHAR(pc.FROM_DATE, 'DD.MM.YYYY') APPLY_DATE,
    pex.TXTVALUE payer_salutation,
    payer.FIRSTNAME payer_firstname,
    payer.LASTNAME payer_lastname,
    payer.ADDRESS1 payer_address1,
    payer.ADDRESS2 payer_address2,
    payer.ADDRESS3 payer_address3,
    payer.ZIPCODE payer_postcode,
    payer.CITY payer_city,
    centre.PHONE_NUMBER club_phone,
    gm.FULLNAME gm_fullname,
    pc.ID change_id,
    CASE
        WHEN pc.CANCELLED = 1
        THEN 'CANCELLED'
        WHEN pc.APPLIED = 1
        THEN 'APPLIED'
        WHEN pc.PENDING = 1
        THEN 'PENDING'
        WHEN pc.APPROVED = 1
        THEN 'APPROVED'
        WHEN pc.APPROVED = 0
            AND pc.PENDING = 0
            AND pc.APPLIED = 0
            AND pc.CANCELLED = 0
        THEN 'DRAFT'
        ELSE 'ERROR'
    END change_State,
    CASE
        WHEN pc.NOTIFIED = 1
        THEN 'Yes'
        ELSE 'No'
    END change_sent
FROM
    SUBSCRIPTIONS sub
JOIN
    SUBSCRIPTION_PRICE pc
ON
    pc.SUBSCRIPTION_CENTER = sub.CENTER
    AND pc.SUBSCRIPTION_ID = sub.ID
JOIN
    SUBSCRIPTIONTYPES stype
ON
    sub.SUBSCRIPTIONTYPE_CENTER = stype.CENTER
    AND sub.SUBSCRIPTIONTYPE_ID = stype.ID
JOIN
    PRODUCTS prod
ON
    stype.CENTER = prod.CENTER
    AND stype.ID = prod.ID
JOIN
    CENTERS centre
ON
    sub.CENTER = centre.ID
JOIN
    PRODUCTS joinProd
ON
    stype.PRODUCTNEW_CENTER = joinProd.CENTER
    AND stype.PRODUCTNEW_ID = joinProd.ID
JOIN
    PERSONS p
ON
    p.CENTER = sub.OWNER_CENTER
    AND p.ID = sub.OWNER_ID
JOIN
    RELATIVES op_rel
ON
    op_rel.RELATIVECENTER = sub.OWNER_CENTER
    AND op_rel.RELATIVEID = sub.OWNER_ID
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3
JOIN
    persons payer
ON
    payer.CENTER = op_rel.CENTER
    AND payer.ID = op_rel.ID
LEFT JOIN
    PERSON_EXT_ATTRS pex
ON
    pex.PERSONCENTER = payer.CENTER
    AND pex.PERSONID = payer.ID
    AND pex.NAME = '_eClub_Salutation'
LEFT JOIN
    PERSONS gm
ON
    centre.MANAGER_CENTER = gm.CENTER
    AND centre.MANAGER_ID = gm.ID
WHERE
    pc.FROM_DATE = $$ApplyDate$$
    AND pc.TYPE IN ('SCHEDULED',
                    'MANUAL')
    AND pc.CANCELLED = 0
    AND pc.APPROVED = 1