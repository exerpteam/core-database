-- The extract is extracted from Exerp on 2026-02-08
--  
        WITH params AS MATERIALIZED
        (
                SELECT
                          dateToLongC(TO_CHAR(TO_DATE(:FechaInicioRegistroPago,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS
                    fromDateLongParam_RegistroPago,
                    dateToLongC(TO_CHAR(TO_DATE(:FechaFinRegistroPago,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) + (24*60*60*1000) -1 AS toDateLongParam_RegistroPago,
                          TO_DATE(:FechaInicioPago,'YYYY-MM-DD') AS fromDateParam_Pago,
                         TO_DATE(:FechaFinPago,'YYYY-MM-DD') AS toDateParam_Pago,
            c.id AS center_id,
                        c.name as center_name
                FROM 
                        vivagym.centers c
                WHERE
                        c.country = 'ES'   
						AND c.id IN (:Scope)
        )
        SELECT
                p.center || 'p' || p.id AS personid,
                p.external_id as external_id,
                p.fullname,
                CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' 
                                  WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' 
                                  WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS persontype,
                CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' 
                              WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' 
                              ELSE 'Undefined' END AS person_status,
                spp.center as club,
                pr.name AS product_name,
                spp.from_date AS Fecha_pago_Inicio,
                spp.to_date AS Fecha_pago_fin,
                TO_CHAR(TO_TIMESTAMP(i.entry_time / 1000), 'DD/MM/YYYY HH24:MI:SS') AS Fecha_registro_pago,
                ROUND(il.net_amount,2)  invoice_line_net_amount,
                ROUND(il.TOTAL_AMOUNT, 2)  invoice_line_total_amount,
                il.text AS invoice_text, 
                CASE
                WHEN spp.cancellation_time = 0 
                THEN '0'
                ELSE TO_CHAR(TO_TIMESTAMP(spp.cancellation_time / 1000), 'DD/MM/YYYY HH24:MI:SS') 
            END                                     "Fecha_cancelacion_pago",
           CASE
                WHEN pr.PTYPE = 7 THEN '11' -- if freeze product then 11
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
                ELSE '99'
            END                    "IdConcepto"                    
        FROM vivagym.invoices i
        JOIN params par ON i.center = par.center_id
        JOIN vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
        JOIN vivagym.spp_invoicelines_link spl ON spl.invoiceline_center = il.center AND spl.invoiceline_id = il.id AND spl.invoiceline_subid = il.subid
        JOIN vivagym.subscriptionperiodparts spp ON spl.period_center = spp.center AND spl.period_id = spp.id AND spl.period_subid = spp.subid
        JOIN vivagym.subscriptions s ON spp.center = s.center AND spp.id = s.id
        JOIN vivagym.persons p ON s.owner_center = p.center AND s.owner_id = p.id
        JOIN vivagym.products pr ON s.subscriptiontype_center = pr.center AND s.subscriptiontype_id = pr.id
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
        WHERE 
                i.entry_time between par.fromDateLongParam_RegistroPago AND par.toDateLongParam_RegistroPago
             --   AND spp.cancellation_time = 0
               AND spp.to_date between par.fromDateParam_Pago AND par.toDateParam_Pago
               AND spp.from_date between par.fromDateParam_Pago AND par.toDateParam_Pago