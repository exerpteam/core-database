-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
       SELECT
            /*+ materialize */
            c.id,
            CAST (dateToLongC(TO_CHAR(CAST($$FromDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS fromDate,
            CAST((dateToLongC(TO_CHAR(CAST($$ToDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS toDate
        FROM
            centers c
    )
SELECT
        (
                CASE
                    WHEN p.status = 4
                    THEN rel.center ||'p'|| rel.id
                    ELSE p.center ||'p'|| p.id
                END) AS "Member id",
    t1.Bookdate         AS "Book date",
    t1.arttext          as "Consolidated text",
    t1.DebitExternalId  AS "Debit",
    t1.DebitAccount     AS "Debit Account",
    t1.CreditExternalId AS "Credit",
    t1.CreditAccount    AS "Credit Account",
    t1.amount           AS "Amount",
    t1.VAT              AS "VAT",
    t1.VATtype          AS "VAT type",
    t1.Entrytime        as "Entry time",
    t1.Aggrtransid      as "Aggregated trans ID", 
    t1.actcenter        as "Center name"
FROM
    (
        SELECT
            act.CENTER || 'act' ||act.ID || 'id' || act.SUBID                     AS ACTTRANS,
         TO_CHAR(longtodatec(act.trans_TIME,act.CENTER),'YYYY-MM-dd') AS Bookdate,
            act.TEXT                                                              AS Text,
            debitAccount.EXTERNAL_ID                                              AS
                          DebitExternalId,
            act.AMOUNT                                                     AS Amount,
            creditAccount.EXTERNAL_ID                                           AS CreditExternalId,
            debitAccount.NAME || ' (' || debitAccount.CENTER || 'acc' || debitAccount.ID || ')' AS
            DebitAccount,
            creditAccount.NAME || ' (' || creditAccount.CENTER || 'acc' || creditAccount.ID || ')'
                           AS CreditAccount,
            vatTran.AMOUNT AS VAT,
            vatType.NAME   AS VATtype,
            (
                CASE
                    WHEN act.TRANS_TYPE=1
                    THEN 'General ledger'
                    WHEN act.TRANS_TYPE=2
                    THEN 'Account receivables'
                    WHEN act.TRANS_TYPE=3
                    THEN 'Account payables'
                    WHEN act.TRANS_TYPE=4
                    THEN 'Invoice line'
                    WHEN act.TRANS_TYPE=5
                    THEN 'Credit note line'
                    WHEN act.TRANS_TYPE=6
                    THEN 'Bill line'
                    ELSE 'Unknown'
                END)                                                              AS TypeT1,
     TO_CHAR(longtodatec(act.ENTRY_TIME,act.CENTER), 'YYYY-MM-dd HH24:MI') AS Entrytime,
            (
                CASE
                    WHEN act.AGGREGATED_TRANSACTION_CENTER IS NOT NULL
                    THEN act.AGGREGATED_TRANSACTION_CENTER || 'agt' ||
                        act.AGGREGATED_TRANSACTION_ID
                    ELSE NULL
                END) AS Aggrtransid,
            c.NAME   AS Centername,
            (
                CASE
                    WHEN act.TRANS_TYPE=2
                    THEN ar.CUSTOMERCENTER
                    WHEN act.TRANS_TYPE=4
                    THEN il.PERSON_CENTER
                    WHEN act.TRANS_TYPE=5
                    THEN cn.PERSON_CENTER
                    ELSE NULL
                END) PersonCenter,
            (
                CASE
                    WHEN act.TRANS_TYPE=2
                    THEN ar.CUSTOMERID
                    WHEN act.TRANS_TYPE=4
                    THEN il.PERSON_ID
                    WHEN act.TRANS_TYPE=5
                    THEN cn.PERSON_ID
                    ELSE NULL
                END) PersonId ,
            ar.*,
            act.center as actcenter,
            act.id as actid,
            act.subid as actsubid,
            (
                CASE
                    WHEN act.TRANS_TYPE=2
                    THEN art.text
                    WHEN act.TRANS_TYPE=4
                    THEN artt.text
                    WHEN act.TRANS_TYPE=5
                    THEN arttc.text
                    ELSE NULL
                END) arttext

        FROM
            ACCOUNT_TRANS act
        JOIN
            CENTERS c
        ON
            c.ID = act.CENTER
        LEFT JOIN
            ACCOUNTS creditAccount
        ON
            creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER
        AND creditAccount.ID = act.CREDIT_ACCOUNTID
        LEFT JOIN
            ACCOUNTS debitAccount
        ON
            debitAccount.CENTER = act.DEBIT_ACCOUNTCENTER
        AND debitAccount.ID = act.DEBIT_ACCOUNTID
        LEFT JOIN
            ACCOUNT_TRANS vatTran
        ON
            vatTran.MAIN_TRANSCENTER = act.CENTER
        AND vatTran.MAIN_TRANSID = act.ID
        AND vatTran.MAIN_TRANSSUBID = act.SUBID
        LEFT JOIN
            VAT_TYPES vatType
        ON
            vatType.CENTER = vatTran.VAT_TYPE_CENTER
        AND vatType.ID = vatTran.VAT_TYPE_ID
        LEFT JOIN
            INVOICE_LINES_MT il
        ON
            il.ACCOUNT_TRANS_CENTER = act.CENTER
        AND il.ACCOUNT_TRANS_ID = act.ID
        AND il.ACCOUNT_TRANS_SUBID = act.SUBID
        AND act.TRANS_TYPE=4
        LEFT JOIN
        spp_invoicelines_link sppinvlnk
        ON
                sppinvlnk.invoiceline_center = il.center
                AND sppinvlnk.invoiceline_id = il.id
                AND sppinvlnk.invoiceline_subid = il.subid
        LEFT JOIN
            CREDIT_NOTE_LINES_MT cn
        ON
            cn.ACCOUNT_TRANS_CENTER = act.CENTER
        AND cn.ACCOUNT_TRANS_ID = act.ID
        AND cn.ACCOUNT_TRANS_SUBID = act.SUBID
        AND act.TRANS_TYPE=5
        LEFT JOIN
        spp_invoicelines_link sppcnlnk
        ON
                sppcnlnk.invoiceline_center = cn.invoiceline_center
                AND sppcnlnk.invoiceline_id = cn.invoiceline_id
                AND sppcnlnk.invoiceline_subid = cn.invoiceline_subid
        LEFT JOIN
            AR_TRANS art
        ON
            art.REF_CENTER = act.CENTER
        AND art.REF_ID = act.ID
        AND art.REF_SUBID = act.SUBID
        AND act.TRANS_TYPE=2
        AND art.REF_TYPE = 'ACCOUNT_TRANS'
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
        AND ar.ID = art.ID
        JOIN
            params
        ON
            params.id = act.center
LEFT JOIN
            AR_TRANS artt
        ON
            artt.REF_CENTER = il.CENTER
        AND artt.REF_ID = il.ID
        AND act.TRANS_TYPE=4
    LEFT JOIN
            AR_TRANS arttc
        ON
            arttc.REF_CENTER = cn.CENTER
        AND arttc.REF_ID = cn.ID   
        AND act.TRANS_TYPE=5

        WHERE
            act.TRANS_TIME >= params.fromDate
        AND act.TRANS_TIME < params.toDate
        AND act.CENTER IN (:Scope)
        AND act.MAIN_TRANSCENTER IS NULL
        and (creditAccount.EXTERNAL_ID in (:externalid) or debitAccount.EXTERNAL_ID in (:externalid))
        ORDER BY
            act.TRANS_TIME ) t1
LEFT JOIN
    PERSONS p
ON
    t1.PersonCenter = p.CENTER
AND t1.PersonId = p.ID

LEFT JOIN
    PERSONS rel
ON
    rel.center = p.CURRENT_PERSON_CENTER
AND rel.id = p.CURRENT_PERSON_ID