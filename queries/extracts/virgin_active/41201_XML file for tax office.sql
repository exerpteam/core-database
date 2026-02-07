/**************************/
/* 1.XML Generation       */
/* 2.SELECT EFT invoices  */
/* 3.SELECT POS invoices  */
/**************************/

SELECT
    data_for_Xml."Anagrafica" "Member ID" ,
    data_for_Xml."Numero" "Invoice Nr",

     replace(replace(concat('<?xml version="1.0" encoding="UTF-8"?><FatturaElettronica xmlns'||chr(58)||'xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns'||chr(58)||'xsd="http://www.w3.org/2001/XMLSchema" versione="FPR12" xmlns="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2">',
      
      -- Header
      xmlelement(name "FatturaElettronicaHeader", 
            xmlelement(name "DatiTrasmissione", 
                xmlelement(name "IdTrasmittente", 
                     xmlelement(name "IdPaese",data_for_Xml."IdPaese"), 
                     xmlelement(name "IdCodice", data_for_Xml."IdCodice1")
                ), 
                xmlelement(name "ProgressivoInvio", to_char(replace(data_for_Xml."Numero",'-',''), 'FMXXXXXXX')), 
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
                   xmlelement(name "Indirizzo", data_for_Xml."Indirizzo1"),
                   xmlelement(name "CAP", data_for_Xml."CAP1"),
                   xmlelement(name "Comune", data_for_Xml."Comune1"),
                   xmlelement(name "Nazione", data_for_Xml."Nazione1")
                   )
                
            ),
            xmlelement(name "CessionarioCommittente",
                xmlelement(name "DatiAnagrafici",
                   xmlelement(name "CodiceFiscale", data_for_Xml."CodiceFiscale"),
                   xmlelement(name "Anagrafica", 
                      xmlelement(name "Denominazione", data_for_Xml."Denominazione_Cust")
                   )
                ),
               xmlelement(name "Sede",
                  xmlelement(name "Indirizzo", data_for_Xml."Indirizzo2"),
                  xmlelement(name "CAP", data_for_Xml."CAP2"),
                  xmlelement(name "Comune", data_for_Xml."Comune2"),
                 xmlelement(name "Nazione", data_for_Xml."Nazione2")
              )
         )
    ).getStringVal())
            
    , '<FatturaElettronicaHeader>','<FatturaElettronicaHeader xmlns="">')
    , '&apos;','''')
  
   AS headerxml,

   replace(replace(concat( 
     -- Body
    xmlelement(name "FatturaElettronicaBody", 
        xmlelement(name "DatiGenerali",
            xmlelement(name "DatiGeneraliDocumento",
                xmlelement(name "TipoDocumento", data_for_Xml."TipoDocumento"),
                xmlelement(name "Divisa", data_for_Xml."Divisa"),
                xmlelement(name "Data", data_for_Xml."Data"),
                xmlelement(name "Numero", data_for_Xml."Numero"),
                xmlelement(name "ImportoTotaleDocumento", data_for_Xml."ImportoTotaleDocumento")
           )
        ),
        

        xmlelement(name "DatiBeniServizi", 
		    data_for_Xml."AllInvoiceLines" , 
            xmlelement(name "DatiRiepilogo",
                xmlelement(name "AliquotaIVA", data_for_Xml."AliquotaIVA"),
                xmlelement(name "ImponibileImporto", data_for_Xml."ImponibileImporto"),    
                xmlelement(name "Imposta", data_for_Xml."Imposta") 
   )
    
        )
        ).getStringVal(),
    '</FatturaElettronica>'
    )
    , '<FatturaElettronicaBody>', '<FatturaElettronicaBody xmlns="">')
    , '&apos;','''')
	
    AS bodyxml	
	 
