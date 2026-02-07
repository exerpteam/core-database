SELECT
	agt.center,
    'GLE'||GL_EXPORT_BATCH_ID              AS "Reference",
    longtodateC(gle.ENTRY_TIME,agt.CENTER) AS "Date",
    exp.STATUS ,
    agt.BOOK_DATE  AS "Bokföringsdate",
    agt.TEXT       AS "Text",
    agt.AMOUNT     AS "Summa",
    agt.VAT_AMOUNT AS "Moms",
    agt.DEBIT_ACCOUNT_EXTERNAL_ID as "Debit Account",
    agt.CREDIT_ACCOUNT_EXTERNAL_ID as "Credit Account"
FROM
    aggregated_transactions agt
LEFT JOIN
    GL_EXPORT_BATCHES gle
ON
    gle.id = agt.GL_EXPORT_BATCH_ID
LEFT JOIN
    EXCHANGED_FILE ef
ON
    ef.ID = gle.EXCHANGED_FILE_ID
LEFT JOIN
    EXCHANGED_FILE_EXP exp
ON
    exp.EXCHANGED_FILE_ID = gle.EXCHANGED_FILE_ID
WHERE

    agt.CENTER IN (:Scope)

AND agt.book_date >= (:FromDate) 
AND agt.book_date <= (:ToDate) 
