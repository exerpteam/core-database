WITH params AS MATERIALIZED(
      SELECT
        datetolongC(
    TO_CHAR(DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - INTERVAL '1 month'), 
    'YYYY-MM-DD'), c.id
) AS FROMDATE,

datetolongC(
    TO_CHAR(
        (DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))),
    'YYYY-MM-DD'), c.id
) AS TODATE,

c.id,
            cea.txt_value as id_delegacion,
            '1' AS codEmpresa
        FROM centers c 
        LEFT JOIN center_ext_attrs cea ON cea.center_id = c.id AND cea.name = 'IdDelegacion'
        WHERE 
			c.id IN (:Scope)
			AND c.country = 'ES'
)
SELECT
    "ContractNo"  ,
    "CodigoEmpresa",
    "IdDelegacion",
    --"IS_COMPANY",
    --"SALE_PERSON_ID",
    --"ENTRY_DATETIME",
    "FechaFactura",
    "CifDni"      ,
    "SiglaNacion" ,
    "CifEuropeo"  ,
    "RazonSocial" ,
    "RazonSocial2",
    "Domicilio"   ,
    "Domicilio2"  ,
    "CodigoPostal",
    "SerieFactura",
    "NumeroFactura2",
    "Observaciones" ,
    --"PRODUCT_CENTER",
    --"PRODUCT_ID",
    --"PRODUCT_NORMAL_PRICE",
    --"SPONSOR_SALE_LOG_ID",
    --"GL_DEBIT_ACCOUNT",
    "IdConcepto"        ,
    "Unidades"          ,
    "Precio"            ,
    "ImporteLiquido"    ,
    "PorIva1"           ,
    "CuotaIva1"         ,
    "PorIva2"           ,
    "CuotaIva2"         ,
    "BaseIva1"          ,
    "BaseIva2"          ,
    "BaseImponible"     ,
    "ImporteDRevenue"   ,
    "ImporteCMRevenue"  ,
    "PreviousMRevenue"  ,
    "NetDeferredRevenue",
    "TotalMRevenue"     ,
    --"SALE_COMMISSION",
    --"SALE_UNITS",
    --"PERIOD_COMMISSION",
    --"SOURCE_TYPE",
    --"CREDIT_SALE_LOG_ID",
    --"CASH_REGISTER_CENTER_ID",
    "Fecha",
    "FechaEnvio",
    count(*) over (partition BY 1) AS line_number,
    "FechaEnvio",
    --"FLAT_RATE_COMMISSION",
    --"EXTERNAL_ID",
    --"PAYER_PERSON_ID",
    "ExerpID"
    --"AGGREGATED_TRANSACTION_KEY",
    