FROM 
(
SELECT
    'IT' AS "IdPaese", --fixed
    pcomment.TXTVALUE "IdCodice1",
    'FPR12' "FormatoTrasmissione", --fixed
    DECODE(codice.TXTVALUE,null,'0000000',codice.TXTVALUE) "CodiceDestinatario",
    DECODE(p.center, 209, '06371530962',  223, '03032340980',224, '03032340980',225, '03032340980', '03641880962' )  "IdCodice",
    DECODE(p.center, 209, 'Club Milano Corso Como S.r.l.' ,  223,'Club Milano City S.r.l.',224,'Club Milano City S.r.l.',225,'Club Milano City S.r.l.', 'Virgin Active Italia S.pa.'  )  "Denominazione_VAI",
    p.SSN  AS "CodiceFiscale",
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
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE)-:offset, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS StartDateLong,
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS EndDateLong        
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
    ci.PERSON_CENTER PersonCenter,
    ci.PERSON_ID  PersonId,
    ci.ISSUED_DATE "Data",
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
WHERE 
   ci.ISSUED_DATE  >= params.StartDateLong
   AND ci.ISSUED_DATE < params.EndDateLong
UNION ALL
--credit notes
SELECT
    ci.PERSON_CENTER PersonCenter,
    ci.PERSON_ID  PersonId,
    ci.ISSUED_DATE "Data",
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
WHERE 
   ci.ISSUED_DATE  >= params.StartDateLong
   AND ci.ISSUED_DATE < params.EndDateLong
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
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE)-:offset, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS StartDateLong,
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS EndDateLong        
        FROM  dual
)
SELECT 
   INVOICE_REFERENCE,
   xmlagg(
     xmlelement(name "DettaglioLinee",
        xmlelement(name "NumeroLinea", LineNo),
        xmlelement(name "Descrizione", TEXT),
        xmlelement(name "Quantita", TO_CHAR(QUANTITY, 'FM99999990.00')),
        xmlelement(name "PrezzoUnitario", TO_CHAR(NET_AMOUNT, 'FM99999990.00')),
        xmlelement(name "PrezzoTotale", TO_CHAR(NET_AMOUNT*QUANTITY, 'FM99999990.00')),
        xmlelement(name "AliquotaIVA", TO_CHAR(RATE * 100, 'FM90.00')),
		xmlelement(name "AltriDatiGestionali",
		     xmlelement(name "TipoDato", 'SCONTRINO'),
		     xmlelement(name "RiferimentoTesto", TEXT_2),
		     xmlelement(name "RiferimentoNumero", "RiferimentoNumero"),
		     xmlelement(name "RiferimentoData", TO_CHAR(longtodateTZ(ENTRY_TIME, 'Europe/Rome'),'YYYY-MM-DD'))
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
    ''||i.ID AS "RiferimentoNumero",
    il.SUBID,
    il.TEXT,
    il.QUANTITY,
    il.NET_AMOUNT AS "NET_AMOUNT",
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
   ci.ISSUED_DATE  >= params.StartDateLong
   AND ci.ISSUED_DATE < params.EndDateLong
UNION ALL
SELECT
    ci.INVOICE_REFERENCE,
	''||cn.ID AS "RiferimentoNumero",
	cl.SUBID,
	cl.TEXT,
	cl.QUANTITY,
	-cl.NET_AMOUNT AS "NET_AMOUNT",
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
   ci.ISSUED_DATE >= params.StartDateLong
   AND ci.ISSUED_DATE < params.EndDateLong
) tt1  
) 
   
GROUP BY INVOICE_REFERENCE  
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
    TO_CHAR(longtodateTZ(eft_part."Data", 'Europe/Rome'),'YYYY-MM-DD')  "Data",
    eft_details."AllInvoiceLines",
    TO_CHAR(eft_part."ImponibileImporto", 'FM99999990.00') as "ImponibileImporto",
    TO_CHAR(eft_part."Imposta", 'FM99999990.00') as "Imposta",
    TO_CHAR(eft_part."ImponibileImporto" + eft_part."Imposta", 'FM99999990.00') as "ImportoTotaleDocumento"
FROM

(
(
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE)-:offset, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS StartDateLong,
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS EndDateLong        
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
    i.PAYER_CENTER PersonCenter,
    i.PAYER_ID PersonId,
    prs.ISSUED_DATE  "Data",
    prs.REF "Numero",
    il.NET_AMOUNT,
    il.TOTAL_AMOUNT
FROM
    PARAMS
CROSS JOIN
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
    i.CENTER = il.CENTER
    AND i.ID = il.ID
WHERE 
   prs.REF is not null
   AND art.REF_TYPE = 'INVOICE' 
   AND prs.ISSUED_DATE >= params.StartDateLong
   AND prs.ISSUED_DATE < params.EndDateLong

UNION ALL
-- Credit Notes

SELECT 
    cn.PAYER_CENTER PersonCenter,
    cn.PAYER_ID PersonId,
    prs.ISSUED_DATE  "Data",
    prs.REF "Numero",
    -cl.NET_AMOUNT,
    -cl.TOTAL_AMOUNT
FROM
    PARAMS
CROSS JOIN
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
    cn.CENTER = cl.CENTER
    AND cn.ID = cl.ID
WHERE 
   prs.REF is not null
   AND art.REF_TYPE = 'CREDIT_NOTE' 
   AND prs.ISSUED_DATE >= params.StartDateLong
   AND prs.ISSUED_DATE < params.EndDateLong
)
   
GROUP BY   
   personcenter, personid, "Data", "Numero"
HAVING 
    SUM(TOTAL_AMOUNT) <> 0
) 
) eft_part
JOIN
(
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE)-:offset, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS StartDateLong,
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')   AS EndDateLong
        FROM  dual
    )
