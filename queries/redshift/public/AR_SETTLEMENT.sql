SELECT
    am.id                                                                    AS "ID",
    am.art_paying_center||'ar'||am.art_paying_id||'art'||am.art_paying_subid AS
                                                                         "PAYING_AR_TRANSACTION_ID",
    am.art_paid_center||'ar'||am.art_paid_id||'art'||am.art_paid_subid AS "PAID_AR_TRANSACTION_ID",
    am.amount                                                          AS "AMOUNT",
    am.entry_time                                                      AS "ENTRY_DATETIME",
    am.cancelled_time                                                  AS "CANCELLED_DATETIME",
    am.art_paid_center                                                 AS "CENTER_ID",
    art_paid.last_modified                                             AS "ETS"
FROM
    art_match am
JOIN
    ar_trans art_paid
ON
    am.art_paid_center=art_paid.center
AND am.art_paid_id=art_paid.id
AND am.art_paid_subid=art_paid.subid
