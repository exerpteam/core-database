SELECT
    il.CENTER || 'inv' || il.ID || 'ln' || il.SUBID AS "NumeroFactura",
    --par.id_delegacion                                        "IdDelegacion" , -- Ahora apunta al
    -- centro pero debería apuntar al ext att del centro = DelegacionID
    CASE
        WHEN p.SEX <> 'C'
        THEN
            CASE
                WHEN (p.CENTER  != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                     SELECT
                            EXTERNAL_ID
                       FROM
                            PERSONS
                      WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END    "Entidade"                                                                     ,
	il.center||'inv'||il.ID  AS "CDU_ExerpID"                ,
    'C'                                                       AS "TipoEntidade"  ,
    i.ENTRY_TIME                                              AS "ENTRY_DATETIME",
    TO_CHAR(longtodatec(i.ENTRY_TIME ,i.CENTER),'yyyy-MM-dd') AS "FechaFactura"           ,
    prod.CENTER                                               AS "PRODUCT_CENTER"         ,
    prod.CENTER || 'prod' || prod.ID                          AS "PRODUCT_ID"             ,
    prod.PTYPE                                                AS "Observaciones"          ,
    il.text                                                   AS "Descricao"              ,
    il.PRODUCT_NORMAL_PRICE                                   AS "PRODUCT_NORMAL_PRICE"   ,
    il.QUANTITY                                               AS "Quantidade"             ,
    ROUND(il.net_amount,2)                                    AS "PrecioUnit"             ,
    ROUND(il.net_amount,2)                                    AS "BaseIva1"               ,
    ROUND(il.net_amount,2)                                    AS "BaseImponible"          ,
    ROUND(il.TOTAL_AMOUNT,2)-ROUND(il.net_amount,2)           AS "CuotaIva1"              ,
    '0.0'                                                     AS "DescPag"                ,
    'Fitnesshut'                                              AS "Empresa"                ,
    'EUR'                                                     AS "Moeda"                  ,
    ROUND(il.TOTAL_AMOUNT, 2)                                 AS "CDU_ExerpTotalDocument" ,
    '1.0'                                                     AS "Cambio"                 ,
    ROUND(il.net_amount,2)                                    AS "ImporteCMRevenue"       ,
    '0'                                                       AS "PreviousMRevenue"       ,
    '0'                                                       AS "NetDeferredRevenue"     ,
    ROUND(il.net_amount,2)                                    AS "TotalMRevenue"          ,

    TO_CHAR(longtodatec(i.TRANS_TIME,i.CENTER),'DD/MM/YYYY') "Data"                   ,
    TO_CHAR(longtodatec(i.ENTRY_TIME,i.CENTER),'DD/MM/YYYY HH24:MI') "FechaEnvio"             ,
    il.flat_rate_commission AS                                       "FLAT_RATE_COMMISSION"   ,
    il.external_id          AS                                       "EXTERNAL_ID"            ,
    i.receipt_id            AS                                       "NumeroFactura2"         ,
    CASE
        WHEN payer.SEX != 'C'
        THEN
            CASE
                WHEN (payer.CENTER  != payer.TRANSFERS_CURRENT_PRS_CENTER
                        OR payer.id != payer.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                     SELECT
                            EXTERNAL_ID
                       FROM
                            PERSONS
                      WHERE
                            CENTER = payer.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = payer.TRANSFERS_CURRENT_PRS_ID)
                ELSE payer.EXTERNAL_ID
            END
        ELSE NULL
    END "PAYER_PERSON_ID",
    CASE
        WHEN AGGREGATED_TRANSACTION_CENTER IS NOT NULL
        THEN act.AGGREGATED_TRANSACTION_CENTER||'agt'||act.AGGREGATED_TRANSACTION_ID
        ELSE NULL
    END AS "AGGREGATED_TRANSACTION_KEY"
FROM
    invoice_lines_mt il
    -- hacer un join con params usando il.center
JOIN
    INVOICES i
 ON
    il.center = i.center
    AND il.id = i.id
JOIN
    PRODUCTS prod
 ON
    prod.center = il.PRODUCTCENTER
    AND prod.id = il.PRODUCTID
JOIN
    ACCOUNT_TRANS act
 ON
    act.CENTER    = il.ACCOUNT_TRANS_CENTER
    AND act.ID    = il.ACCOUNT_TRANS_ID
    AND act.SUBID = il.ACCOUNT_TRANS_SUBID
JOIN
    ACCOUNTS credacc
 ON
    act.CREDIT_ACCOUNTCENTER = credacc.CENTER
    AND act.CREDIT_ACCOUNTID = credacc.ID
JOIN
    ACCOUNTS debitacc
 ON
    act.DEBIT_ACCOUNTCENTER = debitacc.CENTER
    AND act.DEBIT_ACCOUNTID = debitacc.ID
LEFT JOIN
    PRODUCT_GROUP pg
 ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    PERSONS p
 ON
    p.center = il.PERSON_CENTER
    AND p.ID = il.PERSON_ID
LEFT JOIN
    CASHREGISTERS crg
 ON
    crg.CENTER = i.CASHREGISTER_CENTER
    AND crg.ID = i.CASHREGISTER_ID
LEFT JOIN
    PERSONS payer
 ON
    payer.center = i.PAYER_CENTER
    AND payer.id = i.PAYER_ID
LEFT JOIN
    ACCOUNT_VAT_TYPE_GROUP vatg
 ON
    vatg.account_center = credacc.center
    AND vatg.account_id = credacc.id
LEFT JOIN
    account_vat_type_link vatl
 ON
    vatl.account_vat_type_group_id = vatg.id
LEFT JOIN
    vat_types vat
 ON
    vat.center = vatl.vat_type_center
    AND vat.id = vatl.vat_type_id
WHERE
    -- anadir condicion from and to respecto a una columna de tiempo
    il.NET_AMOUNT             != '0'
    AND il.CENTER             IN ('178','715','433','582')
    AND i.ENTRY_TIME           > '1643709912000'
    AND i.ENTRY_TIME           < '1646129112000'
