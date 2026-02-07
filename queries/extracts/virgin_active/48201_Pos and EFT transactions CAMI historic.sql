SELECT
    DECODE(cp.center,NULL,'',cp.center||'p'||cp.id) AS "ID",
    cp.FULLNAME          AS "Name and Last name",
    email.TXTVALUE      AS "Email",
    pec.TXTVALUE        AS "FATTURA PEC",
    codice.TXTVALUE     AS "CODICE DESTINATARIO",
    codiceF.TXTVALUE    AS "Codice Fiscale / Partita IVA",
    pcomment.TXTVALUE   AS "COMMENT",
    invname.TXTVALUE as "Fattura Nome",
    invadr1.TXTVALUE as "FatturaINDIRIZZO 1",
    invadr2.TXTVALUE as "FatturaINDIRIZZO 2",
    invzip.TXTVALUE  as " Fattura CAP",
    invcity.TXTVALUE      AS "Fattura CITTA",
    cp.ssn as ssn,
    cp.address1 as "INDIRIZZO 1",
    cp.address2 as "INDIRIZZO 2" ,
    cp.zipcode  as "CAP",
    cp.city as "CITTA",   
    pos_eft."Numero Fattura",
    TO_CHAR(longtodate(pos_eft."Data Creazione Fattura"),'YYYY-MM-DD') AS "Data Creazione Fattura",
    pos_eft."Data Pagamento Fattura",
    pos_eft."Importo fattura",
    pos_eft."Numero di ricevuta",
    pos_eft."Descrizione",
    pos_eft."Importo ricevuta",
    pos_eft."Fonte",
    pos_eft."Importo IVA",
    pos_eft."Importo"
