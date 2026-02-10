-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT

    p.name,

    p.GLOBALID,

    pac.NAME account_config,

    ai.NAME income_name,

    ai.external_id income_ext_id,

    aiVAT.GLOBALID income_ext_id_vat,

    ae.NAME expense_name,

    ae.external_id expence_ext_id,

    aeVAT.GLOBALID expence_ext_id_vat,

    ar.NAME refund_name,    

    ar.external_id refund_ext_id,

    arVAT.external_id refund_ext_id_vat

FROM

    products p

JOIN HP.PRODUCT_ACCOUNT_CONFIGURATIONS pac

ON

    p.PRODUCT_ACCOUNT_CONFIG_ID = pac.ID

    -- Income accounts

JOIN accounts ai

ON

    ai.GLOBALID = pac.SALES_ACCOUNT_GLOBALID

    and ai.CENTER = p.center

LEFT JOIN VAT_TYPES aiVAT

ON

    aiVAT.center = ai.VAT_CENTER

    AND aiVAT.id = ai.VAT_ID

    -- Expence accounts

LEFT JOIN accounts ae

ON

    ae.GLOBALID = pac.EXPENSES_ACCOUNT_GLOBALID

    and ae.CENTER = p.center

    

LEFT JOIN VAT_TYPES aeVAT

ON

    aeVat.center = ae.VAT_CENTER

    AND aeVat.id = ae.VAT_ID

    -- Refund accounts

LEFT JOIN accounts ar

ON

    ar.GLOBALID = pac.REFUND_ACCOUNT_GLOBALID

    and ar.CENTER = p.center

LEFT JOIN VAT_TYPES arVAT

ON

    arVat.center = ar.VAT_CENTER

    AND arVat.id = ar.VAT_ID

WHERE

    p.CENTER IN ( :ChosenScope)

    AND p.BLOCKED = 0

ORDER BY

    p.globalid,

    p.name