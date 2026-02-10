-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
     params AS
     (
         SELECT
             /*+ materialize */
             c.ID AS Center,
             c.SHORTNAME,
             $$From_Date$$                AS StartDateLong,
             $$To_Date$$ +24*60*60*1000 AS EndDateLong
         FROM
             CENTERS c
         WHERE
             c.COUNTRY = 'NO'
     )
     ,
     v_trans AS
     (
         SELECT
             cp.EXTERNAL_ID,
             params.CENTER Club,
             params.SHORTNAME,
             i.CENTER,
             i.ID,
             il.ACCOUNT_TRANS_CENTER,
             il.ACCOUNT_TRANS_ID,
             il.ACCOUNT_TRANS_SUBID,
             il.TOTAL_AMOUNT,
             il.TOTAL_AMOUNT-il.NET_AMOUNT VAT,
             il.NET_AMOUNT,
             TO_CHAR(longtodateC(i.ENTRY_TIME,i.center),'YYYY-MM-dd HH24:MI:SS') EntryDateTime,
             TO_CHAR(longtodateC(i.TRANS_TIME,i.center),'YYYY-MM-dd HH24:MI:SS') BookDateTime,
             'INVOICE'                                                           "Type",
             i.FISCAL_REFERENCE                                                  REFERENCE,
             i.FISCAL_EXPORT_TOKEN                                               Token
         FROM
             PARAMS
         JOIN
             INVOICES i
         ON
             i.CENTER = params.CENTER
             AND i.FISCAL_EXPORT_TOKEN IS NOT NULL
         JOIN
             INVOICE_LINES_MT il
         ON
             i.CENTER= il.CENTER
             AND i.ID = il.ID
         JOIN
             PERSONS p
         ON
             i.PAYER_CENTER = p.center
             AND i.PAYER_ID = p.ID
         JOIN
             PERSONS cp
         ON
             cp.CENTER = p.CURRENT_PERSON_CENTER
             AND cp.ID = p.CURRENT_PERSON_ID
         WHERE
             i.TRANS_TIME >= params.StartDateLong
             AND i.TRANS_TIME < params.EndDateLong
         UNION ALL
         SELECT
             cp.EXTERNAL_ID,
             params.CENTER Club,
             params.SHORTNAME,
             cn.CENTER,
             cn.ID,
             cl.ACCOUNT_TRANS_CENTER,
             cl.ACCOUNT_TRANS_ID,
             cl.ACCOUNT_TRANS_SUBID,
             -(cl.TOTAL_AMOUNT),
             -(cl.TOTAL_AMOUNT-cl.NET_AMOUNT) VAT,
             -(cl.NET_AMOUNT),
             TO_CHAR(longtodateC(cn.ENTRY_TIME,cn.center),'YYYY-MM-dd HH24:MI:SS') EntryDateTime,
             TO_CHAR(longtodateC(cn.TRANS_TIME,cn.center),'YYYY-MM-dd HH24:MI:SS') BookDateTime,
             'CREDIT_NOTE'                                                         "Type",
             cn.FISCAL_REFERENCE                                                   REFERENCE,
             cn.FISCAL_EXPORT_TOKEN                                                Token
         FROM
             PARAMS
         JOIN
             CREDIT_NOTES cn
         ON
             cn.CENTER = params.CENTER
             AND cn.FISCAL_EXPORT_TOKEN IS NOT NULL
         JOIN
             CREDIT_NOTE_LINES_MT cl
         ON
             cn.CENTER= cl.CENTER
             AND cn.ID = cl.ID
         LEFT JOIN
             PERSONS p
         ON
             cn.PAYER_CENTER = p.center
             AND cn.PAYER_ID = p.ID
         LEFT JOIN
             PERSONS cp
         ON
             cp.CENTER = p.CURRENT_PERSON_CENTER
             AND cp.ID = p.CURRENT_PERSON_ID
         WHERE
             cn.TRANS_TIME >= params.StartDateLong
             AND cn.TRANS_TIME < params.EndDateLong
     )
 SELECT
     t.EXTERNAL_ID AS "External ID",
     t.Club        AS "Club ID",
     t.SHORTNAME "Club Name",
     CASE
         WHEN t."Type" = 'INVOICE'
         THEN t.center ||'inv'||t.ID
         ELSE t.center ||'cred'||t.ID
     END            AS "Document Number",
     t.TOTAL_AMOUNT AS "Total Amount",
     t.VAT,
     t.NET_AMOUNT "Net Amount",
     t.EntryDateTime AS "Entry Date Time",
     t.BookDateTime  AS "Book Date Time",
     t."Type"          AS "Sales Type",
     CASE
         WHEN ci.REFERENCE_CENTER IS NOT NULL
         THEN 'SCONTRINO'
         ELSE 'FATTURA'
     END                    AS "Document Type",
     credit_acc.EXTERNAL_ID AS "Credit Account",
     debit_acc.EXTERNAL_ID  AS "Debit account",
     t.REFERENCE            AS "Fiscal Reference",
     t.Token                AS "External Token"
 FROM
     v_trans t
 LEFT JOIN
     ACCOUNT_TRANS act
 ON
     act.CENTER = t.ACCOUNT_TRANS_CENTER
     AND act.ID = t.ACCOUNT_TRANS_ID
     AND act.SUBID = t.ACCOUNT_TRANS_SUBID
 LEFT JOIN
     ACCOUNTS debit_acc
 ON
     act.DEBIT_ACCOUNTCENTER = debit_acc.CENTER
     AND act.DEBIT_ACCOUNTID = debit_acc.ID
 LEFT JOIN
     ACCOUNTS credit_acc
 ON
     act.CREDIT_ACCOUNTCENTER = credit_acc.CENTER
     AND act.CREDIT_ACCOUNTID = credit_acc.ID
 LEFT JOIN
     CUSTOMER_INVOICE ci
 ON
     ci.REFERENCE_CENTER= t.CENTER
     AND ci.REFERENCE_ID = t.ID