FROM
(
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR($$StartDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')               AS StartDateLong,
            (datetolongTZ(TO_CHAR($$EndDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')+ 86400 * 1000) AS EndDateLong
        FROM
            dual
    )
SELECT 
    i.PAYER_CENTER                                    AS PERSONCENTER,
    i.PAYER_ID                                        AS PERSONID,
    prs.REF                                           AS "Numero Fattura",
    i.ENTRY_TIME                                      AS "Data Creazione Fattura",  
    TO_CHAR(prs.ORIGINAL_DUE_DATE,'YYYY-MM-DD')       AS "Data Pagamento Fattura",
    prs.REQUESTED_AMOUNT                              AS "Importo fattura",
    i.center||'inv'||i.id                             AS "Numero di ricevuta",
    il.TEXT                                           AS "Descrizione",
    il.TOTAL_AMOUNT "Importo ricevuta",
    'EFT' AS "Fonte",
    il.TOTAL_AMOUNT-il.NET_AMOUNT "Importo IVA",
    il.NET_AMOUNT "Importo"
FROM
    params
CROSS JOIN
    invoices i
JOIN
    invoice_lines_mt il
ON
    il.center = i.center
    AND il.id = i.id
JOIN
    AR_TRANS art
ON
    art.REF_CENTER = i.CENTER
    AND art.REF_ID = i.ID
    AND art.REF_TYPE = 'INVOICE'
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    art.payreq_spec_center = prs.center
    AND art.payreq_spec_id = prs.id
    AND art.payreq_spec_subid = prs.subid
WHERE 
   $$invoice_type$$ in ('EFT','BOTH')
   AND i.CENTER in ($$Scope$$)
   AND prs.REQUESTED_AMOUNT <> 0
   AND prs.REF IS NOT null
   AND prs.ORIGINAL_DUE_DATE >= $$StartDate$$ 
   AND prs.ORIGINAL_DUE_DATE <= $$EndDate$$ 
   
UNION ALL
SELECT
    i.PAYER_CENTER                                    AS PERSONCENTER,
    i.PAYER_ID                                        AS PERSONID,
    ci.INVOICE_REFERENCE                              AS "Numero Fattura",
    i.ENTRY_TIME                                      AS "Data Creazione Fattura",
    TO_CHAR(longtodate(ci.ISSUED_DATE),'YYYY-MM-DD')  AS "Data Pagamento Fattura",
    il.TOTAL_AMOUNT                                   AS "Importo fattura",
    i.center||'inv'||i.id                             AS "Numero di ricevuta",
    il.TEXT                                           AS "Descrizione",
    il.TOTAL_AMOUNT                                   AS "Importo ricevuta",
    'POS'                                             AS "Fonte",
    il.TOTAL_AMOUNT-il.NET_AMOUNT                     AS "Importo IVA",
    il.NET_AMOUNT                                     AS "Importo"
FROM
    params
CROSS JOIN
    INVOICES i
JOIN
    INVOICE_LINES_MT il
ON
    i.center = il.center
    AND i.id = il.id
LEFT JOIN 
    CUSTOMER_INVOICE ci
ON
    ci.REFERENCE_CENTER =  i.center
    AND ci.REFERENCE_ID = i.id
WHERE 
   $$invoice_type$$ in ('POS','BOTH')
   AND i.CENTER in ($$Scope$$)
   AND il.TOTAL_AMOUNT <> 0
   AND ci.ISSUED_DATE >= params.StartDateLong 
   AND ci.ISSUED_DATE < params.EndDateLong 
   AND ci.INVOICE_REFERENCE is not null
UNION ALL
SELECT
    nvl(cn.PAYER_CENTER, cl.PERSON_CENTER)            AS PERSONCENTER,
    nvl(cn.PAYER_ID, cl.PERSON_ID)                    AS PERSONID,
    prs.REF                                           AS "Numero Fattura",
    cn.ENTRY_TIME                                     AS "Data Creazione Fattura",
    TO_CHAR(prs.ORIGINAL_DUE_DATE,'YYYY-MM-DD')       AS "Data Pagamento Fattura",
    -cl.TOTAL_AMOUNT                                  AS "Importo fattura",
    cn.center||'cred'||cn.id                          AS "Numero di ricevuta",
    cl.TEXT                                           AS "Descrizione",
    -cl.TOTAL_AMOUNT                                  AS "Importo ricevuta",
    'EFT'                                             AS "Fonte",
    -(cl.TOTAL_AMOUNT-cl.NET_AMOUNT)                  AS "Importo IVA",
    -cl.NET_AMOUNT                                    AS "Importo"
FROM
    params
CROSS JOIN
   CREDIT_NOTES cn
JOIN
    CREDIT_NOTE_LINES_MT cl
ON
    cl.center = cn.center
    AND cl.id = cn.id
LEFT JOIN 
    AR_TRANS  art
ON
    art.REF_CENTER = cl.center
    and art.REF_ID = cl.id
    and art.REF_TYPE = 'CREDIT_NOTE'
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    art.payreq_spec_center = prs.center
    AND art.payreq_spec_id = prs.id
    AND art.payreq_spec_subid = prs.subid
WHERE
   cn.CENTER in ($$Scope$$)
   AND  prs.ORIGINAL_DUE_DATE >= $$StartDate$$ 
   AND prs.ORIGINAL_DUE_DATE <= $$EndDate$$ 
   AND prs.REF is not null
) 
pos_eft

LEFT JOIN 
    PERSONS p
ON
    p.CENTER = pos_eft.PERSONCENTER
    AND p.ID = pos_eft.PERSONID
LEFT JOIN
    PERSONS cp
ON
    p.CURRENT_PERSON_CENTER = cp.CENTER
    AND p.CURRENT_PERSON_ID = cp.ID
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = cp.CENTER
AND email.PERSONID = cp.ID
AND email.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS pec
ON
    pec.PERSONCENTER =  cp.CENTER
AND pec.PERSONID = cp.ID
AND pec.NAME = 'FatturaPEC'
LEFT JOIN
    PERSON_EXT_ATTRS codice
ON
    codice.PERSONCENTER = cp.CENTER
AND codice.PERSONID = cp.ID
AND codice.NAME = 'CodiceDestinatario'

LEFT JOIN
    PERSON_EXT_ATTRS codiceF
ON
    codiceF.PERSONCENTER = cp.CENTER
AND codiceF.PERSONID = cp.ID
AND codiceF.NAME = 'CodiceFattura'

LEFT JOIN
    PERSON_EXT_ATTRS pcomment
ON
    pcomment.PERSONCENTER = cp.CENTER
AND pcomment.PERSONID = cp.ID
AND pcomment.NAME = '_eClub_Comment'
LEFT JOIN
    PERSON_EXT_ATTRS invadr1
ON
    invadr1.PERSONCENTER = cp.CENTER
AND invadr1.PERSONID = cp.ID
AND invadr1.NAME = '_eClub_InvoiceAddress1'
LEFT JOIN
    PERSON_EXT_ATTRS invadr2
ON
    invadr2.PERSONCENTER = cp.CENTER
AND invadr2.PERSONID = cp.ID
AND invadr2.NAME = '_eClub_InvoiceAddress2'
LEFT JOIN
    PERSON_EXT_ATTRS invcity
ON
    invcity.PERSONCENTER = cp.CENTER
AND invcity.PERSONID = cp.ID
AND invcity.NAME = '_eClub_InvoiceCity'
LEFT JOIN
    PERSON_EXT_ATTRS invzip
ON
    invzip.PERSONCENTER = cp.CENTER
AND invzip.PERSONID = cp.ID
AND invzip.NAME = '_eClub_InvoiceZipCode'
LEFT JOIN
    PERSON_EXT_ATTRS invname
ON
    invname.PERSONCENTER = cp.CENTER
    AND invname.PERSONID = cp.ID
    AND invname.NAME = '_eClub_InvoiceCoName'