SELECT 
   REF,
   xmlagg(
     xmlelement(name "DettaglioLinee",
        xmlelement(name "NumeroLinea", LineNo),
        xmlelement(name "Descrizione", TEXT),
        xmlelement(name "Quantita", TO_CHAR(QUANTITY, 'FM99999990.00')),
        xmlelement(name "PrezzoUnitario", TO_CHAR(NET_AMOUNT, 'FM99999990.00')),
        xmlelement(name "PrezzoTotale", TO_CHAR(NET_AMOUNT*QUANTITY, 'FM99999990.00')),
        xmlelement(name "AliquotaIVA", TO_CHAR(RATE * 100, 'FM90.00')),
		  xmlelement(name "AltriDatiGestionali",
		     xmlelement(name "TipoDato", 'SCONTRINO'),
	             xmlelement(name "RiferimentoTesto", TEXT_2),
		     xmlelement(name "RiferimentoNumero", "RiferimentoNumero"),
		     xmlelement(name "RiferimentoData", TO_CHAR(longtodateTZ(ENTRY_TIME, 'Europe/Rome'),'YYYY-MM-DD'))
		 )
        )
      )
    as "AllInvoiceLines"  
FROM
(
SELECT tt1.*, row_number() over (PARTITION BY tt1.REF order by tt1.REF) AS LineNo 
FROM 
(
SELECT
    prs.REF,
    ''||i.ID AS "RiferimentoNumero",
    il.SUBID,
    il.TEXT,
    il.QUANTITY,
    il.NET_AMOUNT,
    ivat.RATE,
    i.TEXT AS "TEXT_2",
    i.ENTRY_TIME
FROM  
    PARAMS
CROSS JOIN
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
   AND prs.ISSUED_DATE >= params.StartDateLong
   AND prs.ISSUED_DATE < params.EndDateLong
UNION ALL
SELECT
    prs.REF,
    ''||cn.ID AS "RiferimentoNumero",
	cl.SUBID,
	cl.TEXT,
	cl.QUANTITY,
	-cl.NET_AMOUNT AS "NET_AMOUNT",
	cvat.RATE,
	cn.TEXT AS "TEXT_2",
	cn.ENTRY_TIME
FROM  
    PARAMS
CROSS JOIN
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
   AND prs.ISSUED_DATE >= params.StartDateLong
   AND prs.ISSUED_DATE < params.EndDateLong
) tt1   
)   
GROUP BY REF  
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

) data_for_Xml
