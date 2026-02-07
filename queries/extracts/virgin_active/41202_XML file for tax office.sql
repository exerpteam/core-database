WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR($$StartDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')                   AS StartDateLong,
            (datetolongTZ(TO_CHAR($$EndDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')+ 86400 * 1000)-1 AS EndDateLong
        FROM
            dual
    )
SELECT
    '?'  "IdPaese",
    pcomment.TXTVALUE "IdCodice",
    DECODE(codice.TXTVALUE,null,'0000000',codice.TXTVALUE) "CodiceDestinatario",
    '?' "IdCodice",
    '?' "Denominazione",
    'RF01' "RegimeFiscale",
    '?' "Indirizzo",
    '?' "CAP",
    '?' "Comune",
    '?' "Nazione",
    pos_eft.PersonCenter||'p'||pos_eft.PersonId "Anagrafica",
    invadr1.TXTVALUE||' '||invadr2.TXTVALUE  "Indirizzo",
    invzip.TXTVALUE "CAP",
    invcity.TXTVALUE "Comune",
    invnation.TXTVALUE "Nazione",
    TO_CHAR(longtodate(pos_eft."Data"),'YYYY-MM-DD')  "Data",
    pos_eft."Numero",
    pos_eft."NumeroLinea",
    pos_eft."Descrizione",
    pos_eft."PrezzoUnitario",
    pos_eft."PrezzoTotale",
    pos_eft."RiferimentoTesto",
    pos_eft."RiferimentoNumero",
    pos_eft."RiferimentoData",
    pos_eft."AliquotaIVA",
    pos_eft."ImponibileImporto",
    pos_eft."Imposta"
FROM
(SELECT 
    inv.PAYER_CENTER  PersonCenter,
    inv.PAYER_ID PersonId,
    prs.ISSUED_DATE  "Data",
    prs.REF "Numero",
    il.SUBID  "NumeroLinea",
    il.TEXT "Descrizione",
    il.PRODUCT_NORMAL_PRICE "PrezzoUnitario",
    il.TOTAL_AMOUNT  "PrezzoTotale",
    il.TEXT  "RiferimentoTesto",
    il.CENTER || 'inv' || il.ID  "RiferimentoNumero",
    TO_CHAR(longtodate(inv.ENTRY_TIME),'YYYY-MM-DD') "RiferimentoData",
    ivat.RATE * 100 "AliquotaIVA",
    il.NET_AMOUNT "ImponibileImporto",
    il.TOTAL_AMOUNT - il.NET_AMOUNT "Imposta"
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    AR_TRANS  art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
    AND prs.REF is not null
    AND art.REF_TYPE = 'INVOICE'   
JOIN
   INVOICES inv
ON 
   art.REF_CENTER = inv.CENTER
   AND art.REF_ID = inv.ID
JOIN
   INVOICE_LINES_MT il
ON
   inv.CENTER = il.CENTER
   AND inv.ID = il.ID   
LEFT JOIN
    INVOICELINES_VAT_AT_LINK ivat
ON
    il.CENTER = ivat.INVOICELINE_CENTER
    AND il.ID = ivat.INVOICELINE_ID
    AND il.SUBID = ivat.INVOICELINE_SUBID

UNION ALL

SELECT
    ci.PERSON_CENTER  PersonCenter,
    ci.PERSON_ID PersonId,
    ci.ISSUED_DATE "Data",
    ci.INVOICE_REFERENCE "Numero",
    il.SUBID  "NumeroLinea",
    il.TEXT "Descrizione",
    il.PRODUCT_NORMAL_PRICE "PrezzoUnitario",
    il.TOTAL_AMOUNT  "PrezzoTotale",
    il.TEXT  "RiferimentoTesto",
    il.CENTER || 'inv' || il.ID  "RiferimentoNumero",
    TO_CHAR(longtodate(inv.ENTRY_TIME),'YYYY-MM-DD') "RiferimentoData",
    ivat.RATE * 100 "AliquotaIVA",
    il.NET_AMOUNT "ImponibileImporto",
    il.TOTAL_AMOUNT - il.NET_AMOUNT "Imposta"
FROM
    CUSTOMER_INVOICE ci
JOIN
    INVOICES inv
ON
    ci.REFERENCE_CENTER = inv.CENTER
    AND ci.REFERENCE_ID = inv.ID
JOIN
    INVOICE_LINES_MT il
ON
    inv.CENTER = il.CENTER
    AND inv.ID = il.ID
LEFT JOIN
    INVOICELINES_VAT_AT_LINK ivat
ON
    il.CENTER = ivat.INVOICELINE_CENTER
    AND il.ID = ivat.INVOICELINE_ID
    AND il.SUBID = ivat.INVOICELINE_SUBID
) 

pos_eft
CROSS JOIN 
    params
LEFT JOIN
    PERSON_EXT_ATTRS codice
ON
    codice.PERSONCENTER = pos_eft.PersonCenter
AND codice.PERSONID = pos_eft.PersonId
AND codice.NAME = 'CodiceDestinatario'
LEFT JOIN
    PERSON_EXT_ATTRS pcomment
ON
    pcomment.PERSONCENTER = pos_eft.PersonCenter
AND pcomment.PERSONID = pos_eft.PersonId
AND pcomment.NAME = '_eClub_Comment'
LEFT JOIN
    PERSON_EXT_ATTRS invadr1
ON
    invadr1.PERSONCENTER = pos_eft.PersonCenter
AND invadr1.PERSONID = pos_eft.PersonId
AND invadr1.NAME = '_eClub_InvoiceAddress1'
LEFT JOIN
    PERSON_EXT_ATTRS invadr2
ON
    invadr2.PERSONCENTER = pos_eft.PersonCenter
AND invadr2.PERSONID = pos_eft.PersonId
AND invadr2.NAME = '_eClub_InvoiceAddress2'
LEFT JOIN
    PERSON_EXT_ATTRS invcity
ON
    invcity.PERSONCENTER = pos_eft.PersonCenter
AND invcity.PERSONID = pos_eft.PersonId
AND invcity.NAME = '_eClub_InvoiceCity'
LEFT JOIN
    PERSON_EXT_ATTRS invzip
ON
    invzip.PERSONCENTER = pos_eft.PersonCenter
AND invzip.PERSONID = pos_eft.PersonId
AND invzip.NAME = '_eClub_InvoiceZipCode'
LEFT JOIN
    PERSON_EXT_ATTRS invnation
ON
    invnation.PERSONCENTER = pos_eft.PersonCenter
AND invnation.PERSONID = pos_eft.PersonId
AND invnation.NAME = '_eClub_InvoiceCoName'
WHERE
    pos_eft.PersonCenter in ($$Scope$$)
    AND pos_eft."Data"  > params.StartDateLong
    AND pos_eft."Data"  < params.EndDateLong