FROM
    (
     SELECT
            il.CENTER || 'inv' || il.ID || 'ln' || il.SUBID "NumeroFactura",
            par.id_delegacion                                        "IdDelegacion" , -- Ahora apunta al
            par.codEmpresa "CodigoEmpresa",
            -- centro pero debería apuntar al ext att del centro = DelegacionID
            i.CENTER "SerieFactura",
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
            END "ContractNo",
            CAST(
                CASE
                    WHEN payer.SEX = 'C'
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                     "IS_COMPANY"  ,
            'ES' AS                           "SiglaNacion" ,
        -- Reemplazamos " y ; para evitar problemas con los archivos csv
            substring(REPLACE(REPLACE(payer.firstname, ';',' '), '"',' ') || ' ' || REPLACE(REPLACE(payer.lastname, ';',' '), '"',' '),1,40) "RazonSocial" ,
            substring(REPLACE(REPLACE(payer.firstname, ';',' '), '"',' ') || ' ' || REPLACE(REPLACE(payer.lastname, ';',' '), '"',' '),41,40) "RazonSocial2" ,
            CASE
                WHEN payer.national_id IS NOT NULL
                THEN payer.national_id
                ELSE NULL
            END "CifDni",
            CASE
                WHEN payer.national_id IS NOT NULL
                THEN CONCAT(payer.country,payer.national_id)
                ELSE NULL
            END                                               "CifEuropeo"    ,
            -- Reemplazamos " y ; para evitar problemas con los archivos csv
            substring(REPLACE(REPLACE(payer.address1, ';',' '), '"',' '),1,40)          "Domicilio"     ,
            substring(REPLACE(REPLACE(payer.address1, ';',' '), '"',' '),41,40)        "Domicilio2"    ,
   
            payer.zipcode                                                "CodigoPostal"  ,
            CASE
                WHEN vat.rate IS NOT NULL
                THEN ROUND(vat.rate,2)*100 
                ELSE '0'
            END                                     "PorIva1"       ,
            i.ENTRY_TIME                                                 "ENTRY_DATETIME",
            TO_CHAR(longtodatec(i.ENTRY_TIME ,i.CENTER),'yyyy-MM-dd') AS "FechaFactura"        ,
            prod.CENTER                                                  "PRODUCT_CENTER"      ,
            prod.CENTER || 'prod' || prod.ID                             "PRODUCT_ID"          ,
            BI_DECODE_FIELD('PRODUCTS','PTYPE',prod.PTYPE)  AS            "Observaciones"       ,
            il.PRODUCT_NORMAL_PRICE                         AS            "PRODUCT_NORMAL_PRICE",
            il.QUANTITY                                     AS            "Unidades"            ,
            ROUND(il.net_amount,2)                          AS            "Precio"              ,
            ROUND(il.net_amount,2)                          AS            "BaseIva1"            ,
            ROUND(il.net_amount,2)                          AS            "BaseImponible"       ,
            ROUND(il.TOTAL_AMOUNT,2)-ROUND(il.net_amount,2) AS            "CuotaIva1"           ,
            '0'                                             AS            "BaseIva2"            ,
            '0'                                             AS            "CuotaIva2"           ,
            '0'                                             AS            "PorIva2"             ,
            ROUND(il.TOTAL_AMOUNT, 2)                       AS            "ImporteLiquido"      ,
            '0'                                             AS            "ImporteDRevenue"     ,
            ROUND(il.net_amount,2)                          AS            "ImporteCMRevenue"    ,
            '0'                                             AS            "PreviousMRevenue"    ,
            '0'                                             AS            "NetDeferredRevenue"  ,
            ROUND(il.net_amount,2)                          AS            "TotalMRevenue"       ,
            CASE
                WHEN il.SPONSOR_INVOICE_SUBID IS NOT NULL
                THEN i.SPONSOR_INVOICE_CENTER || 'inv' || i.SPONSOR_INVOICE_ID || 'ln' ||
                    il.SPONSOR_INVOICE_SUBID
                ELSE NULL
            END                  "SPONSOR_SALE_LOG_ID",
            debitacc.EXTERNAL_ID "GL_DEBIT_ACCOUNT"   ,
            CASE
				WHEN prod.PTYPE = 7 
     			AND credacc.EXTERNAL_ID IN ('7050030', '7050031')
				THEN '46'
WHEN prod.PTYPE = 7 THEN '11'
				WHEN credacc.EXTERNAL_ID ='7590000'
                THEN '19'
                WHEN credacc.EXTERNAL_ID ='7050001'
                THEN '6'
                WHEN credacc.EXTERNAL_ID ='7050002'
                THEN '1'
                WHEN credacc.EXTERNAL_ID ='7050003'
                THEN '2'
                WHEN credacc.EXTERNAL_ID ='7050004'
                THEN '3'
                WHEN credacc.EXTERNAL_ID ='7050005'
                THEN '4'
                WHEN credacc.EXTERNAL_ID ='7050006'
                THEN '5'
                WHEN credacc.EXTERNAL_ID ='7050007'
                THEN '1'
                WHEN credacc.EXTERNAL_ID ='7050008'
                THEN '9'
                WHEN credacc.EXTERNAL_ID ='7590002'
                THEN '9'
                WHEN credacc.EXTERNAL_ID ='7050009'
                THEN '13'
                WHEN credacc.EXTERNAL_ID ='7050010'
                THEN '7'
                WHEN credacc.EXTERNAL_ID ='7050011'
                THEN '8'
                WHEN credacc.EXTERNAL_ID ='7050012'
                THEN '12'
                WHEN credacc.EXTERNAL_ID ='7050013'
                THEN '14'
                WHEN credacc.EXTERNAL_ID ='7050014'
                THEN '11'
                WHEN credacc.EXTERNAL_ID ='7050015'
                THEN '10'
                WHEN credacc.EXTERNAL_ID ='7050016'
                THEN '15'
                WHEN credacc.EXTERNAL_ID ='7050021'
                THEN '16'
                WHEN credacc.EXTERNAL_ID ='7590001'
                THEN '17'
                WHEN credacc.EXTERNAL_ID ='7050022'
                THEN '18'
				WHEN credacc.EXTERNAL_ID ='7590007'
                THEN '25'
                WHEN credacc.EXTERNAL_ID ='7590006'
                THEN '24'
                WHEN credacc.EXTERNAL_ID ='7050023'
                THEN '20'
                WHEN credacc.EXTERNAL_ID ='7050024'
                THEN '21'
                WHEN credacc.EXTERNAL_ID ='7050025'
                THEN '22'
                WHEN credacc.EXTERNAL_ID ='7050026'
                THEN '23'
                WHEN credacc.EXTERNAL_ID ='7050027'
                THEN '26'
                WHEN credacc.EXTERNAL_ID ='7050028'
                THEN '27'
                WHEN credacc.EXTERNAL_ID ='7050029'
                THEN '28'
                WHEN credacc.EXTERNAL_ID ='7590008'
                THEN '32'
                WHEN credacc.EXTERNAL_ID ='7590009'
                THEN '33'
                WHEN credacc.EXTERNAL_ID ='7590011'
                THEN '35'
                WHEN credacc.EXTERNAL_ID ='7050030'
                THEN '29'
                WHEN credacc.EXTERNAL_ID ='7050032'
                THEN '31'
                WHEN credacc.EXTERNAL_ID ='7050031'
                THEN '30'
                WHEN credacc.EXTERNAL_ID ='7590010'
                THEN '34'
                WHEN credacc.EXTERNAL_ID ='7590012'
                THEN '36'
				WHEN credacc.EXTERNAL_ID ='70500039'
                THEN '45'
				WHEN credacc.EXTERNAL_ID ='7590013'
                THEN '44'
				WHEN credacc.EXTERNAL_ID ='70500040'
                THEN '42'
				WHEN credacc.EXTERNAL_ID ='70500041'
                ELSE '99'
            END                    "IdConcepto"                    ,
            il.sales_commission        AS "SALE_COMMISSION"        ,
            il.sales_units             AS "SALE_UNITS"             ,
            il.period_commission       AS "PERIOD_COMMISSION"      ,
            COALESCE(crg.TYPE,'OTHER') AS "SOURCE_TYPE"            ,
            NULL                       AS "CREDIT_SALE_LOG_ID"     ,
            il.center||'0'||il.ID||'0'||il.subid  AS "ExerpID"                , --  
            crg.center                 AS "CASH_REGISTER_CENTER_ID",
            to_char(longtodatec(i.TRANS_TIME,i.CENTER),'DD/MM/YYYY HH24:MI')                  "Fecha"                    ,
            to_char(longtodatec(i.ENTRY_TIME,i.CENTER),'DD/MM/YYYY HH24:MI')       "FechaEnvio"                    ,
            il.flat_rate_commission AS    "FLAT_RATE_COMMISSION"   ,
            il.external_id          AS    "EXTERNAL_ID"            ,
            i.receipt_id            AS    "NumeroFactura2"         ,
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
            params par
         ON
            par.id = il.center
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
            
            il.NET_AMOUNT != '0'
            AND i.ENTRY_TIME   > par.FROMDATE
            AND i.ENTRY_TIME   < par.TODATE
            AND i.receipt_id IS NOT NULL
			AND i.text != 'Converted subscription invoice'
  UNION ALL
     SELECT
            cl.CENTER || 'cred' || cl.ID || 'cnl' || cl.SUBID "NumeroFactura",
            par.id_delegacion                                          "IdDelegacion" , -- Ahora apunta al
            par.codEmpresa "CodigoEmpresa",
            -- centro pero debería apuntar al ext att del centro = DelegacionID
            c.CENTER "SerieFactura",
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
            END "ContractNo",
            CAST(
                CASE
                    WHEN payer.SEX = 'C'
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                     "IS_COMPANY"  ,
            'ES' AS                           "SiglaNacion" ,
        -- Reemplazamos " y ; para evitar problemas con los archivos csv
            substring(REPLACE(REPLACE(payer.firstname, ';',' '), '"',' ') || ' ' || REPLACE(REPLACE(payer.lastname, ';',' '), '"',' '),1,40) "RazonSocial" ,
            substring(REPLACE(REPLACE(payer.firstname, ';',' '), '"',' ') || ' ' || REPLACE(REPLACE(payer.lastname, ';',' '), '"',' '),41,40) "RazonSocial2" ,
            CASE
                WHEN payer.national_id IS NOT NULL
                THEN payer.national_id
                ELSE NULL
            END "CifDni",
            CASE
                WHEN payer.national_id IS NOT NULL
                THEN CONCAT(payer.country,payer.national_id)
                ELSE NULL
            END                                               "CifEuropeo"    ,
            -- Reemplazamos " y ; para evitar problemas con los archivos csv
            substring(REPLACE(REPLACE(payer.address1, ';',' '), '"',' '),1,40)          "Domicilio"     ,
            substring(REPLACE(REPLACE(payer.address1, ';',' '), '"',' '),41,40)        "Domicilio2"    ,
   
            payer.zipcode                                                "CodigoPostal"  ,
            CASE
                WHEN vat.rate IS NOT NULL
                THEN ROUND(vat.rate,2)*100 
                ELSE '0'
            END                                     "PorIva1"       ,
            c.ENTRY_TIME                                                 "ENTRY_DATETIME",
            TO_CHAR(longtodatec(c.ENTRY_TIME ,c.CENTER),'yyyy-MM-dd') AS "FechaFactura"        ,
            prod.CENTER                                                  "PRODUCT_CENTER"      ,
            prod.CENTER || 'prod' || prod.ID                             "PRODUCT_ID"          ,
            BI_DECODE_FIELD('PRODUCTS','PTYPE',prod.PTYPE)   AS            "Observaciones"       ,
            NULL                                             AS            "PRODUCT_NORMAL_PRICE",
            - cl.QUANTITY                                    AS            "Unidades"            ,
            -ROUND(cl.net_amount,2)                          AS            "Precio"              ,
            -ROUND(cl.net_amount,2)                          AS            "BaseIva1"            ,
            -ROUND(cl.net_amount,2)                          AS            "BaseImponible"       ,
            -ROUND(cl.TOTAL_AMOUNT,2)+ROUND(cl.net_amount,2) AS            "CuotaIva1"           ,
            '0'                                              AS            "CuotaIva2"           ,
            '0'                                              AS            "PorIva2"             ,
            '0'                                              AS            "BaseIva2"            ,
            -ROUND(cl.TOTAL_AMOUNT, 2)                       AS            "ImporteLiquido"      ,
            '0'                                              AS            "ImporteDRevenue"     ,
            -ROUND(cl.net_amount,2)                          AS            "ImporteCMRevenue"    ,
            '0'                                              AS            "PreviousMRevenue"    ,
            '0'                                              AS            "NetDeferredRevenue"  ,
            ROUND(cl.net_amount,2)                           AS            "TotalMRevenue"       ,
            NULL                                             AS            "SPONSOR_SALE_LOG_ID" ,
            debitacc.EXTERNAL_ID                                           "GL_DEBIT_ACCOUNT"    ,
            CASE
				WHEN prod.PTYPE = 7 
     			AND debitacc.EXTERNAL_ID IN ('7050030', '7050031')
				THEN '46' 
                WHEN prod.PTYPE = 7 THEN '11' -- if freeze product then 11
				WHEN debitacc.EXTERNAL_ID ='7590000'
                THEN '19'
                WHEN debitacc.EXTERNAL_ID ='7050001'
                THEN '6'
                WHEN debitacc.EXTERNAL_ID ='7050002'
                THEN '1'
                WHEN debitacc.EXTERNAL_ID ='7050003'
                THEN '2'
                WHEN debitacc.EXTERNAL_ID ='7050004'
                THEN '3'
                WHEN debitacc.EXTERNAL_ID ='7050005'
                THEN '4'
                WHEN debitacc.EXTERNAL_ID ='7050006'
                THEN '5'
                WHEN debitacc.EXTERNAL_ID ='7050007'
                THEN '1'
                WHEN debitacc.EXTERNAL_ID ='7050008'
                THEN '9'
                WHEN debitacc.EXTERNAL_ID ='7590002'
                THEN '9'
                WHEN debitacc.EXTERNAL_ID ='7050009'
                THEN '13'
                WHEN debitacc.EXTERNAL_ID ='7050010'
                THEN '7'
                WHEN debitacc.EXTERNAL_ID ='7050011'
                THEN '8'
                WHEN debitacc.EXTERNAL_ID ='7050012'
                THEN '12'
                WHEN debitacc.EXTERNAL_ID ='7050013'
                THEN '14'
                WHEN debitacc.EXTERNAL_ID ='7050014'
                THEN '11'
                WHEN debitacc.EXTERNAL_ID ='7050015'
                THEN '10'
                WHEN debitacc.EXTERNAL_ID ='7050016'
                THEN '15'
                WHEN debitacc.EXTERNAL_ID ='7050021'
                THEN '16'
                WHEN debitacc.EXTERNAL_ID ='7590001'
                THEN '17'
                WHEN debitacc.EXTERNAL_ID ='7050022'
                THEN '18'
				WHEN debitacc.EXTERNAL_ID ='7590007'
                THEN '25'
                WHEN debitacc.EXTERNAL_ID ='7590006'
                THEN '24'
                WHEN debitacc.EXTERNAL_ID ='7050023'
                THEN '20'
                WHEN debitacc.EXTERNAL_ID ='7050024'
                THEN '21'
                WHEN debitacc.EXTERNAL_ID ='7050025'
                THEN '22'
                WHEN debitacc.EXTERNAL_ID ='7050026'
                THEN '23'
                WHEN debitacc.EXTERNAL_ID ='7050027'
                THEN '26'
                WHEN debitacc.EXTERNAL_ID ='7050028'
                THEN '27'
                WHEN debitacc.EXTERNAL_ID ='7050029'
                THEN '28'
                WHEN debitacc.EXTERNAL_ID ='7590008'
                THEN '32'
                WHEN debitacc.EXTERNAL_ID ='7590009'
                THEN '33'
                WHEN debitacc.EXTERNAL_ID ='7590011'
                THEN '35'
                WHEN debitacc.EXTERNAL_ID ='7050030'
                THEN '29'
                WHEN debitacc.EXTERNAL_ID ='7050032'
                THEN '31'
                WHEN debitacc.EXTERNAL_ID ='7050031'
                THEN '30'
                WHEN debitacc.EXTERNAL_ID ='7590010'
                THEN '34'
                WHEN debitacc.EXTERNAL_ID ='7590012'
                THEN '36'
				WHEN debitacc.EXTERNAL_ID ='70500039'
                THEN '45'
				WHEN debitacc.EXTERNAL_ID ='7590013'
                THEN '44'
				WHEN debitacc.EXTERNAL_ID ='70500040'
                THEN '42'
				WHEN debitacc.EXTERNAL_ID ='70500041'
                ELSE '99'
            END                    "IdConcepto"        ,
            cl.sales_commission                                AS "SALE_COMMISSION"  ,
            cl.sales_units                                     AS "SALE_UNITS"       ,
            cl.period_commission                                 AS "PERIOD_COMMISSION",
            COALESCE(crg.TYPE,'OTHER')                                       AS "SOURCE_TYPE"      ,
            cl.INVOICELINE_CENTER||'inv'||cl.INVOICELINE_ID||'ln'||cl.INVOICELINE_SUBID AS
                                            "CREDIT_SALE_LOG_ID"   ,
            cl.CENTER || '1' || cl.ID || '1' || cl.SUBID  AS "ExerpID"                ,
            crg.center                   AS "CASH_REGISTER_CENTER_ID",
            to_char(longtodatec(c.ENTRY_TIME,c.CENTER),'DD/MM/YYYY HH24:MI')                  "Fecha"                    ,
            to_char(longtodatec(c.ENTRY_TIME,c.CENTER),'DD/MM/YYYY HH24:MI')       "FechaEnvio"                    ,
            cl.flat_rate_commission AS      "FLAT_RATE_COMMISSION"   ,
            NULL                    AS      "EXTERNAL_ID"            ,
            c.receipt_id            AS      "NumeroFactura2"         ,
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
            CREDIT_NOTES c
       JOIN
            PARAMS par
         ON
            par.id = c.center
       JOIN
            credit_note_lines_mt cl
         ON
            cl.center = c.center
            AND cl.id = c.id
       JOIN
            PRODUCTS prod
         ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
       JOIN
            ACCOUNT_TRANS act
         ON
            act.CENTER    = cl.ACCOUNT_TRANS_CENTER
            AND act.ID    = cl.ACCOUNT_TRANS_ID
            AND act.SUBID = cl.ACCOUNT_TRANS_SUBID
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
            p.center = cl.PERSON_CENTER
            AND p.ID = cl.PERSON_ID
  LEFT JOIN
            CASHREGISTERS crg
         ON
            crg.CENTER = c.CASHREGISTER_CENTER
            AND crg.ID = c.CASHREGISTER_ID
  LEFT JOIN
            PERSONS payer
         ON
            payer.center = c.PAYER_CENTER
            AND payer.id = c.PAYER_ID
LEFT JOIN
            ACCOUNT_VAT_TYPE_GROUP vatg
         ON
            vatg.account_center = debitacc.center
            AND vatg.account_id = debitacc.id
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
            --// anadir condicion from and to respecto a una columna de tiempo
            cl.NET_AMOUNT != 0
            AND c.ENTRY_TIME   > par.FROMDATE
            AND c.ENTRY_TIME   < par.TODATE
            AND c.receipt_id IS NOT NULL ) x
ORDER BY 14,13