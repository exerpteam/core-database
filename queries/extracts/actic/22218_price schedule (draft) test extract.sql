SELECT
    s.CENTER || 'ss' || s.ID subs_Id,
    s.OWNER_CENTER || 'p' || s.OWNER_ID person_Id,
    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD') BINDING_END_DATE,
    s.BINDING_PRICE INSIDE_BINDING_PRICE,
    s.SUBSCRIPTION_PRICE OUTSIDE_BINDING_PRICE,
    TO_CHAR(sp1.FROM_DATE, 'YYYY-MM-DD') NEW_PRICE_FROM,
    sp1.PRICE NEW_PRICE_AMOUNT,
    sp1.BINDING,
    sp1.TYPE,
    CASE
        WHEN sp1.CANCELLED = 1
        THEN 'CANCELLED'
        WHEN sp1.APPLIED = 1
        THEN 'APPLIED'
        WHEN sp1.PENDING = 1
        THEN 'PENDING'
        WHEN sp1.APPROVED = 1
        THEN 'APPROVED'
        WHEN sp1.APPROVED = 0
            AND sp1.PENDING = 0
            AND sp1.APPLIED = 0
            AND sp1.CANCELLED = 0
        THEN 'DRAFT'
        ELSE 'ERROR'
    END change_State,
   mex.TXTVALUE member_salutation,
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
        CASE
        WHEN payer.CENTER IS NOT NULL
        THEN payer.CENTER || 'p' || payer.ID
        ELSE NULL
    END payer_id,
    pex.TXTVALUE payer_salutation,
    payer.FIRSTNAME payer_firstname,
    payer.LASTNAME payer_lastname,
    payer.ADDRESS1 payer_address1,
    payer.ADDRESS2 payer_address2,
    payer.ADDRESS3 payer_address3,
    payer.ZIPCODE payer_postcode,
    payer.CITY payer_city    
FROM
    subscriptions s
JOIN
    subscription_price sp1
ON
    Sp1.Subscription_Center = s.center
    AND Sp1.Subscription_Id = s.id
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    SUBSCRIPTIONTYPES stype
ON
    s.SUBSCRIPTIONTYPE_CENTER = stype.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = stype.ID
JOIN
    PRODUCTS prod
ON
    stype.CENTER = prod.CENTER
    AND stype.ID = prod.ID    
LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.RELATIVECENTER = s.OWNER_CENTER
    AND op_rel.RELATIVEID = s.OWNER_ID
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3
LEFT JOIN
    persons payer
ON
    payer.CENTER = op_rel.CENTER
    AND payer.ID = op_rel.ID
LEFT JOIN
    PERSON_EXT_ATTRS mex
ON
    mex.PERSONCENTER = p.CENTER
    AND mex.PERSONID = p.ID
    AND mex.NAME = '_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS pex
ON
    pex.PERSONCENTER = payer.CENTER
    AND pex.PERSONID = payer.ID
    AND pex.NAME = '_eClub_Salutation'    
WHERE
    s.state IN (2,4,8)

    AND sp1.PRICE > s.BINDING_PRICE
    AND sp1.BINDING = 0
    AND Sp1.Cancelled = 0
    AND sp1.TYPE = 'SCHEDULED'
    AND Sp1.From_Date > TRUNC(exerpsysdate())
    AND (
        Sp1.To_Date IS NULL
        OR Sp1.To_Date >=TRUNC(exerpsysdate()))