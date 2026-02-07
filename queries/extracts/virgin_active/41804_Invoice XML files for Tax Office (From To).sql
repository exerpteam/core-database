/**************************/
/* 1.XML Generation       */
/* 2.SELECT EFT invoices  */
/* 3.SELECT POS invoices  */
/**************************/
WITH
    Unique_No AS
    (
    -- PLEASE note that Extract ID should be same the current extract !!
    -- This may differ from TEST and PROD
        SELECT sum(ROWS_RETURNED) as prev_sum
        FROM extract_usage
        WHERE extract_id in (42001,41804, 42801)
    )
    
SELECT
       data_for_Xml."Anagrafica" "Member ID" ,
    data_for_Xml."Numero" "Invoice Nr",
  
    replace(replace(replace(replace(replace(replace(replace(concat(concat(concat('<?xml version="1.0" encoding="UTF-8"?><FatturaElettronica xmlns'||chr(58)||'xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns'||chr(58)||'xsd="http://www.w3.org/2001/XMLSchema" versione="FPR12" xmlns="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2">',
      
      -- Header
      xmlelement(name "FatturaElettronicaHeader", 
            xmlelement(name "DatiTrasmissione", 
                xmlelement(name "IdTrasmittente", 
                     xmlelement(name "IdPaese",data_for_Xml."IdPaese"), 
                     xmlelement(name "IdCodice", data_for_Xml."IdCodice_Intesa")
                ), 
                xmlelement(name "ProgressivoInvio", to_char(Unique_No.prev_sum + rownum, 'FMXXXXXXX')), 
                xmlelement(name "FormatoTrasmissione",data_for_Xml."FormatoTrasmissione"), 
                xmlelement(name "CodiceDestinatario", data_for_Xml."CodiceDestinatario")
            ), 
            xmlelement(name "CedentePrestatore",
                xmlelement(name "DatiAnagrafici",
                   xmlelement(name "IdFiscaleIVA",
                       xmlelement(name "IdPaese", data_for_Xml."IdPaese"),
                       xmlelement(name "IdCodice", data_for_Xml."IdCodice")    
                   
                   
                   ),
                   xmlelement(name "Anagrafica",
                       xmlelement(name "Denominazione", data_for_Xml."Denominazione_VAI")
                   ),
                   xmlelement(name "RegimeFiscale",  data_for_Xml."RegimeFiscale")
                ),
                xmlelement(name "Sede",
                   xmlelement(name "Indirizzo", replace(data_for_Xml."Indirizzo1",'°',' ')),
                   xmlelement(name "CAP", data_for_Xml."CAP1"),
                   xmlelement(name "Comune", data_for_Xml."Comune1"),
                   xmlelement(name "Nazione", data_for_Xml."Nazione1")
                   )
                
            ),
            xmlelement(name "CessionarioCommittente",
                xmlelement(name "DatiAnagrafici",
				   xmlelement(name "IdFiscaleIVA",
                       xmlelement(name "IdPaese", DECODE(data_for_Xml."IdCodice_Comment",null,null,data_for_Xml."IdPaese")),
                       xmlelement(name "IdCodice", data_for_Xml."IdCodice_Comment")    
                   ),
                   xmlelement(name "CodiceFiscale", data_for_Xml."CodiceFiscale"),
                   xmlelement(name "Anagrafica", 
                      xmlelement(name "Denominazione", data_for_Xml."Denominazione_Cust")
                   )
                ),
               xmlelement(name "Sede",
                  xmlelement(name "Indirizzo", replace(data_for_Xml."Indirizzo2",'°',' ')),
                  xmlelement(name "CAP", data_for_Xml."CAP2"),
                  xmlelement(name "Comune", data_for_Xml."Comune2"),
                 xmlelement(name "Nazione", data_for_Xml."Nazione2")
              )
         ),
         xmlelement(name "TerzoIntermediarioOSoggettoEmittente",
              xmlelement(name "DatiAnagrafici",
                   xmlelement(name "IdFiscaleIVA",
                       xmlelement(name "IdPaese", data_for_Xml."IdPaese"),
                       xmlelement(name "IdCodice", data_for_Xml."IdCodice_Intesa")    
                   ),
                   xmlelement(name "Anagrafica",
                       xmlelement(name "Denominazione", 'Intesa Spa')
              )
              )
              ),
        xmlelement (name "SoggettoEmittente", 'TZ')      
    ).getStringVal()),
	'<FatturaElettronicaBody xmlns="">'),
	xmlelement(name "DatiGenerali",
            xmlelement(name "DatiGeneraliDocumento",
                xmlelement(name "TipoDocumento", data_for_Xml."TipoDocumento"),
                xmlelement(name "Divisa", data_for_Xml."Divisa"),
                xmlelement(name "Data", data_for_Xml."Data"),
                xmlelement(name "Numero", data_for_Xml."Numero"),
                xmlelement(name "ImportoTotaleDocumento", data_for_Xml."ImportoTotaleDocumento")
           )
        ).getStringVal() || '<DatiBeniServizi>')
            
    , '<FatturaElettronicaHeader>','<FatturaElettronicaHeader xmlns="">')
    , '&apos;','''')
	, '''', ' ')
	,'&amp;',' ')
	,'&',' ')
	,'<IdFiscaleIVA><IdPaese></IdPaese><IdCodice></IdCodice></IdFiscaleIVA>','')
	,'<CodiceFiscale></CodiceFiscale>','')
	
   AS headerXml,

   -- Body (invoicelines)
   replace(
    replace(
    replace(
     replace(
      replace(
	    CASE when data_for_Xml.LineNo = 1 AND length(trim(data_for_Xml."email")) is not null THEN
	      replace(data_for_Xml."AllInvoiceLines".getStringVal(),
	      '<AltriDatiGestionali>', '<AltriDatiGestionali><TipoDato>e-mail</TipoDato><RiferimentoTesto>'||data_for_Xml."email"||
		  '</RiferimentoTesto><RiferimentoNumero>'||data_for_Xml.RiferimentoNumero ||'</RiferimentoNumero></AltriDatiGestionali><AltriDatiGestionali>')
		ELSE
		  data_for_Xml."AllInvoiceLines".getStringVal()
		END
	  ,'&apos;','''')
	  ,'''','')
	  ,'&amp;',' ')
	  ,'quot;','"')
	,'&',' ') AS bodyXML,
   

   
   --Footer
   replace(replace(replace(
    concat( 
                xmlelement(name "DatiRiepilogo",
				CASE WHEN INSTR(data_for_Xml."AllInvoiceLines".getStringVal(),'Commissioni') > 0 THEN
				    xmlelement(name "AliquotaIVA", '0.00')
				ELSE CASE WHEN INSTR(data_for_Xml."AllInvoiceLines".getStringVal(),'Diplomati') > 0 THEN
					xmlelement(name "AliquotaIVA", '0.00')
				ELSE
				    xmlelement(name "AliquotaIVA", '22.00')
				END END,
				CASE WHEN INSTR(data_for_Xml."AllInvoiceLines".getStringVal(),'Commissioni') > 0 THEN
				    xmlelement(name "Natura",'N1')
				ELSE CASE WHEN INSTR(data_for_Xml."AllInvoiceLines".getStringVal(),'Diplomati') > 0 THEN
					xmlelement(name "Natura",'N3')
				END END,
                xmlelement(name "ImponibileImporto", data_for_Xml."ImponibileImporto"),    
                xmlelement(name "Imposta", data_for_Xml."Imposta")    
            ).getStringVal()
    ,
    '</DatiBeniServizi></FatturaElettronicaBody></FatturaElettronica>'
    )
    , '&apos;','''')
	,'&amp;',' ')
	,'&',' ') 
	
    AS footerXml,

    data_for_Xml."IdCodice_Intesa"  AS "IdCodice",
    to_char(Unique_No.prev_sum + rownum, 'FMXXXXXXX') AS "ProgressivoInvio"	
	 
FROM 
 Unique_No, 
(
SELECT
    'IT' AS "IdPaese", --fixed
    CASE 
	  WHEN REGEXP_INSTR(pcomment.TXTVALUE,'[^0-9]') > 0  THEN null 
	  WHEN (SUBSTR(pcomment.TXTVALUE,1,1) = '9')  THEN null
      WHEN (SUBSTR(pcomment.TXTVALUE,1,1) = '8')  THEN null
	  ELSE pcomment.TXTVALUE
	END "IdCodice_Comment",
    '05262890014'  AS "IdCodice_Intesa", --fixed
    'FPR12' "FormatoTrasmissione", --fixed
    DECODE(codice.TXTVALUE,null,'0000000',codice.TXTVALUE) "CodiceDestinatario",
    DECODE(p.center, 209, '06371530962',  223, '03032340980',224, '03032340980',225, '03032340980', 229, '09634340963', '03641880962' )  "IdCodice",
    DECODE(p.center, 209, 'Club Milano Corso Como S.r.l.' ,  223,'Club Milano City S.r.l.',224,'Club Milano City S.r.l.',225,'Club Milano City S.r.l.',229, 'Revolution s.r.l. Unipersonale', 'Virgin Active Italia S.pa.' )  "Denominazione_VAI",
    CASE 
        WHEN (REGEXP_INSTR(pcomment.TXTVALUE,'[^0-9]') > 0) THEN p.SSN
        WHEN (pcomment.TXTVALUE IS NULL)  THEN p.SSN
        WHEN (SUBSTR(pcomment.TXTVALUE,1,1) = '9')  THEN pcomment.TXTVALUE
        WHEN (SUBSTR(pcomment.TXTVALUE,1,1) = '8')  THEN pcomment.TXTVALUE
	END AS "CodiceFiscale",
	--p.SSN AS "CodiceFiscale",
    p.center||'p'||p.id "Anagrafica",
    NVL(invname.TXTVALUE, p.FULLNAME) "Denominazione_Cust",
    NVL(invadr1.TXTVALUE, p.ADDRESS1)  "Indirizzo2",
    NVL(invzip.TXTVALUE, p.ZIPCODE) "CAP2",
    NVL(invcity.TXTVALUE, p.CITY) "Comune2",
    NVL(invnation.TXTVALUE, p.COUNTRY) "Nazione2",
    'TD01' AS "TipoDocumento", --fixed
    'EUR' AS "Divisa",  --fixed
    'RF01' AS "RegimeFiscale", --fixed
    'Via Privata Archimede 2' "Indirizzo1",
    '20094' "CAP1",
    'Corsico' "Comune1",
    'IT' "Nazione1",
    '22.00' AS "AliquotaIVA",   --fixed VAT 22.00
	email.TXTVALUE AS "email",
    both_pos_and_eft.*
FROM
(
( /************************* POS invoices ************************/ 
SELECT
    pos_part.PersonCenter,
    pos_part.PersonID,
    pos_part."Numero",
    TO_CHAR(longtodateTZ(pos_part."Data", 'Europe/Rome'),'YYYY-MM-DD')  "Data",
    pos_details."AllInvoiceLines",
	pos_details.LineNo,
	pos_details.RiferimentoNumero,
    TO_CHAR(pos_part."ImponibileImporto", 'FM99999990.00') as "ImponibileImporto",
    TO_CHAR(pos_part."Imposta", 'FM99999990.00') as "Imposta",
    TO_CHAR(pos_part."ImponibileImporto" + pos_part."Imposta", 'FM99999990.00') as "ImportoTotaleDocumento"
FROM

(
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR($$Start_Date$$,'YYYY-MM-DD HH24:MI'), 'Europe/Rome')             AS StartDateLong,
            datetolongTZ(TO_CHAR($$End_Date$$,'YYYY-MM-DD HH24:MI'), 'Europe/Rome')+24*3600*1000  AS EndDateLong        
        FROM  dual
    )
SELECT 
    personcenter, 
    personid, 
    "Data", 
    "Numero",   
    SUM(NET_AMOUNT) AS "ImponibileImporto",
    SUM(TOTAL_AMOUNT) - SUM(NET_AMOUNT) AS "Imposta"
FROM
(
SELECT
    cp.CENTER PersonCenter,
    cp.ID  PersonId,
    i.TRANS_TIME "Data",
    ci.INVOICE_REFERENCE "Numero",
    il.NET_AMOUNT,
    il.TOTAL_AMOUNT
FROM
    PARAMS
CROSS JOIN
    CUSTOMER_INVOICE ci
JOIN
    INVOICE_LINES_MT il
ON 
    ci.REFERENCE_CENTER= il.CENTER
    AND ci.REFERENCE_ID = il.ID
JOIN
    INVOICES i
ON
    ci.REFERENCE_CENTER= i.CENTER
    AND ci.REFERENCE_ID = i.ID
JOIN 
    PERSONS p
ON
    ci.PERSON_CENTER = p.center
    AND ci.PERSON_ID = p.ID
JOIN 
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.ID = p.CURRENT_PERSON_ID
WHERE 
   i.TRANS_TIME  >= params.StartDateLong
   AND i.TRANS_TIME < params.EndDateLong
UNION ALL
--credit notes
SELECT
    cp.CENTER PersonCenter,
    cp.ID  PersonId,
    cn.TRANS_TIME "Data",
    ci.INVOICE_REFERENCE "Numero",
    -cl.NET_AMOUNT,
    -cl.TOTAL_AMOUNT
FROM
    PARAMS
CROSS JOIN
    CUSTOMER_INVOICE ci
JOIN
    CREDIT_NOTE_LINES_MT cl
ON 
    ci.REFERENCE_CENTER= cl.CENTER
    AND ci.REFERENCE_ID = cl.ID
JOIN
    CREDIT_NOTES cn
ON 
    ci.REFERENCE_CENTER= cn.CENTER
    AND ci.REFERENCE_ID = cn.ID
JOIN 
    PERSONS p
ON
    ci.PERSON_CENTER = p.center
    AND ci.PERSON_ID = p.ID
JOIN 
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.ID = p.CURRENT_PERSON_ID
WHERE 
   cn.TRANS_TIME  >= params.StartDateLong
   AND cn.TRANS_TIME < params.EndDateLong
)

GROUP BY 
    PersonCenter, PersonId, "Data", "Numero"
HAVING 
    SUM(TOTAL_AMOUNT) <> 0
) pos_part

JOIN
(
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR($$Start_Date$$,'YYYY-MM-DD HH24:MI'), 'Europe/Rome')              AS StartDateLong,
            datetolongTZ(TO_CHAR($$End_Date$$,'YYYY-MM-DD HH24:MI'), 'Europe/Rome') +24*3600*1000  AS EndDateLong         
        FROM  dual
)
SELECT 
   INVOICE_REFERENCE,
   LineNo,
   RiferimentoNumero,
   xmlagg(
     xmlelement(name "DettaglioLinee",
        xmlelement(name "NumeroLinea", LineNo),
        xmlelement(name "Descrizione", TEXT),
        xmlelement(name "Quantita", TO_CHAR(QUANTITY, 'FM99999990.00')),
        xmlelement(name "PrezzoUnitario", TO_CHAR(NET_AMOUNT/QUANTITY, 'FM99999990.00')),
        xmlelement(name "PrezzoTotale", TO_CHAR(NET_AMOUNT, 'FM99999990.00')),
		
        CASE WHEN INSTR(TEXT,'Commissioni') > 0 THEN
			xmlelement(name "AliquotaIVA", '0.00')
		ELSE CASE WHEN INSTR(TEXT,'Diplomati') > 0 THEN
			xmlelement(name "AliquotaIVA", '0.00')
		ELSE
			xmlelement(name "AliquotaIVA", TO_CHAR(RATE * 100, 'FM90.00'))
		END END,
		CASE WHEN INSTR(TEXT,'Commissioni') > 0 THEN
			xmlelement(name "Natura",'N1')
		ELSE CASE WHEN INSTR(TEXT,'Diplomati') > 0 THEN
			xmlelement(name "Natura",'N3')
		END END,
		
		xmlelement(name "AltriDatiGestionali",
		     xmlelement(name "TipoDato", 'SCONTRINO'),
		     xmlelement(name "RiferimentoTesto", SUBSTR(TEXT_2,1,60)),
		     xmlelement(name "RiferimentoNumero", RiferimentoNumero)
                )
        )
      )
    as "AllInvoiceLines"  
FROM
(
SELECT tt1.*, row_number() over (partition by tt1.INVOICE_REFERENCE order by tt1.INVOICE_REFERENCE) AS LineNo 
FROM 
(
SELECT
    ci.INVOICE_REFERENCE,
	i.center ||'.'|| i.id AS RiferimentoNumero,
    il.SUBID,
    il.TEXT,
    il.QUANTITY,
   	il.NET_AMOUNT AS "NET_AMOUNT",
	il.TOTAL_AMOUNT AS "TOTAL_AMOUNT",	
    ivat.RATE,
    i.TEXT AS "TEXT_2",
    i.ENTRY_TIME
FROM
   PARAMS
CROSS JOIN    
   CUSTOMER_INVOICE ci
JOIN
    INVOICES i
ON
    i.CENTER = ci.REFERENCE_CENTER
	AND i.ID = ci.REFERENCE_ID
JOIN
   INVOICE_LINES_MT il
ON 
   ci.REFERENCE_CENTER= il.CENTER
   AND ci.REFERENCE_ID = il.ID
JOIN
   INVOICELINES_VAT_AT_LINK ivat
ON
   il.CENTER = ivat.INVOICELINE_CENTER
   AND il.ID = ivat.INVOICELINE_ID
   AND il.SUBID = ivat.INVOICELINE_SUBID
WHERE 
   i.TRANS_TIME  >= params.StartDateLong
   AND i.TRANS_TIME < params.EndDateLong
UNION ALL
SELECT
    ci.INVOICE_REFERENCE,
	cn.center ||'.'|| cn.id AS RiferimentoNumero,
	cl.SUBID,
	cl.TEXT,
	cl.QUANTITY,
	-cl.NET_AMOUNT AS "NET_AMOUNT",
	-cl.TOTAL_AMOUNT AS "TOTAL_AMOUNT",	
	cvat.RATE,
    cn.TEXT AS "TEXT_2",
	cn.ENTRY_TIME
FROM  
    PARAMS
CROSS JOIN
    CUSTOMER_INVOICE ci
JOIN
    CREDIT_NOTES cn
ON
    cn.CENTER = ci.REFERENCE_CENTER
	AND cn.ID = ci.REFERENCE_ID
JOIN
    CREDIT_NOTE_LINES_MT cl
ON 
    ci.REFERENCE_CENTER = cl.CENTER
    AND ci.REFERENCE_ID  = cl.ID
JOIN
    CREDIT_NOTE_LINE_VAT_AT_LINK cvat
ON
    cl.CENTER = cvat.CREDIT_NOTE_LINE_CENTER
    AND cl.ID = cvat.CREDIT_NOTE_LINE_ID
    AND cl.SUBID = cvat.CREDIT_NOTE_LINE_SUBID
WHERE 
   cn.TRANS_TIME >= params.StartDateLong
   AND cn.TRANS_TIME < params.EndDateLong
) tt1  
) 
   
GROUP BY INVOICE_REFERENCE, LineNo, RiferimentoNumero
) pos_details
ON
  pos_details.INVOICE_REFERENCE = pos_part."Numero"
  
)
UNION ALL
(
/******************* EFT invoices ***********************************/
SELECT
    eft_part.PersonCenter,
    eft_part.PersonID, 
    eft_part."Numero",
    TO_CHAR(eft_part."Data",'YYYY-MM-DD')  AS  "Data",
    eft_details."AllInvoiceLines",
	eft_details.LineNo,
	eft_details.RiferimentoNumero,
    TO_CHAR(eft_part."ImponibileImporto", 'FM99999990.00') as "ImponibileImporto",
    TO_CHAR(eft_part."Imposta", 'FM99999990.00') as "Imposta",
    TO_CHAR(eft_part."ImponibileImporto" + eft_part."Imposta", 'FM99999990.00') as "ImportoTotaleDocumento"
FROM

(
(
SELECT 
    personcenter, 
    personid, 
    "Data", 
    "Numero",   
    SUM(NET_AMOUNT) AS "ImponibileImporto",
    SUM(TOTAL_AMOUNT) - SUM(NET_AMOUNT) AS "Imposta"
FROM
(
SELECT 
    ar.CUSTOMERCENTER PersonCenter,
    ar.CUSTOMERID PersonId,
    prs.ORIGINAL_DUE_DATE  "Data",
    prs.REF "Numero",
    il.NET_AMOUNT,
    il.TOTAL_AMOUNT
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    CENTERS c
ON
   c.ID = prs.CENTER
   AND c.COUNTRY = 'IT'
JOIN 
    ACCOUNT_RECEIVABLES ar
ON 
   prs.CENTER = ar.CENTER
   AND prs.ID = ar.ID
   AND ar.ar_type = 4   
JOIN 
    AR_TRANS  art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
    INVOICES i
ON
    i.CENTER = art.REF_CENTER
    AND i.ID = art.REF_ID  
JOIN
    INVOICE_LINES_MT il
ON 
    i.CENTER = il.CENTER
    AND i.ID = il.ID
WHERE 
   prs.REF is not null
   AND art.REF_TYPE = 'INVOICE' 
   AND prs.ORIGINAL_DUE_DATE >= $$Start_Date$$
   AND prs.ORIGINAL_DUE_DATE <= $$End_Date$$

UNION ALL

-- Credit Notes
SELECT 
    ar.CUSTOMERCENTER PersonCenter,
    ar.CUSTOMERID PersonId,
    prs.ORIGINAL_DUE_DATE  "Data",
    prs.REF "Numero",
    -cl.NET_AMOUNT,
    -cl.TOTAL_AMOUNT
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    CENTERS c
ON
   c.ID = prs.CENTER
   AND c.COUNTRY = 'IT'
JOIN 
    ACCOUNT_RECEIVABLES ar
ON 
   prs.CENTER = ar.CENTER
   AND prs.ID = ar.ID
   AND ar.ar_type = 4  
JOIN 
    AR_TRANS  art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
    CREDIT_NOTES cn
ON
    cn.CENTER = art.REF_CENTER
    AND cn.ID = art.REF_ID  
JOIN
    CREDIT_NOTE_LINES_MT cl
ON 
    cn.CENTER = cl.CENTER
    AND cn.ID = cl.ID
WHERE 
   prs.REF is not null
   AND art.REF_TYPE = 'CREDIT_NOTE' 
   AND prs.ORIGINAL_DUE_DATE >= $$Start_Date$$
   AND prs.ORIGINAL_DUE_DATE <= $$End_Date$$
)
   
GROUP BY   
   personcenter, personid, "Data", "Numero"
HAVING 
    SUM(TOTAL_AMOUNT) <> 0
) 
) eft_part
JOIN
(
SELECT 
   REF,
   LineNo,
   RiferimentoNumero,
   xmlagg(
     xmlelement(name "DettaglioLinee",
        xmlelement(name "NumeroLinea", LineNo),
        xmlelement(name "Descrizione", TEXT),
        xmlelement(name "Quantita", TO_CHAR(QUANTITY, 'FM99999990.00')),
        xmlelement(name "PrezzoUnitario", TO_CHAR(NET_AMOUNT, 'FM99999990.00')),
        xmlelement(name "PrezzoTotale", TO_CHAR(NET_AMOUNT*QUANTITY, 'FM99999990.00')),
        
		CASE WHEN INSTR(TEXT,'Commissioni') > 0 THEN
			xmlelement(name "AliquotaIVA", '0.00')
		ELSE CASE WHEN INSTR(TEXT,'Diplomati') > 0 THEN
			xmlelement(name "AliquotaIVA", '0.00')
		ELSE
			xmlelement(name "AliquotaIVA", TO_CHAR(RATE * 100, 'FM90.00'))
		END END,
		CASE WHEN INSTR(TEXT,'Commissioni') > 0 THEN
			xmlelement(name "Natura",'N1')
		ELSE CASE WHEN INSTR(TEXT,'Diplomati') > 0 THEN
			xmlelement(name "Natura",'N3')
		END END,
		
		  xmlelement(name "AltriDatiGestionali",
		     xmlelement(name "TipoDato", 'SCONTRINO'),
	         xmlelement(name "RiferimentoTesto", SUBSTR(TEXT_2,1,60)),
		     xmlelement(name "RiferimentoNumero", RiferimentoNumero)
		 )
        )
      )
    as "AllInvoiceLines"  
FROM
(
SELECT tt1.*, row_number() over (partition by tt1.REF order by tt1.REF) AS LineNo 
FROM 
(
SELECT
    prs.REF,
	i.center ||'.'|| i.id AS RiferimentoNumero,
    il.SUBID,
    il.TEXT,
    il.QUANTITY,
    il.NET_AMOUNT,
    ivat.RATE,
    i.TEXT AS "TEXT_2",
    i.ENTRY_TIME
FROM  
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    CENTERS c
ON
   c.ID = prs.CENTER
   AND c.COUNTRY = 'IT'
JOIN
    AR_TRANS  art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
    INVOICES i
ON
    i.CENTER = art.REF_CENTER
	AND i.ID = art.REF_ID
JOIN
    INVOICE_LINES_MT il
ON 
    art.REF_CENTER = il.CENTER
    AND art.REF_ID = il.ID
JOIN
    INVOICELINES_VAT_AT_LINK ivat
ON
   il.CENTER = ivat.INVOICELINE_CENTER
    AND il.ID = ivat.INVOICELINE_ID
    AND il.SUBID = ivat.INVOICELINE_SUBID
WHERE 
   prs.REF is not null
   AND art.REF_TYPE = 'INVOICE'    
   AND prs.ORIGINAL_DUE_DATE >= $$Start_Date$$
   AND prs.ORIGINAL_DUE_DATE <= $$End_Date$$
UNION ALL
SELECT
    prs.REF,
	cn.center ||'.'|| cn.id AS RiferimentoNumero,
	cl.SUBID,
	cl.TEXT,
	cl.QUANTITY,
	-cl.NET_AMOUNT AS "NET_AMOUNT",
	cvat.RATE,
	cn.TEXT AS "TEXT_2",
	cn.ENTRY_TIME
FROM  
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    CENTERS c
ON
   c.ID = prs.CENTER
   AND c.COUNTRY = 'IT'
JOIN
    AR_TRANS  art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
    CREDIT_NOTES cn
ON
    cn.CENTER = art.REF_CENTER
    AND cn.ID = art.REF_ID 
JOIN
    CREDIT_NOTE_LINES_MT cl
ON 
    art.REF_CENTER = cl.CENTER
    AND art.REF_ID = cl.ID
JOIN
    CREDIT_NOTE_LINE_VAT_AT_LINK cvat
ON
    cl.CENTER = cvat.CREDIT_NOTE_LINE_CENTER
    AND cl.ID = cvat.CREDIT_NOTE_LINE_ID
    AND cl.SUBID = cvat.CREDIT_NOTE_LINE_SUBID
WHERE 
   prs.REF is not null
   AND art.REF_TYPE = 'CREDIT_NOTE'   
   AND prs.ORIGINAL_DUE_DATE >= $$Start_Date$$
   AND prs.ORIGINAL_DUE_DATE <= $$End_Date$$
) tt1   
)   
GROUP BY REF, LineNo , RiferimentoNumero
) eft_details
ON
   eft_details.Ref = eft_part."Numero"

)


) both_pos_and_eft
JOIN
    PERSONS p
ON 
    p.center = both_pos_and_eft.PersonCenter
    AND p.id = both_pos_and_eft.PersonId
LEFT JOIN
    PERSON_EXT_ATTRS codice
ON
    codice.PERSONCENTER = p.Center
AND codice.PERSONID = p.Id
AND codice.NAME = 'CodiceDestinatario'
LEFT JOIN
    PERSON_EXT_ATTRS pcomment
ON
    pcomment.PERSONCENTER = p.Center
AND pcomment.PERSONID = p.Id
AND pcomment.NAME = '_eClub_Comment'
LEFT JOIN
    PERSON_EXT_ATTRS invadr1
ON
    invadr1.PERSONCENTER = p.Center
AND invadr1.PERSONID = p.Id
AND invadr1.NAME = '_eClub_InvoiceAddress1'
LEFT JOIN
    PERSON_EXT_ATTRS invcity
ON
    invcity.PERSONCENTER = p.Center
AND invcity.PERSONID = p.Id
AND invcity.NAME = '_eClub_InvoiceCity'
LEFT JOIN
    PERSON_EXT_ATTRS invzip
ON
    invzip.PERSONCENTER = p.Center
AND invzip.PERSONID = p.Id
AND invzip.NAME = '_eClub_InvoiceZipCode'
LEFT JOIN
    PERSON_EXT_ATTRS invnation
ON
    invnation.PERSONCENTER = p.Center
AND invnation.PERSONID = p.Id
AND invnation.NAME = '_eClub_InvoiceCountry'
LEFT JOIN
    PERSON_EXT_ATTRS invname
ON
    invname.PERSONCENTER = p.CENTER
AND invname.PERSONID = p.ID
AND invname.NAME = '_eClub_InvoiceCoName'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
AND email.PERSONID = p.ID
AND email.NAME = '_eClub_Email'
) data_for_Xml
