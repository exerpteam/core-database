-- The extract is extracted from Exerp on 2026-02-08
-- EC-4702
 SELECT
            agt.book_date                  AS "BOOK_DATE",
            agt.text                       AS "TEXT",
            agt.debit_account_external_ID  AS "DEBIT",
            agt.amount                     AS "AMOUNT",
            agt.credit_account_external_ID AS "CREDIT",
            agt.vat_amount                 AS "VAT",
            agt.vat_rate                   AS "VATTYPE",
			agt.id							AS "AGGR.TRANS.ID",
            c.name                         AS "CENTER_NAME"
       FROM
            aggregated_transactions agt
       JOIN
            centers c ON c.id = agt.center
      WHERE
        agt.book_date >= :date_from
        AND agt.book_date <= :date_to
        and c.id in (:scope)
