-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
            datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day','YYYY-MM-DD'), c.id) AS FROMDATE,
            datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'),'YYYY-MM-DD'), c.id)-1 AS TODATE,
            c.id,
            cea.txt_value as id_delegacion,
            'AFS01' AS codEmpresa
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
                WHEN ilvat.rate IS NOT NULL
                THEN ROUND(ilvat.rate,2)*100 
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
				WHEN credacc.EXTERNAL_ID ='7050033'
                THEN '37'
                WHEN credacc.EXTERNAL_ID ='7050034'
                THEN '38'
				WHEN credacc.EXTERNAL_ID ='7050035'
                THEN '39'
                WHEN credacc.EXTERNAL_ID ='7050036'
                THEN '40'
				WHEN credacc.EXTERNAL_ID ='7050000'
                THEN '41'
				WHEN credacc.EXTERNAL_ID ='70500035'
                THEN '999'
				WHEN credacc.EXTERNAL_ID ='70500037'
                THEN '271'
				WHEN credacc.EXTERNAL_ID ='70500038'
                THEN '272'
				WHEN credacc.EXTERNAL_ID ='70500036'
                THEN '273'
				WHEN credacc.EXTERNAL_ID ='70500039'
                THEN '45'
				WHEN credacc.EXTERNAL_ID ='7590013'
                THEN '44'
				WHEN credacc.EXTERNAL_ID ='70500040'
                THEN '42'
				WHEN credacc.EXTERNAL_ID ='70500041'
                THEN '43'
				WHEN credacc.EXTERNAL_ID ='70500043'
                THEN '46'
				WHEN credacc.EXTERNAL_ID ='70500044'
                THEN '57'
				WHEN credacc.EXTERNAL_ID ='70500045'
                THEN '58'
				WHEN credacc.EXTERNAL_ID ='70500046'
                THEN '59'
				WHEN credacc.EXTERNAL_ID ='70500047'
                THEN '60'
				WHEN credacc.EXTERNAL_ID ='70500048'
                THEN '61'
				WHEN credacc.EXTERNAL_ID ='70500049'
                THEN '62'
				WHEN credacc.EXTERNAL_ID ='70500050'
                THEN '63'
				WHEN credacc.EXTERNAL_ID ='7590014'
                THEN '64'
				WHEN credacc.EXTERNAL_ID ='7590015'
                THEN '65'
				WHEN credacc.EXTERNAL_ID ='70500051'
                THEN '66'
				WHEN credacc.EXTERNAL_ID ='7590016'
                THEN '67'
                WHEN credacc.EXTERNAL_ID = '70500052'
                THEN '47'
                WHEN credacc.EXTERNAL_ID = '70500053'
                THEN '48'
                WHEN credacc.EXTERNAL_ID = '70500054'
                THEN '49'
                WHEN credacc.EXTERNAL_ID = '70500055'
                THEN '50'
                WHEN credacc.EXTERNAL_ID = '70500056'
                THEN '51'
                WHEN credacc.EXTERNAL_ID = '70500057'
                THEN '52'
                WHEN credacc.EXTERNAL_ID = '70500058'
                THEN '53'
                WHEN credacc.EXTERNAL_ID = '70500059'
                THEN '54'
                WHEN credacc.EXTERNAL_ID = '70500060'
                THEN '55'
                WHEN credacc.EXTERNAL_ID = '70500061'
                THEN '68'
                WHEN credacc.EXTERNAL_ID = '70500062'
                THEN '69'
                WHEN credacc.EXTERNAL_ID = '70500063'
                THEN '70'
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
       FROM invoice_lines_mt il
            -- hacer un join con params usando il.center
       JOIN params par
                ON par.id = il.center
       JOIN vivagym.invoices i
                ON il.center = i.center
                AND il.id = i.id
       JOIN vivagym.products prod
                ON prod.center = il.productcenter
                AND prod.id = il.productid
       JOIN vivagym.account_trans act
                ON act.center = il.account_trans_center
                AND act.id = il.account_trans_id
                AND act.subid = il.account_trans_subid
       JOIN vivagym.accounts credacc
                ON act.credit_accountcenter = credacc.center
                AND act.credit_accountid = credacc.id
       JOIN vivagym.accounts debitacc
                ON act.debit_accountcenter = debitacc.center
                AND act.debit_accountid = debitacc.id
       LEFT JOIN vivagym.product_group pg
                ON pg.id = prod.primary_product_group_id
       LEFT JOIN vivagym.persons p
                ON p.center = il.person_center
                AND p.ID = il.person_id
        LEFT JOIN vivagym.cashregisters crg
                ON crg.center = i.cashregister_center
                AND crg.id = i.cashregister_id
        LEFT JOIN vivagym.persons payer
                ON payer.center = i.payer_center
                AND payer.id = i.payer_id
        LEFT JOIN vivagym.invoicelines_vat_at_link ilvat
                ON ilvat.invoiceline_center = il.center
                AND ilvat.invoiceline_id = il.id
                AND ilvat.invoiceline_subid = il.subid
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
                WHEN cnvat.rate IS NOT NULL
                THEN ROUND(cnvat.rate,2)*100 
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
				WHEN debitacc.EXTERNAL_ID ='7050033'
                THEN '37'
                WHEN debitacc.EXTERNAL_ID ='7050034'
                THEN '38'
				WHEN debitacc.EXTERNAL_ID ='7050035'
                THEN '39'
                WHEN debitacc.EXTERNAL_ID ='7050036'
                THEN '40'
				WHEN debitacc.EXTERNAL_ID ='7050000'
                THEN '41'
				WHEN debitacc.EXTERNAL_ID ='70500035'
                THEN '999'
				WHEN debitacc.EXTERNAL_ID ='70500037'
                THEN '271'
				WHEN debitacc.EXTERNAL_ID ='70500038'
                THEN '272'
				WHEN debitacc.EXTERNAL_ID ='70500036'
                THEN '273'
				WHEN debitacc.EXTERNAL_ID ='70500039'
                THEN '45'
				WHEN debitacc.EXTERNAL_ID ='7590013'
                THEN '44'
				WHEN debitacc.EXTERNAL_ID ='70500040'
                THEN '42'
				WHEN debitacc.EXTERNAL_ID ='70500041'
                THEN '43'
				WHEN debitacc.EXTERNAL_ID ='70500043'
                THEN '46'
				WHEN debitacc.EXTERNAL_ID ='70500044'
                THEN '57'
				WHEN debitacc.EXTERNAL_ID ='70500045'
                THEN '58'
				WHEN debitacc.EXTERNAL_ID ='70500046'
                THEN '59'
				WHEN debitacc.EXTERNAL_ID ='70500047'
                THEN '60'
				WHEN debitacc.EXTERNAL_ID ='70500048'
                THEN '61'
				WHEN debitacc.EXTERNAL_ID ='70500049'
                THEN '62'
				WHEN debitacc.EXTERNAL_ID ='70500050'
                THEN '63'
				WHEN debitacc.EXTERNAL_ID ='7590014'
                THEN '64'
				WHEN debitacc.EXTERNAL_ID ='7590015'
                THEN '65'
				WHEN debitacc.EXTERNAL_ID ='70500051'
                THEN '66'
				WHEN debitacc.EXTERNAL_ID ='7590016'
                THEN '67'
                WHEN debitacc.EXTERNAL_ID = '70500052'
                THEN '47'
            WHEN debitacc.EXTERNAL_ID = '70500053'
                THEN '48'
            WHEN debitacc.EXTERNAL_ID = '70500054'
                THEN '49'
            WHEN debitacc.EXTERNAL_ID = '70500055'
                THEN '50'
            WHEN debitacc.EXTERNAL_ID = '70500056'
                THEN '51'
            WHEN debitacc.EXTERNAL_ID = '70500057'
                THEN '52'
            WHEN debitacc.EXTERNAL_ID = '70500058'
                THEN '53'
            WHEN debitacc.EXTERNAL_ID = '70500059'
                THEN '54'
            WHEN debitacc.EXTERNAL_ID = '70500060'
                THEN '55'
                WHEN debitacc.EXTERNAL_ID = '70500061'
                THEN '68'
                WHEN debitacc.EXTERNAL_ID = '70500062'
                THEN '69'
                WHEN debitacc.EXTERNAL_ID = '70500063'
                THEN '70'
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
       FROM vivagym.credit_notes c
       JOIN PARAMS par
                ON par.id = c.center
       JOIN credit_note_lines_mt cl
                ON cl.center = c.center
                AND cl.id = c.id
       JOIN vivagym.products prod
                ON prod.center = cl.productcenter
                AND prod.id = cl.productid
       JOIN vivagym.account_trans act
                ON act.center = cl.account_trans_center
                AND act.id = cl.account_trans_id
                AND act.subid = cl.account_trans_subid
       JOIN vivagym.accounts credacc
                ON act.credit_accountcenter = credacc.center
                AND act.credit_accountid = credacc.id
       JOIN vivagym.accounts debitacc
                ON act.debit_accountcenter = debitacc.center
                AND act.debit_accountid = debitacc.id
       LEFT JOIN vivagym.product_group pg
                ON pg.id = prod.primary_product_group_id
       LEFT JOIN vivagym.persons p
                ON p.center = cl.person_center
                AND p.id = cl.person_id
       LEFT JOIN vivagym.cashregisters crg
                ON crg.center = c.cashregister_center
                AND crg.id = c.cashregister_id
       LEFT JOIN vivagym.persons payer
                ON payer.center = c.payer_center
                AND payer.id = c.payer_id
       LEFT JOIN vivagym.credit_note_line_vat_at_link cnvat
                ON cnvat.credit_note_line_center = cl.center
                AND cnvat.credit_note_line_id = cl.id
                AND cnvat.credit_note_line_subid = cl.subid
      WHERE
            --// anadir condicion from and to respecto a una columna de tiempo
            cl.NET_AMOUNT != 0
            AND c.ENTRY_TIME   > par.FROMDATE
            AND c.ENTRY_TIME   < par.TODATE
            AND c.receipt_id IS NOT NULL ) x
ORDER BY 14,13