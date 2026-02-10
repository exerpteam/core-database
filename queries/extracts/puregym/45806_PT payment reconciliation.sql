-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3707
 SELECT
         t1.Bookdate AS "Book date",
         t1.Text AS "Text",
         t1.DebitExternalId AS "Debit External Id",
         t1.Debit AS "Debit",
         t1.Credit AS "Credit",
         t1.CreditExternalId AS "Credit External Id",
         t1.DebitAccount AS "Debit Account",
         t1.CreditAccount AS "Credit Account",
         t1.VAT AS "VAT",
         t1.TypeT1 AS "Type",
         t1.Entrytime AS "Entry time",
         t1.Aggrtransid AS "Aggr. trans. id",
         t1.Centername AS "Center name",
         p.FULLNAME AS "Member Name",
         p.CENTER || 'p' || p.ID AS "Member P",
         t1.StartDate AS "Subscription Start Date",
         t1.EndDate AS "Subscription End Date",
         (CASE
                 WHEN t1.SubscriptionCenter IS NOT NULL THEN t1.SubscriptionCenter || 'ss' || t1.SubscriptionId
                 ELSE NULL
         END) AS "SubscriptionId"
 FROM
 (
         SELECT
                 act.CENTER || 'act' ||act.ID || 'id' || act.SUBID AS ACTTRANS,
                 longtodateC(act.TRANS_TIME,act.CENTER) AS Bookdate,
                 act.TEXT AS Text,
                 debitAccount.EXTERNAL_ID AS DebitExternalId,
                 (CASE
                         WHEN debitAccount.GLOBALID IN ('INCOME_PT_RENT','INCOME_PT_FITNESS_COACH')
                         THEN act.AMOUNT
                         ELSE NULL
                 END) AS Debit,
                 (CASE
                         WHEN creditAccount.GLOBALID IN ('INCOME_PT_RENT','INCOME_PT_FITNESS_COACH')
                         THEN act.AMOUNT
                         ELSE NULL
                 END) AS Credit,
                 creditAccount.EXTERNAL_ID AS CreditExternalId,
                 debitAccount.NAME || ' (' || debitAccount.CENTER || 'acc' || debitAccount.ID || ')' AS DebitAccount,
                 creditAccount.NAME || ' (' || creditAccount.CENTER || 'acc' || creditAccount.ID || ')' AS CreditAccount,
                 vatTran.AMOUNT AS VAT,
                 vatType.NAME AS VATtype,
                 (CASE
                         WHEN act.TRANS_TYPE=1 THEN 'General ledger'
                         WHEN act.TRANS_TYPE=2 THEN 'Account receivables'
                         WHEN act.TRANS_TYPE=3 THEN 'Account payables'
                         WHEN act.TRANS_TYPE=4 THEN 'Invoice line'
                         WHEN act.TRANS_TYPE=5 THEN 'Credit note line'
                         WHEN act.TRANS_TYPE=6 THEN 'Bill line'
                         ELSE 'Unknown'
                 END) AS TypeT1,
                 longtodateC(act.ENTRY_TIME,act.CENTER) AS Entrytime,
                 act.AGGREGATED_TRANSACTION_CENTER || 'agt' || act.AGGREGATED_TRANSACTION_ID AS Aggrtransid,
                 c.NAME AS Centername,
                 (CASE
                          WHEN act.TRANS_TYPE=4 THEN il.PERSON_CENTER
                          WHEN act.TRANS_TYPE=5 THEN cn.PERSON_CENTER
                          ELSE NULL
                  END) PersonCenter,
                  (CASE
                          WHEN act.TRANS_TYPE=4 THEN il.PERSON_ID
                          WHEN act.TRANS_TYPE=5 THEN cn.PERSON_ID
                          ELSE NULL
                  END) PersonId,
                  (CASE
                          WHEN act.TRANS_TYPE=4 THEN s.CENTER
                          WHEN act.TRANS_TYPE=5 THEN s2.CENTER
                          ELSE NULL
                  END) SubscriptionCenter,
                  (CASE
                          WHEN act.TRANS_TYPE=4 THEN s.ID
                          WHEN act.TRANS_TYPE=5 THEN s2.ID
                          ELSE NULL
                  END) SubscriptionId,
                  (CASE
                          WHEN act.TRANS_TYPE=4 THEN s.START_DATE
                          WHEN act.TRANS_TYPE=5 THEN s2.START_DATE
                          ELSE NULL
                  END) StartDate,
                  (CASE
                          WHEN act.TRANS_TYPE=4 THEN s.END_DATE
                          WHEN act.TRANS_TYPE=5 THEN s2.END_DATE
                          ELSE NULL
                  END) EndDate
         FROM ACCOUNT_TRANS act
         JOIN ACCOUNTS creditAccount
                 ON creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER AND creditAccount.ID = act.CREDIT_ACCOUNTID
         JOIN ACCOUNTS debitAccount
                 ON debitAccount.CENTER = act.DEBIT_ACCOUNTCENTER AND debitAccount.ID = act.DEBIT_ACCOUNTID
         JOIN CENTERS c
                 ON c.ID = act.CENTER
         LEFT JOIN ACCOUNT_TRANS vatTran
                 ON vatTran.MAIN_TRANSCENTER = act.CENTER AND vatTran.MAIN_TRANSID = act.ID AND vatTran.MAIN_TRANSSUBID = act.SUBID
         LEFT JOIN VAT_TYPES vatType
                 ON vatType.CENTER = vatTran.VAT_TYPE_CENTER AND vatType.ID = vatTran.VAT_TYPE_ID
         LEFT JOIN INVOICE_LINES_MT il
                 ON il.ACCOUNT_TRANS_CENTER = act.CENTER AND il.ACCOUNT_TRANS_ID = act.ID AND il.ACCOUNT_TRANS_SUBID = act.SUBID
         LEFT JOIN SPP_INVOICELINES_LINK spplink
                 ON spplink.INVOICELINE_CENTER = il.CENTER AND spplink.INVOICELINE_ID = il.ID AND spplink.INVOICELINE_SUBID = il.SUBID
         LEFT JOIN SUBSCRIPTIONPERIODPARTS spp
                 ON spp.CENTER = spplink.PERIOD_CENTER AND spp.ID = spplink.PERIOD_ID AND spp.SUBID = spplink.PERIOD_SUBID
         LEFT JOIN SUBSCRIPTIONS s
                 ON s.CENTER = spp.CENTER AND s.ID = spp.ID
         LEFT JOIN CREDIT_NOTE_LINES_MT cn
                 ON cn.ACCOUNT_TRANS_CENTER = act.CENTER AND cn.ACCOUNT_TRANS_ID = act.ID AND cn.ACCOUNT_TRANS_SUBID = act.SUBID
         LEFT JOIN SPP_INVOICELINES_LINK spplink2
                 ON spplink2.INVOICELINE_CENTER = cn.CENTER AND spplink2.INVOICELINE_ID = cn.ID AND spplink2.INVOICELINE_SUBID = cn.SUBID
         LEFT JOIN SUBSCRIPTIONPERIODPARTS spp2
                 ON spp2.CENTER = spplink2.PERIOD_CENTER AND spp2.ID = spplink2.PERIOD_ID AND spp2.SUBID = spplink2.PERIOD_SUBID
         LEFT JOIN SUBSCRIPTIONS s2
                 ON s2.CENTER = spp2.CENTER AND s2.ID = spp2.ID
         WHERE
                 act.TRANS_TIME >= :fromdate
                 AND act.TRANS_TIME < :todate + 86400000
                 AND (creditAccount.GLOBALID = :GlobalId OR debitAccount.GLOBALID = :GlobalId)
                                 AND act.CENTER IN (:Scope)
         ORDER BY
                 act.TRANS_TIME
 ) t1
 LEFT JOIN PERSONS p ON t1.PersonCenter = p.CENTER AND t1.PersonId = p.ID
