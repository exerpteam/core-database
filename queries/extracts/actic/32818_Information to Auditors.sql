-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/wiki/spaces/CAS/pages/472416261/Information+to+Auditors
https://clublead.atlassian.net/browse/ST-6354
SELECT
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
    agt.CENTER IN($$scope$$)
    AND agt.BOOK_DATE BETWEEN $$from_date$$ AND $$To_date$$