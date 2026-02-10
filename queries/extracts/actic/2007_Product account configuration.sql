-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    distinct p.name,
    p.GLOBALID,
    ai.external_id income_ext_id,
    aiVAT.GLOBALID income_ext_id_vat,
    ae.external_id expence_ext_id,
    aeVAT.GLOBALID expence_ext_id_vat,
    ar.external_id refund_ext_id,
    arVAT.external_id refund_ext_id_vat
FROM
    products p
    -- Income accounts
LEFT JOIN accounts ai
ON
    ai.center = p.INCOME_ACCOUNTCENTER
    AND ai.id = p.INCOME_ACCOUNTID
LEFT JOIN VAT_TYPES aiVAT
ON
    aiVAT.center = ai.VAT_CENTER
    AND aiVAT.id = ai.VAT_ID
    -- Expence accounts
LEFT JOIN accounts ae
ON
    ae.center = p.EXPENSE_ACCOUNTCENTER
    AND ae.id = p.EXPENSE_ACCOUNTID
LEFT JOIN VAT_TYPES aeVAT
ON
    aeVat.center = ae.VAT_CENTER
    AND aeVat.id = ae.VAT_ID
    -- Refund accounts
LEFT JOIN accounts ar
ON
    ar.center = p.REFUND_ACCOUNTCENTER
    AND ar.id = p.REFUND_ACCOUNTID
LEFT JOIN VAT_TYPES arVAT
ON
    arVat.center = ar.VAT_CENTER
    AND arVat.id = ar.VAT_ID
WHERE    
    p.CENTER in ( :ChosenScope )
    AND p.BLOCKED = 0
ORDER BY
    p.globalid,
    p.name